using Eirene
 	using DelimitedFiles
 	using Plots
    using LinearAlgebra
    using Images
    using Distances
    using Images
    using JLD

 cd("../image-topology/")
    julia_func_path = "./julia-functions/"
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

    save_gabor_param = false
    plt_filters = false
    save_filters = false

    plot_heatmaps = true
    save_heatmaps = false

    do_eirene =     true
    save_figures =  true
    plot_betti_figrues = true

    do_local_corr = false
    do_local_gabor = true
    do_local_grad = false


    # Image processing parameters
    shift =          1
    max_size_limiter =   200

    patch_params = Dict("x"=>1, "y"=>1, "spread" =>1)
    sub_img_size = 31

# ==============================================================================
# ====================== Random and geometric matrix rank ======================
min_B_dim = 1
	max_B_dim = 3
	sample_space_dim = 201
	maxsim = 1
	mat_size = 81

# ==========================================
# ============= Generate data ==============
# ===

rank_mat = [0, 0]
# Generate random matrix
symm_mat_rand = generate_random_matrix(mat_size)
ordered_mat_rand = get_ordered_matrix(symm_mat_rand)
rank_mat[1] = rank(ordered_mat_rand)

# ===
# Generate geometric matrix
pts_rand = generate_random_point_cloud(sample_space_dim,mat_size)
symm_mat_geom = generate_geometric_matrix(pts_rand')
ordered_mat_geom = get_ordered_matrix(symm_mat_geom; assing_same_values=false)
rank_mat[2] = rank(ordered_mat_geom)
# ======================================================================
# ========================= Do the Betti analysis ======================
# ===
# Generate bettis


if plot_betti_figrues && do_eirene
	eirene_geom = eirene(ordered_mat_geom,maxdim=3,model="vr")
    bett_geom = get_bettis(eirene_geom, max_B_dim);

	eirene_rand= eirene(ordered_mat_rand,maxdim=3,model="vr")
	bett_rand = get_bettis(eirene_rand, max_B_dim);


    plot_title1 = "geometric,mat_size=$(mat_size),"*
                    "rank=$(rank_mat[1]),steps=$(size(bett_geom[1],1))"
	plot_geom = plot_bettis2(bett_geom, plot_title1, legend_on=true,
                                min_dim=1)
	xlabel!("Steps")

	plot_title2 = "random,mat_size=$(mat_size),"*
                    "rank=$(rank_mat[2]),steps=$(size(bett_rand[1],1))"
	plot_rand = plot_bettis2(bett_rand, plot_title2, legend_on=true,
                                min_dim=1)
	xlabel!("Steps")

    if save_figures
		extension = ".png"
		file_name1 = replace(plot_title1, ","=>"_")*extension
		file_name2 = replace(plot_title2, ","=>"_")*extension

        savefig(plot_geom, rank_betti_path*file_name1)
        savefig(plot_rand, rank_betti_path*file_name2)
        @info "Saved files in " rank_betti_path
    end
end

# ==============================================================================
# ================================ Plot results ================================

if plot_heatmaps
	heat_map1 = plot_square_heatmap(ordered_mat_geom, 10,size(ordered_mat_geom,1);
		plt_title = "Order matrix of geom. matrix, size:$(mat_size)")
	plot!( yflip = true,)

	heat_map2 = plot_square_heatmap(ordered_mat_rand, 10,size(ordered_mat_rand,1);
		plt_title = "Order matrix of rand. matrix, size:$(mat_size)")
	plot!( yflip = true,)

    if save_heatmaps
        heatm_details = "$(mat_size)"
		savefig(heat_map1, rank_betti_path*"ordering_geom"*heatm_details)
		savefig(heat_map2, rank_betti_path*"ordering_rand"*heatm_details)
		@info "Saved files in " rank_betti_path
    end
end

# ==============================================================================
# ============================== Repeated points ===============================
# ===
# Generate geometric matrix
number_of_targets = 25

	pts_rand = generate_random_point_cloud(sample_space_dim,mat_size)
	copy_pts_rand = copy(pts_rand)

	source_point = rand(collect(1:size(pts_rand,1)))
	target_points = rand(collect(1:size(pts_rand,1)), 1, number_of_targets)

	for target in target_points
		pts_rand[target,:] = pts_rand[source_point,:]
	end

	symm_mat_geom_orig = generate_geometric_matrix(copy_pts_rand')
	ordered_geom_gr_orig = get_ordered_matrix(symm_mat_geom_orig; assing_same_values=true)

	symm_mat_geom = generate_geometric_matrix(pts_rand')
	ordered_geom = get_ordered_matrix(symm_mat_geom; assing_same_values=false)
	ordered_geom_gr = get_ordered_matrix(symm_mat_geom; assing_same_values=true)

	rank_mat[2] = rank(ordered_geom)
	rank_mat[2] = rank(ordered_geom_gr)


if plot_heatmaps
	heat_map_orig = plot_square_heatmap(ordered_geom_gr_orig, 10,size(ordered_geom,1);
		plt_title = "Ordered original matrix, size:$(mat_size)")
	plot!( yflip = true,)

	heat_map_ord = plot_square_heatmap(ordered_geom, 10,size(ordered_geom,1);
		plt_title = "Ordered matrix, no grouping, size:$(mat_size)")
	plot!( yflip = true,)

	heat_map_ord_gr = plot_square_heatmap(ordered_geom_gr, 10,size(ordered_geom_gr,1);
		plt_title = "Ordered matrix matrix, grouping, size:$(mat_size)")
	plot!( yflip = true,)

    if save_heatmaps
        heatm_details = "$(mat_size)"
		savefig(heat_map1, rank_betti_path*"ordering_geom"*heatm_details)
		savefig(heat_map2, rank_betti_path*"ordering_rand"*heatm_details)
		@info "Saved files in " rank_betti_path
    end
	display(heat_map_orig)
	display(heat_map_ord)
	display(heat_map_ord_gr)
end


function get_bettis_analysis(matrix, mat_type::String; save_figures=false)
	mat_size = size(matrix,1)
	eirene_geom = eirene(ordered_mat_geom,maxdim=3,model="vr")
    bett_geom = get_bettis(eirene_geom, max_B_dim);

    plot_title1 = "$(mat_type)_size=$(mat_size)_steps=$(size(bett_geom[1],1))"
	plot_geom = plot_bettis2(bett_geom, plot_title1, legend_on=true,
                                min_dim=1)
	xlabel!("Steps")

    if save_figures
		extension = ".png"
		file_name1 = replace(plot_title1, ","=>"_")*extension

        savefig(plot_geom, rank_betti_path*file_name1)
        @info "Saved file."
    end
end

get_bettis_analysis(ordered_geom_gr_orig, "ordered_geom_gr_orig")
get_bettis_analysis(ordered_geom, "ordered_geom")
get_bettis_analysis(ordered_geom_gr, "ordered_geom_gr")
