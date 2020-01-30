using Eirene
 	using DelimitedFiles
 	using Plots
    using LinearAlgebra
    using Images
    using Distances
    using Images
    using JLD

 cd("../image-topology/")
    julia_func_path = "../julia-functions/"
    include(julia_func_path*"GeometricSampling.jl");
    include(julia_func_path*"MatrixToolbox.jl")
    include(julia_func_path*"MatrixProcessing.jl")
    include(julia_func_path*"BettiCurves.jl")
    include(julia_func_path*"ImageProcessing.jl")
    include(julia_func_path*"PlottingWrappers.jl")

debug = true

 if debug
    ENV["JULIA_DEBUG"] = "all"
 end

# ==============================================================================
# =============================== Set parameters ===============================

result_path = "results/"
    gabor_path = result_path*"gabor/"
    figure_path = result_path*"figures/"
	rank_betti_path = result_path*"rank_betti/"
    heatmaps_path = figure_path*"heatmaps/"

    img_path = "img/"
    simple_matrix_path = img_path*"simple_matrix/"
    compositions = simple_matrix_path*"composition/"

    plot_heatmaps = true
    save_heatmaps = false

    save_figures =  true
    plot_betti_figrues = true

    # Image processing parameters
    max_size_limiter =   200
    sub_img_size = 31


	function get_bettis_analysis(matrix, mat_type::String, targets::Int,
		 									sources::Int; save_figures=false)
		mat_size = size(matrix,1)
		eirene_geom = eirene(matrix,maxdim=3,model="vr")
	    bett_geom = get_bettis(eirene_geom, max_B_dim);

	    plot_title1 = "$(mat_type)_trg=$(targets)_src=$(sources)_steps=$(size(bett_geom[1],1))"
		plot_geom = plot_bettis2(bett_geom, plot_title1, legend_on=true,
	                                min_dim=1)
		xlabel!("Steps")

	    if save_figures
			extension = ".png"
			file_name1 = replace(plot_title1, ","=>"_")*extension

	        savefig(plot_geom, rank_betti_path*file_name1)
	        @info "Saved file."
	    end
		# display(plot_geom)
		return plot_geom
	end


# ==============================================================================
# ============================== Repeated points ===============================
# ===
# Generate geometric matrix
min_B_dim = 1
	max_B_dim = 3
	sample_space_dim = 201
	maxsim = 1
	mat_size = 81

	# set_sources = [1, 2]
	set_sources = [1, 2, 5, 15]
	set_targets = [2, 5, 15, 30]
	# set_targets = [2, 30]

	pts_rand = generate_random_point_cloud(sample_space_dim,mat_size)
	copy_pts_rand = copy(pts_rand)


