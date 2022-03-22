function simulate_point(v, p, β1, β2, t, g, action; min_v_on_impact=1)
    v0, p0 = v, p
    
    if action=="hit" && p >= 4 # Hitting the ball changes the velocity
        if v < 0
            v0 = min(v, -4)
        else
            v0 = -β2*v - 4
        end
    end
    
    new_v = g * t + v0
    new_p = 0.5 * g * t^2 + v0*t + p0
    
    if new_p <= 0 # It went through the floor, meaning that a bounce occurs
        t_impact = (-v0 - sqrt(v0^2 - 2*g*p0))/g 
        t_remaining = t - t_impact       # Time left this timestep after bounce occurs
        new_v = g * t_impact + v0        # Gravity pull before impact
        new_v = -β1 * new_v              # Impact 
		new_p = 0

		if new_v >= min_v_on_impact
	        new_v, new_p = simulate_point(new_v, new_p, β1, β2, t_remaining, g, action, 
										  min_v_on_impact=min_v_on_impact)
		else
			new_v, new_p = 0, 0
		end
    end
    
    new_v, new_p
end


function simulate_sequence(v0, p0, t, g, policy, duration; 
							β1=:random, β2=:random)
	randomize_β1 = β1 == :random
	randomize_β2 = β2 == :random
    velocities::Array{Real}, positions::Array{Real}, times::Array{Real} = [v0], [p0], [0.0]
    v, p = v0, p0
    for i in 1:ceil(duration/t)
		β1 = randomize_β1 ? rand(0.85:0.01:0.97) : β1
		β2 = randomize_β2 ? rand(0.90:0.01:1.00) : β2
        action = policy(v, p)
        v, p = simulate_point(v, p, β1, β2, t, g, action)
        push!(velocities, v)
        push!(positions, p)
        push!(times, i*t)
    end
    velocities, positions, times
end

e_pot(g, p) = abs(g)*p
e_kin(g, v) = 0.5*v^2
e_mek(g, v, p) = e_kin(g, v) + e_pot(g, p)
