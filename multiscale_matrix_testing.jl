
using Plots
# using DelimitedFiles
using JLD

loading = false
do_rand = true
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

debug = false
if debug
   ENV["JULIA_DEBUG"] = "all"
else
    ENV["JULIA_DEBUG"] = "none"
end

cd("../eirene-tests")

# ==============================================
# ============= matrix parameters ==============
sample_space_dims = 50
    maxsim = 2
    min_B_dim = 1
    max_B_dim = 3
    size_start = 5
    size_step = 5
    size_stop = 100

if loading
    load("multiscale_matrix_testing.jld")
else
    geom_mat_results, rand_mat_results =
                    multiscale_matrix_testing(sample_space_dims,maxsim,
                        min_B_dim,max_B_dim,size_start,size_step,size_stop)
end

# ==============================================================================
# ================= get the averages and stds ==========================
if plotting
    repetitions = size_start:size_step:size_stop
    num_of_bettis = length(collect(min_B_dim:max_B_dim))

    betti_avgs_rand = zeros(length(repetitions), num_of_bettis)
    betti_stds_rand = zeros(length(repetitions), num_of_bettis)
    betti_avgs_geom = zeros(length(repetitions), num_of_bettis)
    betti_stds_geom = zeros(length(repetitions), num_of_bettis)

    for k in 1:length(repetitions)
        if do_rand
            betti_avgs_rand[k,:] = rand_mat_results[k]["avg_cycles"]
            betti_stds_rand[k,:] = rand_mat_results[k]["std_cycles"]
        end

        betti_avgs_geom[k,:] = geom_mat_results[k]["avg_cycles"]
        betti_stds_geom[k,:] = geom_mat_results[k]["std_cycles"]
    end


# ==============================================================================
# ================================ Plot results ================================


    plot_ref = plot(title="Average number of cycles for random matrix",
                                                                    legend=:topleft);
        for betti = min_B_dim:max_B_dim
            plot!(repetitions, betti_avgs_rand[:,betti], ribbon=betti_stds_rand[:,betti],
                    fillalpha=.3, labels="\\beta_$(betti)", linestyle=:solid, color=:auto)
        end
        ylabel!("Number of cycles")
        xlabel!("Matrix size")


    plot_ref = plot(title="Average number of cycles for geometric matrix",
                                                                    legend=:topleft);
        for betti = min_B_dim:max_B_dim
            plot!(repetitions, betti_avgs_geom[:,betti], ribbon=betti_stds_geom[:,betti],
                    fillalpha=.3, labels="\\beta_$(betti)", linestyle=:solid, color=:auto)
        end
        ylabel!("Number of cycles")
        xlabel!("Matrix size")
end

# ==============================================================================
# ============================= Save dictionaries ==============================

save("multiscale_matrix_testing_night.jld", "rand_mat_results", rand_mat_results,
                                        "geom_mat_results", geom_mat_results)
