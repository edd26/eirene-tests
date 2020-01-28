using Plots
# using DelimitedFiles
using JLD

loading = false
 do_rand = true
 plotting = false
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
    maxsim = 100
    min_B_dim = 1
    max_B_dim = 3
    size_start = 60
    size_step = 5
    size_stop = 60

if loading
    dict = load("multiscale_matrix_testing_night.jld")
    geom_mat_results = dict["geom_mat_results"]
    rand_mat_results = dict["rand_mat_results"]
else
geom_mat_results = Any[]
rand_mat_results = Any[]
result_list = [geom_mat_results, rand_mat_results]

sample_space_dim = sample_space_dims
repetitions = size_start:size_step:size_stop
for space_samples = repetitions
    # ==========================================
    # ============= Generate data ==============
    # ===
    # Generate random matrix
	symm_mat_rand = [generate_random_matrix(space_samples) for i=1:maxsim]
    ordered_mat_rand = [get_ordered_matrix(symm_mat_rand[i];
						assing_same_values=false) for i=1:maxsim]

    rank(ordered_mat_rand[3])

    # ===
    # Generate geometric matrix
    pts_rand = [generate_random_point_cloud(sample_space_dim,space_samples) for i=1:maxsim]
    symm_mat_geom = [generate_geometric_matrix(pts_rand[i]') for i=1:maxsim]
	ordered_ranks = zeros(maxsim)
    ordered_mat_geom = [get_ordered_matrix(symm_mat_geom[i];
							assing_same_values=true) for i=1:maxsim]

	rank(symm_mat_geom[5])
	rank(ordered_mat_geom[5])
    # ======================================================================
    # ========================= Do the Betti analysis ======================
    if do_random
        set = [ordered_mat_geom, ordered_mat_rand]
    else
        set = [ordered_mat_geom]
    end
    for matrix_set in set
        @debug("Betti analysis!")
        # ===
        # Generate bettis
		many_bettis = Array[]
		if perform_eavl
			many_timings = Float64[]
			many_bytes = Float64[]
			many_gctime = Float64[]
			many_memallocs = Base.GC_Diff[]
		end

        for i=1:maxsim
			if i%10 == 0
            	@info "Computing Bettis for: " i
			end
			push!(many_bettis, bettis_eirene(matrix_set[i],
									max_B_dim, mindim=min_B_dim))
        end

        # ===
        # Get maximal number of cycles from each Betti from simulations
        max_cycles = zeros(maxsim, max_B_dim)
        for i=1:maxsim,  betti_dim = 1:max_B_dim
            @debug("\tFindmax in bettis")
            max_cycles[i, betti_dim] = findmax(many_bettis[i][:, betti_dim])[1]
        end

        # ===
        # Get the statistics
        avg_cycles = zeros(1, length(min_B_dim:max_B_dim))
        std_cycles = zeros(1, length(min_B_dim:max_B_dim))
        k=1
        for betti_dim=min_B_dim:max_B_dim
            avg_cycles[k] = mean(max_cycles[:, betti_dim])
            std_cycles[k] = std(max_cycles[:, betti_dim])
            k+=1
        end

        # ===
        # Put results into dictionary
        betti_statistics = Dict()
        if matrix_set == ordered_mat_geom
            @debug("Saving ordered")
            betti_statistics["matrix_type"] = "ordered"
            betti_statistics["space_dim"] = sample_space_dim
            result_list = geom_mat_results
        else
            @debug("Saving radom")
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
    @debug("===============")
end # matrix_size_loop
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
end

# ==============================================================================
# ============================= Save dictionaries ==============================

save("multiscale_matrix_testing_2020-01-24.jld", "rand_mat_results", rand_mat_results,
                                        "geom_mat_results", geom_mat_results)
