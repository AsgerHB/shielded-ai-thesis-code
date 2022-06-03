### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 6f5f5e08-199f-41a1-b477-fbd537885fd6
begin
	using PlutoUI
	using Plots
	using CSV
	using DataFrames
	using Statistics
	using StatsPlots
	using TexTables
end

# ╔═╡ 5a20bd30-e279-11ec-3f5e-ed9714dfcd32
call(f) = f()

# ╔═╡ 0299e856-d756-46fa-8a98-e9127daec70f
md"""
## Color shceme

Colors by [Flat UI](https://flatuicolors.com/palette/defo)
"""

# ╔═╡ 7a2864d6-ff32-40d8-89ae-799366b79ac8
begin
	colors = 
	(TURQUOISE = colorant"#1abc9c", 
	EMERALD = colorant"#2ecc71", 
	PETER_RIVER = colorant"#3498db", 
	AMETHYST = colorant"#9b59b6", 
	WET_ASPHALT = colorant"#34495e",
	
	GREEN_SEA   = colorant"#16a085", 
	NEPHRITIS   = colorant"#27ae60", 
	BELIZE_HOLE  = colorant"#2980b9", 
	WISTERIA     = colorant"#8e44ad", 
	MIDNIGHT_BLUE = colorant"#2c3e50", 
	
	SUNFLOWER = colorant"#f1c40f",
	CARROT   = colorant"#e67e22",
	ALIZARIN = colorant"#e74c3c",
	CLOUDS   = colorant"#ecf0f1",
	CONCRETE = colorant"#95a5a6",
	
	ORANGE = colorant"#f39c12",
	PUMPKIN = colorant"#d35400",
	POMEGRANATE = colorant"#c0392b",
	SILVER = colorant"#bdc3c7",
	ASBESTOS = colorant"#7f8c8d")
	
	[colors...]
end

# ╔═╡ e8653f6f-19df-40ba-9633-82726b6b57a8
colortheme=[colors.GREEN_SEA colors.WISTERIA colors.SUNFLOWER colors.PUMPKIN colors.NEPHRITIS colors.MIDNIGHT_BLUE]

# ╔═╡ d13faa16-897a-4d01-9b14-ff6d03f4a592
md"""
Marker Size: $(@bind marker_size NumberField(1:30, default=6))

Line Width: $(@bind line_width NumberField(1:30, default=2))
"""

# ╔═╡ e0c5c3e6-7fbc-449a-96b2-aadd647728d9
md"""
**Results CSV:** 

$(@bind selected_file PlutoUI.FilePicker([MIME("text/csv")]))
"""

# ╔═╡ d4cac18b-1bf1-477d-84e1-ace714fc9967
if selected_file == nothing
	md"# Please select file"
end

# ╔═╡ 5dc4f261-5e46-4914-948b-0c45b9443a44
selected_file

# ╔═╡ bba93717-6370-417d-8b12-01d006623c6a
rawdata = CSV.read(selected_file["data"], normalizenames=true, DataFrame)

# ╔═╡ 7904c209-eeea-4243-beb4-0e5a7fd47a56
medians = 
call(() -> begin
	grouping =  groupby(rawdata, [:Experiment, :Runs, :Death_Costs])
	medians = combine(grouping, 
		:Avg_Swings => median, :Avg_Deaths => median, :Avg_Interventions => median,
		renamecols=false)
	medians = sort(medians, [:Experiment, :Death_Costs, :Runs])
end)

# ╔═╡ e0444e2e-0e77-4e5a-ac1e-64db46f2558f
standard_deviations = 
call(() -> begin
	grouping =  groupby(rawdata, [:Experiment, :Runs, :Death_Costs])
	df = combine(grouping, 
		:Avg_Swings => std, :Avg_Deaths => std, :Avg_Interventions => std,
		renamecols=true)
	df = sort(df, [:Experiment, :Death_Costs, :Runs])
end)

# ╔═╡ 10d9e5d7-6efc-4ef2-9123-bc477d0630c1
function to_tex(df)
	# Get the size of the dataframe
	n    = size(df, 1)
	
	# Loop through the columns and convert them one at a time.
	cols = [] 
	for var in names(df)
	    # If you want a different representation for missing values, 
	    # just change the second argument of coalesce
	    push!(cols, TableCol(var, collect(1:n), coalesce.(df[var], "")))
	end
	
	# Assemble and print the table
	hcat(cols...) 
end

# ╔═╡ 6ec82ff0-6cf7-4733-9a5a-f97fdfc90af1
to_tex(TexTable(standard_deviations))

# ╔═╡ df6cfb7b-3e0f-43ed-a4b5-25dfdc56c349
call(() -> begin
	df = filter(:Experiment => !=("Layabout"), medians)
	df = filter(:Death_Costs => d -> d == "1000" || d == "-", df)
	df = transform(df, :Runs => r -> string.(r), renamecols=false)

	
	function make_label(experiment)
		if experiment != "PreShielded"
			return "$experiment d=1000"
		else
			return experiment
		end
	end

	df = transform(df, :Experiment => ByRow(make_label), renamecols=false)
	
	df = sort(df, :Runs)
	@df df plot(:Runs, :Avg_Swings, 
		group=:Experiment,
		markershape=[:circle  :hexagon  :pentagon],
		markerstrokewidth=0,
		linewidth=line_width,
		markersize=marker_size,
		color=colortheme,
		legend=:right,
		xlabel="Training runs",
		ylabel="Average swings per 120s",
		title="Comparing experiment outcomes")
	
	layabout_row = filter(:Experiment => ==("Layabout"), medians)
	
	@df layabout_row hline!(:Avg_Swings,
		label="Shielded Layabout",
		linestyle=:dash,
		linewidth=line_width+3,
		color=colors.WET_ASPHALT)
end)

