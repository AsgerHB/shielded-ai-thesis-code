function draw_barbaric_transition!(square::Square, resolution, β1, β2, t, g, action; upto_t=false)
	Ivl, Ivu, Ipl, Ipu = bounds(square)
	step = square.grid.G/resolution
	v_start, p_start = [], []
	v_end, p_end = [], []
	t_values = !upto_t ? [t] : (t/resolution:t/resolution:t)
	# Start positions
	for v in Ivl:step:(Ivu)
		for p in Ipl:step:(Ipu)
			push!(v_start, v)
			push!(p_start, p)
		end
	end
	# End positions
	for t′ in t_values
		for v in Ivl:step:(Ivu)
			for p in Ipl:step:(Ipu)
				w, q = simulate_point(v, p, β1, β2, t′, g, action)
				push!(v_end, w)
				push!(p_end, q)
			end
		end
	end
	scatter!(v_start, p_start, label="start", markersize=1, markerstrokewidth=0, markercolor="#888A85")
	scatter!(v_end, p_end, label="end", markersize=1, markerstrokewidth=0, markercolor="#000000")
end


"""Get a list of grid indexes representing reachable squares. 

I could have used proper squares for this, but I want to save that extra bit of memory by not having lots of references back to the same  grid.
"""
function get_reachable_area(square::Square, resolution, β1, β2, t, g, action; 
							upto_t=false)
	Ivl, Ivu, Ipl, Ipu = bounds(square)
	result = []
	
	step = square.grid.G/resolution # Distance between (v,p)-points
	t_values = !upto_t ? [t] : (t/resolution:t/resolution:t)
	for t′ in t_values
		for v in Ivl:step:(Ivu)
			for p in Ipl:step:(Ipu)
				w, q = simulate_point(v, p, β1, β2, t′, g, action)
				
				if !(square.grid.v_min <= w <= square.grid.v_max) || !(square.grid.p_min <= q <= square.grid.p_max)
					continue
				end
				
				square′ = box(square.grid, w, q)
				iv_ip = (square′.iv, square′.ip)
				if !(iv_ip ∈ result)
					push!(result, iv_ip)
				end
			end
		end
	end
	result
end


function set_reachable_area!(square::Square, resolution, β1, β2, t, g, action, value; upto_t=false)
	reachable_area = get_reachable_area(square, resolution, β1, β2, t, g, action, upto_t=upto_t)
	for (iv, ip) in reachable_area
		square.grid.array[iv, ip] = value
	end
end


"""Computes and returns the tuple `(hit, nohit)`.

`hit` is a 2D-array of vectors of the same layout as the `array` of the given `grid`. If a square in `grid` has index `iv, ip`, then the vector at `hit[iv, ip]` will contain tuples `(ivʹ, ipʹ)` of square indexes that are reachable by hitting the ball from `iv, ip`. 

The same goes for `nohit` just with the "nohit" action. 
"""
function get_transitions(grid, resolution, β1, β2, t, g; upto_t=false)
	hit = Array{Vector{Any}}(undef, (grid.v_count, grid.p_count))
	nohit = Array{Vector{Any}}(undef, (grid.v_count, grid.p_count))
	
	for iv in 1:grid.v_count
		for ip in 1:grid.p_count
			square = Square(grid, iv, ip)
			hit[iv, ip] = get_reachable_area(square, resolution, β1, β2, t, g, 
											 "hit", upto_t=upto_t)
			nohit[iv, ip] = get_reachable_area(square, resolution, β1, β2, t, g, 
											   "nohit", upto_t=upto_t)
		end
	end
	hit, nohit
end		



"""Compute the new value of a single square.

NOTE: Requires pre-baked transition matrices `reachable_hit` and `reachable_nohit`. Get these by calling `get_transitions`. 

Value can be either 0, if this square cannot reach any bad squares, 1 if the ball must be hit to avoid reaching bad squares, or 2 if reaching a bad square is inevitable.
"""
function get_new_value( reachable_hit::Matrix{Vector{Any}}, 
						reachable_nohit::Matrix{Vector{Any}}, 
						square::Square,
						grid:: Grid,
						β1, β2, t, g)
	value = get_value(square)

	if value == 2 # Bad squares stay bad. 
		return 2
	end
	
 	# check if a bad square is reachable for nohit
	nohit_bad = false
	for (iv′, ip′) in reachable_nohit[square.iv, square.ip]
		if get_value(Square(grid, iv′, ip′)) == 2
			nohit_bad = true
			break
		end
	end

	# check if hit avoids reaching bad squares
	if nohit_bad
		for (iv′, ip′) in reachable_hit[square.iv, square.ip]
			if get_value(Square(grid, iv′, ip′)) == 2
				return 2
			end
		end
		return 1
	else
		return 0
	end
end


"""Take a single step in the fixed point compuation.
"""
function shield_step( reachable_hit::Matrix{Vector{Any}}, 
					  reachable_nohit::Matrix{Vector{Any}}, 
					  grid::Grid, 
					  resolution, β1, β2, t, g)
	grid′ = Grid(grid.G, grid.v_min, grid.v_max, grid.p_min, grid.p_max)
	
	for iv in 1:grid.v_count
		for ip in 1:grid.p_count
			grid′.array[iv, ip] = get_new_value(reachable_hit, reachable_nohit, Square(grid, iv, ip), grid, β1, β2, t, g)
		end
	end
	grid′
end


"""Generate shield. 

Given some initial grid, returns a tuple `(shield, terminated_early)`. 

`shield` is a new grid containing the fixed point for the given values. 

`terminted_early` is a boolean value indicating if `max_steps` were exceeded before the fixed point could be reached.
"""
function make_shield( reachable_hit::Matrix{Vector{Any}}, 
					  reachable_nohit::Matrix{Vector{Any}}, 
					  grid::Grid, 
					  resolution, β1, β2, t, g; 
					  max_steps=1000,
					  animate=false)
	animation = nothing
	if animate
		animation = Animation()
		draw(grid, colors=["#90ee90", "#ffffe0", "#ea786b"])
		frame(animation)
	end
	i = max_steps
	grid′ = nothing
	while i > 0
		grid′ = shield_step(reachable_hit, reachable_nohit, grid, resolution, β1, β2, t, g)
		if grid′.array == grid.array
			break
		end
		grid = grid′
		i -= 1
		if animate
			draw(grid, colors=["#90ee90", "#ffffe0", "#ea786b"])
			frame(animation)
		end
	end
	grid′, i==0, animation
end


"""Generate shield. 

Given some initial grid, returns a tuple `(shield, terminated_early)`. 

`shield` is a new grid containing the fixed point for the given values. 

`terminted_early` is a boolean value indicating if `max_steps` were exceeded before the fixed point could be reached.
"""
function make_shield(grid::Grid, resolution, β1, β2, t, g;
					 max_steps=1000, animate=false)
	reachable_hit, reachable_nohit = get_transitions(grid, resolution, β1, β2, t, g)
	
	return make_shield(reachable_hit, reachable_nohit, grid, resolution, β1, β2, t, g; max_steps=max_steps, animate=animate)		
end


function shield_action(shield::Grid, v, p, action)
	if v < shield.v_min || v > shield.v_max || p < shield.p_min || p > shield.p_max
		return action
	end
	square = box(shield, v, p)
	if get_value(square) == 1
		return "hit"
	else
		return action
	end
end