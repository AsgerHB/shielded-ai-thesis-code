module BarbaricShielding
#draw_barbaric_transition!, get_reachable_area, set_reachable_area!, get_transitions, get_new_value, shield_step, make_shield, make_shield, shield_action = BS.draw_barbaric_transition!, BS.get_reachable_area, BS.set_reachable_area!, BS.get_transitions, BS.get_new_value, BS.shield_step, BS.make_shield, BS.make_shield, BS.shield_action
export draw_barbaric_transition!, get_reachable_area, set_reachable_area!, get_transitions, get_new_value, shield_step, make_shield, make_shield, shield_action

S = include("SquaresXY.jl")
box, bounds, set_value!, get_value, clear, initialize!, draw = S.box, S.bounds, S.set_value!, S.get_value, S.clear, S.initialize!, S.draw, 

function draw_barbaric_transition!(square, resolution, point_function::Function; upto_t=false)
	Ixl, Ixu, Iyl, Iyu = bounds(square)
	step = square.grid.G/resolution
	x_start, y_start = [], []
	x_end, y_end = [], []
	t_values = !upto_t ? [t] : (t/resolution:t/resolution:t)
	# Start positions
	for x in Ixl:step:(Ixu)
		for y in Iyl:step:(Iyu)
			push!(x_start, x)
			push!(y_start, y)
		end
	end
	# End positions
	for t′ in t_values
		for x in Ixl:step:(Ixu)
			for y in Iyl:step:(Iyu)
				xʹ, yʹ = point_function(x, y, t′)
				push!(x_end, xʹ)
				push!(y_end, yʹ)
			end
		end
	end
	scatter!(x_start, y_start, label="start", markersize=1, markerstrokewidth=0, markercolor="#888A85")
	scatter!(x_end, y_end, label="end", markersize=1, markerstrokewidth=0, markercolor="#000000")
end


"""Get a list of grid indexes representing reachable squares. 

I could have used proper squares for this, but I want to save that extra bit of memory by not having lots of references back to the same  grid.
"""
function get_reachable_area(square, resolution, point_function::Function; 
							upto_t=false)
	Ixl, Ixu, Iyl, Iyu = bounds(square)
	result = []
	
	step = square.grid.G/resolution # Distance between (x,y)-points
	t_values = !upto_t ? [t] : (t/resolution:t/resolution:t)
	for t′ in t_values
		for x in Ixl:step:(Ixu)
			for y in Iyl:step:(Iyu)
				xʹ, yʹ = point_function(x, y, t′)
				
				if !(square.grid.x_min <= xʹ <= square.grid.x_max) || !(square.grid.y_min <= yʹ <= square.grid.y_max)
					continue
				end
				
				square′ = box(square.grid, xʹ, yʹ)
				ix_iy = (square′.ix, square′.iy)
				if !(ix_iy ∈ result)
					push!(result, ix_iy)
				end
			end
		end
	end
	result
end


function set_reachable_area!(square, resolution, action, value; upto_t=false)
	reachable_area = get_reachable_area(square, resolution, action, upto_t=upto_t)
	for (ix, iy) in reachable_area
		square.grid.array[ix, iy] = value
	end
end


"""Computes and returns the tuple `(hit, nohit)`.

`hit` is a 2D-array of vectors of the same layout as the `array` of the gixen `grid`. If a square in `grid` has index `ix, iy`, then the vector at `hit[ix, iy]` will contain tuples `(ixʹ, iyʹ)` of square indexes that are reachable by hitting the ball from `ix, iy`. 

The same goes for `nohit` just with the "nohit" action. 
"""
function get_transitions(grid, resolution, point_action_function::Function, actions; 
                            upto_t=false)
	transitions = Dict()

    for a in actions	
        transitions[a] = []
        for ix in 1:grid.x_count
            for iy in 1:grid.y_count
                square = Square(grid, ix, iy)
                transition[a][ix, iy] = get_reachable_area(square, resolution, 
                                                            (x, y) -> point_action_function(x, y, a), 
                                                            upto_t=upto_t)
            end
        end
    end
	hit, nohit
end		



# TODO: This assumes an ordering of actions where if one action does not lead to a bad state, neither does the ones after it
"""Compute the new value of a single square.

NOTE: Requires pre-baked transition matrices. Get these by calling `get_transitions`. 

WARNING: This function assumes an ordering of actions, such that if an action in is safe, subsequent actions will also be safe.

Squares with no allowable action have the value 0.

Otherwise, the value is the index of the first allowable action. That is, if the first 3 actions lead to a bad state, the value will be 4.

TODO: In the general case, this only allows you to conclude that action 4 is a safe action. It should be some sort of vector of allowed actions instead.
"""
function get_new_value( transitions::Array{Matrix{Vector{Any}}}, 
						square,
						grid,
                        point_action_function::Function,
                        actions)
	value = get_value(square)

	if value == 0 # Bad squares stay bad. 
		return 0
	end
	
    for (i, a) in enumerate(actions)
        for (ix, iy) in reachable_nohit[square.ix, square.iy]
            if get_value(Square(grid, ix, iy)) == 0
                continue
            end
        end
        return i
    end
    
    return 0
end


"""Take a single step in the fixed point compuation.
"""
function shield_step( transitions::Array{Matrix{Vector{Any}}}, 
					  grid, 
                      point_action_function::Function,
                      actions)
	grid′ = Grid(grid.G, grid.x_min, grid.x_max, grid.y_min, grid.y_max)
	
	for ix in 1:grid.x_count
		for iy in 1:grid.y_count
			grid′.array[ix, iy] = get_new_value(transitions, Square(grid, ix, iy), grid, point_action_function, actions)
		end
	end
	grid′
end


"""Generate shield. 

Gixen some initial grid, returns a tuple `(shield, terminated_early)`. 

`shield` is a new grid containing the fixed point for the gixen values. 

`terminted_early` is a boolean value indicating if `max_steps` were exceeded before the fixed point could be reached.
"""
function make_shield( transitions::Array{Matrix{Vector{Any}}}, 
					  grid,
                      point_action_function::Function,
                      actions; 
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
		grid′ = shield_step(transitions, grid, point_action_function, actions)
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

Gixen some initial grid, returns a tuple `(shield, terminated_early)`. 

`shield` is a new grid containing the fixed point for the gixen values. 

`terminted_early` is a boolean value indicating if `max_steps` were exceeded before the fixed point could be reached.
"""
function make_shield(   grid,
                        point_action_function::Function,
                        actions;
                        resolution,
                        upto_t=false,
					    max_steps=1000, animate=false)
	transitions = get_transitions(grid, resolution, point_action_function, actions, upto_t=upto_t)
	
	return make_shield(transitions, grid, point_function, actions, max_steps=max_steps, animate=animate)		
end


"""
TODO: WARNING: This assumes an ordering of actions where if one action does not lead to a bad state, neither does the ones after it in the list `actions`. 
"""
function shield_action(shield, actions, x, y, action)
	if x < shield.x_min || x > shield.x_max || y < shield.y_min || y > shield.y_max
		return action
	end
    action_index = findfirst(x -> x == action, actions)
	square = box(shield, x, y)
    square_value = get_value(square)
	if square_value < action_index
		return actions[square_value]
	else
		return action
	end
end

end#module