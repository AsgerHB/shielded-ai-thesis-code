function simulate_point(v, p, β1, β2, t, g, action)
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
    
    if new_p <= 0
        t_impact = (-v0 - sqrt(v0^2 - 2*g*p0))/g 
        t_remaining = t - t_impact       # Time left this timestep after bounce occurs
        new_v = g * t_impact + v0         # Gravity pull before bounce
        new_v = -β1 * new_v          # Bounce
        new_v = g * t_remaining + new_v   # Gravity pull after bounce
        new_p = 0.5 * g * t_remaining^2 + new_v * t_remaining + 0  # Jump height after bounce
        
        if new_p <= 0           # If it hits the ground twice within the same timestep, 
            new_v, new_p = 0, 0  # simply put the ball to a stop.
        end
    end
    
    new_v, new_p
end


function simulate_sequence(v0, p0, t, g, policy, duration)
    velocities::Array{Real}, positions::Array{Real}, times::Array{Real} = [v0], [p0], [0.0]
    v, p = v0, p0
    for i in 1:ceil(duration/t)
        action = policy(v, p)
		β1, β2 = rand(0.85:0.01:0.97), rand(0.9:0.01:1.0)
        v, p = simulate_point(v, p, β1, β2, t, -9.81, action)
        push!(velocities, v)
        push!(positions, p)
        push!(times, i*t)
    end
    velocities, positions, times
end

e_pot(g, p) = abs(g)*p
e_kin(g, v) = 0.5*v^2
e_mek(g, v, p) = e_kin(g, v) + e_pot(g, p)
