function simulate_point(mechanics, v, p, action; min_v_on_impact=1, unlucky=false)
	t_hit, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit  = mechanics
    v0, p0 = v, p
    
    if action=="hit" && p >= p_hit # Hitting the ball changes the velocity
        if v < 0
            v0 = min(v, v_hit)
        else
			if unlucky
            	v0 = -(β2 - ϵ2)*v + v_hit
			else
				v0 = -rand(β2 - ϵ2:0.01:β2 + ϵ2)*v + v_hit
			end
        end
    end
    
    new_v = g * t_hit + v0
    new_p = 0.5 * g * t_hit^2 + v0*t_hit + p0
    
    if new_p <= 0 # It went through the floor, meaning that a bounce occurs
        t_impact = (-v0 - sqrt(v0^2 - 2*g*p0))/g 
        t_remaining = t_hit - t_impact      # Time left this timestep after bounce occurs
        new_v = g * t_impact + v0        # Gravity pull before impact
		# Impact
		if unlucky
        	new_v = -(β1 - ϵ1)*new_v
		else
        	new_v = -rand(β1 - ϵ1:0.01:β1 + ϵ1)*new_v 
		end
		new_p = 0

		mechanics′ = (t_hit=t_remaining, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit)
		if new_v >= min_v_on_impact
	        new_v, new_p = simulate_point(mechanics′, new_v, new_p, action, min_v_on_impact=min_v_on_impact, unlucky=unlucky)
		else
			new_v, new_p = 0, 0
		end
    end
    
    new_v, new_p
end


function simulate_sequence(mechanics, v0, p0, 
						   policy, duration; 
						   unlucky=false)
	t_hit, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit  = mechanics
    velocities::Vector{Real}, positions::Vector{Real}, times = [v0], [p0], [0.0]
    v, p, t = v0, p0, 0
    while times[end] <= duration - t_hit
        action = policy(v, p)
        v, p = simulate_point(mechanics, v, p, action, unlucky=unlucky)
		t += t_hit
        push!(velocities, v)
        push!(positions, p)
        push!(times, t)
    end
    velocities, positions, times
end


function evaluate(	mechanics, 
	policy, duration;
	unlucky=false,
	runs=1000,
	cost_hit=1)
t_hit, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit  = mechanics
costs = []
for run in 1:runs
v, p = 0, rand(7:10)
cost = 0
for i in 1:ceil(duration/t_hit)
action = policy(v, p)
cost += action == "hit" ? 1 : 0
v, p = simulate_point(mechanics, v, p, action, unlucky=unlucky)
end
push!(costs, cost)
end
sum(costs)/runs
end