for num_sources = set_sources, num_targets in set_targets

	source_points = rand(collect(1:size(pts_rand,1)), 1, num_sources)
	target_points = rand(collect(1:size(pts_rand,1)), 1, num_targets)

	for source_point in source_points
		for target in target_points
			pts_rand[target,:] = copy_pts_rand[source_point,:]
		end
	end

	symm_mat_geom_orig = generate_geometric_matrix(copy_pts_rand')
	ordered_geom_orig = get_ordered_matrix(symm_mat_geom_orig; assing_same_values=false)
	ordered_geom_gr_orig = get_ordered_matrix(symm_mat_geom_orig; assing_same_values=true)

	symm_mat_geom = generate_geometric_matrix(pts_rand')
	ordered_geom = get_ordered_matrix(symm_mat_geom; assing_same_values=false)
	ordered_geom_gr = get_ordered_matrix(symm_mat_geom; assing_same_values=true)


	if plot_heatmaps
		heat_map_orig = plot_square_heatmap(ordered_geom_gr_orig, 10,size(ordered_geom,1);
			plt_title = "Ordered original matrix")
		plot!( yflip = true,)

		heat_map_ord = plot_square_heatmap(ordered_geom, 10,size(ordered_geom,1);
			plt_title = "Ordered matrix, no grouping, trgt:$(num_targets), src:$(num_sources)")
		plot!( yflip = true,)

		heat_map_ord_gr = plot_square_heatmap(ordered_geom_gr, 10,size(ordered_geom_gr,1);
			plt_title = "Ordered matrix matrix, grouping, trgt:$(num_targets), src:$(num_sources)")
		plot!( yflip = true,)

		plt_hall = plot(heat_map_orig, heat_map_ord, heat_map_ord_gr,layout = 3);

	    if save_heatmaps
	        heatm_details = "$(mat_size)"
			savefig(heat_map1, rank_betti_path*"ordering_geom"*heatm_details)
			savefig(heat_map2, rank_betti_path*"ordering_rand"*heatm_details)
			@info "Saved files in " rank_betti_path
	    end
		# display(heat_map_orig)
		# display(heat_map_ord)
		# display(heat_map_ord_gr)
		display(plt_hall)
	end

	plt0 = get_bettis_analysis(ordered_geom_orig, "orig", num_targets, num_sources);
	plt1 = get_bettis_analysis(ordered_geom_gr_orig, "gr_orig", num_targets, num_sources);
	plt2 = get_bettis_analysis(ordered_geom, "no_gr", num_targets, num_sources);
	plt3 = get_bettis_analysis(ordered_geom_gr, "gr", num_targets, num_sources);

	plot(title="Comparison, target_points = $(num_targets), sources = $(num_sources)");
	plt_oall = plot(plt0, plt1, plt2, plt3, layout = 4);

	display(plt_oall)
end

# Observations:
# some of those ordering matrices are simillar to those obtained from images
# the betti curves are not simillar to those from images- they are shifted and
# not as low as for images


# ===============================================
# ======= sequential adding of random points

set_sources = [1, 2, 5, 15]
set_targets = [2, 5, 15, 30]

num_sources = set_sources[1]

num_targets = 50
target_sets = 10
target_batches = Int(ceil(num_targets/target_sets))

pts_rand = generate_random_point_cloud(sample_space_dim,mat_size)
copy_pts_rand = copy(pts_rand)

source_points = rand(collect(1:size(pts_rand,1)), 1, num_sources)
target_points = rand(collect(1:size(pts_rand,1)), target_batches, target_sets)
source_point = source_points[1]


set_of_plots = Any[]
 pts_rand = copy(copy_pts_rand)
 set_of_h_maps = Any[]
 for row = 1:target_batches

	for a_point in target_points[row, :]
		pts_rand[a_point,:] = copy_pts_rand[source_point,:]
	end
   # symm_mat_geom_orig = generate_geometric_matrix(copy_pts_rand')
   # ordered_geom_orig = get_ordered_matrix(symm_mat_geom_orig; assing_same_values=false)
   # ordered_geom_gr_orig = get_ordered_matrix(symm_mat_geom_orig; assing_same_values=true)

   symm_mat_geom = generate_geometric_matrix(pts_rand')
   # ordered_geom = get_ordered_matrix(symm_mat_geom; assing_same_values=false)
   ordered_geom_gr = get_ordered_matrix(symm_mat_geom; assing_same_values=true)


   heat_map_ord_gr = plot_square_heatmap(ordered_geom_gr, 10,size(ordered_geom_gr,1);
	   plt_title = "Ordered matrix matrix, grouping, trgt:$(num_targets), src:$(num_sources)")
   plot!( yflip = true, legend=:none)

   # plt0 = get_bettis_analysis(ordered_geom_orig, "orig", num_targets, num_sources);
   # plt1 = get_bettis_analysis(ordered_geom_gr_orig, "gr_orig", num_targets, num_sources);
   # plt2 = get_bettis_analysis(ordered_geom, "no_gr", num_targets, num_sources);

   plt3 = get_bettis_analysis(ordered_geom_gr, "gr", row, num_sources);
   plot!(legend=false, title=false)

   push!(set_of_plots, plt3)
   push!(set_of_h_maps, heat_map_ord_gr)
 end


plt_all = plot(set_of_plots[1], set_of_plots[2],
				set_of_plots[3], set_of_plots[4],
				set_of_plots[5], layout=(5))

plt_allh = plot(set_of_h_maps[1], set_of_h_maps[2],
				set_of_h_maps[3], set_of_h_maps[4],
				set_of_h_maps[5],layout=(5))
