function step(ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, x, t, a)
	x′, t′ =  x, t
	if a == :fast
		x′ = x + rand(δ_fast - ϵ1:0.005:δ_fast + ϵ1 )
		t′ = t + rand(τ_fast - ϵ2:0.005:τ_fast + ϵ2 )
	else
		x′ = x + rand(δ_slow - ϵ1:0.005:δ_slow + ϵ1 )
		t′ = t + rand(τ_slow - ϵ2:0.005:τ_slow + ϵ2 )
	end
	x′, t′
end


function draw_next_step!(x_max, t_max, ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, x, t, a)
	if a == :both
		draw_next_step!(x_max, t_max, ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, x, t, :fast)
		return draw_next_step!(x_max, t_max, ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, x, t, :slow)
	end
	color = a == :fast ? :blue : :yellow
	scatter!([x], [t], 
		xlimit=[0, x_max], 
		ylimit=[0, t_max], 
		markersize=2, 
		color=:black, 
		aspect_ratio=:equal)
	δ, τ = a == :fast ? (δ_fast, τ_fast) : (δ_slow, τ_slow)
	δ, τ = δ + x, τ + t
	plot!(Shape([δ - ϵ1, δ - ϵ1, δ + ϵ1, δ + ϵ1], 
				[τ - ϵ2, τ + ϵ2, τ + ϵ2, τ - ϵ2]), 
			color=color,
			opacity=0.8,
			linewidth=0,
			legend=nothing)
	plot!([x, δ], [t, τ], linestyle=:dash, linecolor=:blue)
end


function draw_walk!(xs, ts, actions)
	linecolors = [a == :fast ? :blue : :yellow for a in actions]
	plot!(xs, ts,
		xlimit=[0, bounds.x_max],
		ylimit=[0, bounds.t_max],
		markershape=:circle,
		markersize=2,
		markercolor=:black,
		aspect_ratio=:equal,
		linecolor=linecolors,
		xlabel="x",
		ylabel="t",
		legend=nothing)
end


function take_walk(cost_slow, cost_fast, 
					x_max, t_max, 
					ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, 
					policy::Function)
	xs, ts, actions = [0.], [0.], [policy(0, 0)]
	total_cost = 0

	while last(xs) < x_max && last(ts) < t_max
		a = policy(last(xs), last(ts))
		x, t = step(ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, last(xs), last(ts), a)
		push!(xs, x)
		push!(ts, t)
		push!(actions, a)
		total_cost += a == :fast ? cost_fast : cost_slow
	end

	xs, ts, actions, total_cost, last(ts) < t_max
end


function evaluate(cost_slow, cost_fast, 
					x_max, t_max, 
					ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, 
					policy::Function; iterations=1000)
	losses = 0
	costs = []
	for i in 1:iterations
		_, _, _, cost, winner = take_walk(cost_slow, cost_fast, 
					x_max, t_max, 
					ϵ1, ϵ2, δ_fast, δ_slow, τ_fast, τ_slow, 
					policy)
		if !winner
			losses += 1
		end
		push!(costs, cost)
	end
	perfect = losses == 0
	average_wins = (iterations - losses) / iterations
	average_cost = sum(costs)/length(costs)
	perfect, average_wins, average_cost
end