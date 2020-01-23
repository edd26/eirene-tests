
using Plots
using DelimitedFiles
using JLD

loading = false
do_rand = false
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


if loading
    load("multiscale_matrix_testing_rand_and_geom_10-5-80.jld")
else
    if do_rand
        geom_mat_results, rand_mat_results = multiscale_matrix_testing(3,2,1,3,
                                                                        10,5,50)
    else
        geom_mat_results = multiscale_matrix_testing([3 5 10],2,1,3,10,5,50;
                                                            do_random=do_rand)
    end
end

# ==============================================================================
# ================= get the averages and stds ==========================


betti_avgs_rand = zeros(length(repetitions), num_of_bettis)
betti_stds_rand = zeros(length(repetitions), num_of_bettis)
betti_avgs_geom = zeros(length(repetitions), num_of_bettis)
betti_stds_geom = zeros(length(repetitions), num_of_bettis)

for k in 1:length(repetitions)
    betti_avgs_rand[k,:] = rand_mat_results[k]["avg_cycles"]
    betti_stds_rand[k,:] = rand_mat_results[k]["std_cycles"]

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


# ==============================================================================
# ============================= Save dictionaries ==============================

save("multiscale_matrix_testing.jld", "rand_mat_results", rand_mat_results,
                                        "geom_mat_results", geom_mat_results)
