using Plots
# using DelimitedFiles
using JLD

loading = true
 do_rand = true
 plotting = true
 #
 julia_func_path = "../julia-functions/"
    include(julia_func_path*"GeometricSampling.jl");
    include(julia_func_path*"MatrixToolbox.jl")
    include(julia_func_path*"MatrixProcessing.jl")
    include(julia_func_path*"BettiCurves.jl")
    include(julia_func_path*"ImageProcessing.jl")
    include(julia_func_path*"PlottingWrappers.jl")

 result_path = "results/2020-01-27/"
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
    maxsim = 100
    min_B_dim = 1
    max_B_dim = 3
    size_start = 10
    size_step = 5
    size_stop = 100

if loading
    dict = load(result_path*"multiscale_matrix_testing_2020-01-27.jld")
    geom_mat_results = dict["geom_mat_results"]
    rand_mat_results = dict["rand_mat_results"]
else
    geom_mat_results, rand_mat_results =
                    multiscale_matrix_testing(sample_space_dims,maxsim,
                        min_B_dim,max_B_dim,size_start,size_step,size_stop;
                            control_saving=true, perform_eavl=true)
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


    plot_rand = plot(title="Average number of cycles for random matrix",
                                                                    legend=:left);
        for betti = min_B_dim:max_B_dim
            plot!(repetitions, betti_avgs_rand[:,betti], ribbon=betti_stds_rand[:,betti],
                    fillalpha=.3, labels="\\beta_$(betti)", linestyle=:solid, color=:auto)
        end
        ylabel!("Number of cycles")
        xlabel!("Matrix size")

        plot!(inset = (1, bbox(0.05,0.05,0.5,0.25,:top,:left)), subplot=1)
        st_plt = 3
        end_plt = Int(floor((length(repetitions))/2))+2
        for bet = min_B_dim:max_B_dim
            plot!(repetitions[st_plt:end_plt,1], betti_avgs_rand[st_plt:end_plt,bet],
                    ribbon=betti_stds_rand[st_plt:end_plt,bet], fillalpha=.3,
                     legend=false, subplot=2, tick_direction=:in)
        end



        # histogram!(randn(1000),
        #             inset = (1, bbox(0.05,0.05,0.5,0.25,:bottom,:right)), ticks=nothing, subplot=3, bg_inside=nothing)


    plot_geom = plot(title="Average number of cycles for geometric matrix",
                                                                    legend=:topleft);
        for betti = min_B_dim:max_B_dim
            plot!(repetitions, betti_avgs_geom[:,betti], ribbon=betti_stds_geom[:,betti],
                    fillalpha=.3, labels="\\beta_$(betti)", linestyle=:solid, color=:auto)
        end
        ylabel!("Number of cycles")
        xlabel!("Matrix size")

    plot_all = plot(title="Comparison of average number of cycles for random and geometric matrix",
                                                                    legend=:topleft);
        for betti = min_B_dim:max_B_dim
            plot!(repetitions, betti_avgs_rand[:,betti], ribbon=betti_stds_rand[:,betti],
                    fillalpha=.3, labels="\\beta_{$(betti)} random", linestyle=:solid, color=:auto)
        end

        for betti = min_B_dim:max_B_dim
            plot!(repetitions, betti_avgs_geom[:,betti], ribbon=betti_stds_geom[:,betti],
                    fillalpha=.3, labels="\\beta_{$(betti)} geometric", linestyle=:solid, color=:auto)
        end
        ylabel!("Number of cycles")
        xlabel!("Matrix size")

    display(plot_rand)
    display(plot_geom)
    display(plot_all)
end

# # ==============================================================================
# # ============================= Save dictionaries ==============================
#
# save("multiscale_matrix_testing_2020-01-24.jld", "rand_mat_results", rand_mat_results,
#                                         "geom_mat_results", geom_mat_results)