# ╔═╡ d19884c3-a3c9-4df0-8220-7f1707cfe5ca
call(() -> begin
	plot(title="Comparing experiment outcomes")

	## Pre-shielded ##
	df = DataFrame(medians)
	filter!(:Experiment => e -> e == "PreShielded", df)
	transform!(df, :Runs => r -> string.(r), renamecols=false)
	sort!(df, :Runs)
	@df df plot!(:Runs, :Avg_Swings, 
		group=:Experiment,
		markershape=:square,
		markerstrokewidth=0,
		linewidth=line_width,
		markersize=marker_size,
		color=colors.PUMPKIN,
		legend_position=(0.7, 0.4),
		xlabel="Training runs",
		ylabel="Average swings per 120s")
	
	## Layabout ##
	layabout_row = filter(:Experiment => ==("Layabout"), medians)
	
	@df layabout_row hline!(:Avg_Swings,
		label="Shielded Layabout",
		linestyle=:dash,
		linewidth=line_width+3,
		color=colors.WET_ASPHALT)

	## Post-shielded & no shield ##
	
	df = DataFrame(medians)
	filter!(:Experiment => e -> e == "PostShielded" || e == "NoShield", df)
	#filter!([:Experiment, :Death_Costs] => (e, d) -> d != "-" || e != "NoShield", df)
	transform!(df, :Runs => r -> string.(r), renamecols=false)
	make_label(experiment, d) = "$experiment d=$d"
	transform!(df, [:Experiment, :Death_Costs] => ByRow(make_label), renamecols=false)
	rename!(df, :Experiment_Death_Costs => :Label)
	sort!(df, :Runs)
	@df df plot!(:Runs, :Avg_Swings, 
		group=:Label,
		markershape=[:circle :octagon :pentagon :star4 :star6 :star8],
		markerstrokewidth=0,
		linewidth=line_width,
		markersize=marker_size,
		color=[colors.GREEN_SEA colors.EMERALD colors.NEPHRITIS colors.PETER_RIVER colors.BELIZE_HOLE colors.WISTERIA],
		legend_position=(0.7, 0.4),
		xlabel="Training runs",
		ylabel="Average swings per 120s")
	
end)

# ╔═╡ 439297f0-8945-43c8-9141-e04dac3e94ee
call(() -> begin
	df = DataFrame(medians)
	filter!(:Experiment => ==("NoShield"), df)
	df = transform(df, :Runs => ByRow(r -> "$r runs"), renamecols=false)
	df = sort(df, :Runs)
	
	@df df groupedbar(:Death_Costs, :Avg_Deaths, 
		group=:Runs,
		color=colortheme,
		linecolor=colortheme,
		yscale=:none,
		xlabel="d",
		ylabel="Average deahts per 120s",
		title="Effect of d on average number of deaths")
end)

# ╔═╡ 119d6b3e-d8fb-4206-93b0-2e6dc848ac5e
call(() -> begin
	df = DataFrame(medians)
	filter!(:Experiment => ==("NoShield"), df)
	filter!(:Death_Costs => !=("10"), df)
	df = transform(df, :Runs => ByRow(r -> "$r runs"), renamecols=false)
	df = sort(df, :Runs)
	
	@df df groupedbar(:Death_Costs, :Avg_Deaths, 
		group=:Runs,
		color=colortheme,
		linecolor=colortheme,
		yscale=:none,
		xlabel="d",
		ylabel="Average deahts per 120s",
		title="Effect of d on average number of deaths")
end)

# ╔═╡ 61bd91fc-6b0f-4fa5-a3dc-ea0f87c06cf1
call(() -> begin
	df = DataFrame(medians)
	filter!(:Experiment => ==("PostShielded"), df)
	df = transform(df, :Runs => ByRow(r -> "$r runs"), renamecols=false)
	df = sort(df, :Runs)
	@df df groupedbar(:Death_Costs, :Avg_Interventions, 
		group=:Runs,
		color=colortheme,
		linecolor=colortheme,
		yscale=:none,
		bar_width=0.2,
		xlabel="d",
		ylabel="Average interventions per 120s",
		title="Post-shielding: Interference of the shield")
end)

# ╔═╡ Cell order:
# ╠═6f5f5e08-199f-41a1-b477-fbd537885fd6
# ╠═5a20bd30-e279-11ec-3f5e-ed9714dfcd32
# ╟─0299e856-d756-46fa-8a98-e9127daec70f
# ╟─7a2864d6-ff32-40d8-89ae-799366b79ac8
# ╟─e8653f6f-19df-40ba-9633-82726b6b57a8
# ╟─d13faa16-897a-4d01-9b14-ff6d03f4a592
# ╟─d4cac18b-1bf1-477d-84e1-ace714fc9967
# ╟─e0c5c3e6-7fbc-449a-96b2-aadd647728d9
# ╠═5dc4f261-5e46-4914-948b-0c45b9443a44
# ╠═bba93717-6370-417d-8b12-01d006623c6a
# ╠═7904c209-eeea-4243-beb4-0e5a7fd47a56
# ╠═e0444e2e-0e77-4e5a-ac1e-64db46f2558f
# ╠═6ec82ff0-6cf7-4733-9a5a-f97fdfc90af1
# ╠═10d9e5d7-6efc-4ef2-9123-bc477d0630c1
# ╠═df6cfb7b-3e0f-43ed-a4b5-25dfdc56c349
# ╟─d19884c3-a3c9-4df0-8220-7f1707cfe5ca
# ╠═439297f0-8945-43c8-9141-e04dac3e94ee
# ╟─119d6b3e-d8fb-4206-93b0-2e6dc848ac5e
# ╠═61bd91fc-6b0f-4fa5-a3dc-ea0f87c06cf1
