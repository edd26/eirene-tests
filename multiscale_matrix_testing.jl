"""
Script for testing the average number of cycles from geometric and random
    matrices.
"""
using Plots
using DelimitedFiles



#
julia_func_path = "../julia-functions/"
    include(julia_func_path*"GeometricSampling.jl");
    include(julia_func_path*"MatrixToolbox.jl")
    include(julia_func_path*"MatrixProcessing.jl")
    include(julia_func_path*"BettiCurves.jl")
    include(julia_func_path*"ImageProcessing.jl")
    include(julia_func_path*"PlottingWrappers.jl")

result_path = "results/"
figure_path = result_path*"fig/"

debug = true
if debug
   ENV["JULIA_DEBUG"] = "none"
end

cd("../eirene-tests")

# select plotting backend
# plotlyjs()

# ==============================================
# ============= matrix parameters ==============
maxsim=10;

sample_space_dim = 3

min_B_dim = 1
max_B_dim = 3

geom_mat_results = Any[]
rand_mat_results = Any[]
result_list = [geom_mat_results, rand_mat_results]


for space_samples = 10:10:60
    println("Generating data")
    # ==========================================
    # ============= Generate data ==============
    # ===
    # Generate random matrix
    symm_mat_rand = [generate_random_matrix(space_samples) for i=1:maxsim]

    # ===
    # Generate geometric matrix
    pts_rand = [generate_random_point_cloud(sample_space_dim,space_samples) for i=1:maxsim]

    # compute distances
    symm_mat_geom = [generate_geometric_matrix(pts_rand[i]') for i=1:maxsim]

    # ==========================================
    # ======= Generate ordering matrix =========
    ordered_mat_geom = [get_ordered_matrix(symm_mat_geom[i]) for i=1:maxsim]
    ordered_mat_rand = [get_ordered_matrix(symm_mat_rand[i]) for i=1:maxsim]

    # ==============================================================================
    # ========================= Do the Betti analysis ============================
    for matrix_set in [ordered_mat_geom, ordered_mat_rand]
        println("Betti analysis!")
        # ===
        # Generate bettis
        many_bettis = Array[]
        for i=1:maxsim
            println("\tComputing bettis")
            push!(many_bettis,bettis_eirene(matrix_set[i], max_B_dim,
                                                                mindim=min_B_dim))
        end

        # ===
        # Get maximal number of cycles from each Betti from simulations
        max_cycles = zeros(maxsim, max_B_dim)
        for i=1:maxsim,  betti_dim = 1:max_B_dim
            println("\tFindmax in bettis")
            max_cycles[i, betti_dim] = findmax(many_bettis[i][:, betti_dim])[1]
        end

        # ===
        # Get the statistics
        avg_cycles = mean([max_cycles[betti_dim, :] for betti_dim=1:max_B_dim])
        std_cycles = std([max_cycles[betti_dim, :] for betti_dim=1:max_B_dim])

        # ===
        # Put results into dictionary
        betti_statistics = Dict()
        if matrix_set == ordered_mat_geom
            println("Saving ordered")
            betti_statistics["matrix_type"] = "ordered"
            betti_statistics["space_dim"] = sample_space_dim
            result_list = geom_mat_results
        else
            println("Saving radom")
            betti_statistics["matrix_type"] = "random"
            result_list = rand_mat_results
        end
        betti_statistics["space_samples"] = space_samples
        betti_statistics["simualtions"] = maxsim
        betti_statistics["min_betti_dim"] = min_B_dim
        betti_statistics["max_betti_dim"] = max_B_dim
        betti_statistics["avg_cycles"] = avg_cycles
        betti_statistics["std_cycles"] = std_cycles

        push!(result_list, betti_statistics)
    end # matrix type loop
    println("===============")
end # matrix_size_loop






# ==============================================================================
# ================================ Plot results ================================
# plot_title = ""
#
# figure_name = "betti_"*type_1*"_d$(d)_n$(space_samples)"
# C_geom = eirene(ordered_mat_geom[data_used],maxdim=3,model="vr")
# ref = plot_and_save_bettis(C_geom, plot_title, figure_path; file_name=figure_name,
#                                 do_save=true, extend_title=false,
#                                 do_normalise=false, max_dim=3,legend_on=false,
#                                 min_dim=1)
#
#
# figure_name = "betti_"*type_2*"_d$(d)_n$(space_samples)"
# C_rand = eirene(ordered_mat_rand[data_used],maxdim=3,model="vr")
# ref = plot_and_save_bettis(C_rand, plot_title, figure_path; file_name=figure_name,
#                                 do_save=true, extend_title=false,
#                                 do_normalise=false, max_dim=3,legend_on=false,
#                                 min_dim=1)
