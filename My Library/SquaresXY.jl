
struct Grid
    G::Real
    x_min::Real
    x_max::Real
    y_min::Real
    y_max::Real
    x_count::Int
    y_count::Int
    array
end

	
function Grid(G, x_min, x_max, y_min, y_max)
    x_count::Int = ceil((x_max - x_min)/G)
    y_count::Int = ceil((y_max - y_min)/G)
    array = zeros(Int8, (x_count, y_count))
    Grid(G, x_min, x_max, y_min, y_max, x_count, y_count, array)
end

struct Square
    grid::Grid
    ix::Int
    iy::Int
end

Base.show(io::IO, ::MIME"text/plain", square::Square) = println(io, "Square(_, $(square.ix), $(square.iy))")


function box(grid::Grid, x, y)::Square
	if x < grid.x_min || x > grid.x_max
		error("x value out of bounds.")
	end
	if y < grid.y_min || y > grid.y_max
		error("x value out of bounds.")
	end

	ix = floor(Int, (x - grid.x_min)/grid.G) + 1
	iy = floor(Int, (y - grid.y_min)/grid.G) + 1
	Square(grid, ix, iy)
end


function bounds(square::Square)
	ix, iy = square.ix-1, square.iy-1
	x_min, x_max = square.grid.x_min, square.grid.x_max
	y_min, y_max = square.grid.y_min, square.grid.y_max
	G = square.grid.G
	Ixl, Iyl = G * ix + x_min, G * iy + y_min
	Ixu, Iyu = G * (ix+1) + x_min, G * (iy+1) + y_min
	Ixl, Ixu, Iyl, Iyu
end


function set_value!(square::Square, value)
	square.grid.array[square.ix, square.iy] = value
end


function get_value(square::Square)
	square.grid.array[square.ix, square.iy]
end


function clear(grid::Grid)
	for ix in 1:grid.x_count
		for iy in 1:grid.y_count
			grid.array[ix, iy] = 0
		end
	end
end


function initialize!(grid::Grid, value_function=
								(Ixl, Ixu, Iyl, Iyu) -> Ixl == 0 && Iyl == 0 ? 2 : 1)
	for ix in 1:grid.x_count
		for iy in 1:grid.y_count
			square = Square(grid, ix, iy)
			set_value!(square, value_function(bounds(square)...))
		end
	end
end


function draw(grid::Grid; colors=[:white, :black], show_grid=false)
	colors = cgrad(colors, length(colors), categorical=true)
	x_tics = grid.x_min:grid.G:grid.x_max
	y_tics = grid.y_min:grid.G:grid.y_max
	
	hm = heatmap(x_tics, y_tics, transpose(grid.array), c=colors)

	if show_grid && length(grid.x_min:grid.G:grid.x_max) < 100
		vline!(grid.x_min:grid.G:grid.v_max, color="#afafaf", label=nothing)
		hline!(grid.y_min:grid.G:grid.y_max, color="#afafaf", label=nothing)
	end

	return hm
end
