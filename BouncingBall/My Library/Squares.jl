struct Grid
    G::Real
    v_min::Real
    v_max::Real
    p_min::Real
    p_max::Real
    v_count::Int
    p_count::Int
    array
end

	
function Grid(G, v_min, v_max, p_min, p_max)
    v_count::Int = ceil((v_max - v_min)/G)
    p_count::Int = ceil((p_max - p_min)/G)
    array = zeros(Int8, (v_count, p_count))
    Grid(G, v_min, v_max, p_min, p_max, v_count, p_count, array)
end

struct Square
    grid::Grid
    iv::Int
    ip::Int
end

Base.show(io::IO, ::MIME"text/plain", square::Square) = println(io, "Square(_, $(square.iv), $(square.ip))")


function box(grid::Grid, v, p)::Square
	if v < grid.v_min || v >= grid.v_max
		error("v value out of bounds.")
	end
	if p < grid.p_min || p >= grid.p_max
		error("v value out of bounds.")
	end

	iv = floor(Int, (v - grid.v_min)/grid.G) + 1
	ip = floor(Int, (p - grid.p_min)/grid.G) + 1
	Square(grid, iv, ip)
end


function bounds(square::Square)
	iv, ip = square.iv-1, square.ip-1
	v_min, v_max = square.grid.v_min, square.grid.v_max
	p_min, p_max = square.grid.p_min, square.grid.p_max
	G = square.grid.G
	Ivl, Ipl = G * iv + v_min, G * ip + p_min
	Ivu, Ipu = G * (iv+1) + v_min, G * (ip+1) + p_min
	Ivl, Ivu, Ipl, Ipu
end


function set_value!(square::Square, value)
	square.grid.array[square.iv, square.ip] = value
end


function get_value(square::Square)
	square.grid.array[square.iv, square.ip]
end


function clear(grid::Grid)
	for iv in 1:grid.v_count
		for ip in 1:grid.p_count
			grid.array[iv, ip] = 0
		end
	end
end


function initialize!(grid::Grid, value_function=
								(Ivl, Ivu, Ipl, Ipu) -> Ivl == 0 && Ipl == 0 ? 2 : 1)
	for iv in 1:grid.v_count
		for ip in 1:grid.p_count
			square = Square(grid, iv, ip)
			set_value!(square, value_function(bounds(square)...))
		end
	end
end


function draw(grid::Grid; colors=[:white, :black], show_grid=false)
	colors = cgrad(colors, length(colors), categorical=true)
	x_tics = grid.v_min:grid.G:grid.v_max
	y_tics = grid.p_min:grid.G:grid.p_max
	
	hm = heatmap(x_tics, y_tics, transpose(grid.array), c=colors)

	if show_grid && length(grid.v_min:grid.G:grid.v_max) < 100
		vline!(grid.v_min:grid.G:grid.v_max, color="#afafaf", label=nothing)
		hline!(grid.p_min:grid.G:grid.p_max, color="#afafaf", label=nothing)
	end

	return hm
end