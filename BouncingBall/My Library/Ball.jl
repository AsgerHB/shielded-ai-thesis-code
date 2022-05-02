function simulate_point(mechanics, v, p, action; min_v_on_impact=1, unlucky=false)
	t, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit  = mechanics
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
    
    new_v = g * t + v0
    new_p = 0.5 * g * t^2 + v0*t + p0
    
    if new_p <= 0 # It went through the floor, meaning that a bounce occurs
        t_impact = (-v0 - sqrt(v0^2 - 2*g*p0))/g 
        t_remaining = t - t_impact       # Time left this timestep after bounce occurs
        new_v = g * t_impact + v0        # Gravity pull before impact
		# Impact
		if unlucky
        	new_v = -(β1 - ϵ1)*new_v
		else
        	new_v = -rand(β1 - ϵ1:0.01:β1 + ϵ1)*new_v 
		end
		new_p = 0

		if new_v >= min_v_on_impact
	        new_v, new_p = simulate_point(mechanics, new_v, new_p, action, min_v_on_impact=min_v_on_impact, unlucky=unlucky)
		else
			new_v, new_p = 0, 0
		end
    end
    
    new_v, new_p
end

function simulate_sequence(mechanics, v0, p0, 
						   policy, duration; unlucky=false)
	t, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit  = mechanics
	randomize_β1 = β1 == :random
	randomize_β2 = β2 == :random
    velocities::Array{Real}, positions::Array{Real}, times::Array{Real} = [v0], [p0], [0.0]
    v, p = v0, p0
    for i in 1:ceil(duration/t)
		β1 = randomize_β1 ? rand(0.85:0.01:0.97) : β1
		β2 = randomize_β2 ? rand(0.90:0.01:1.00) : β2
        action = policy(v, p)
        v, p = simulate_point(mechanics, v, p, action, unlucky=unlucky)
        push!(velocities, v)
        push!(positions, p)
        push!(times, i*t)
    end
    velocities, positions, times
end

e_kin(g, v) = 0.5*abs(g)*v^2
e_pot(g, p) = abs(g)*p
e_mek(g, v, p) = e_kin(g, v) + e_pot(g, p)
