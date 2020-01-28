using Plots
using JLD

loading = false
plotting = false

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
   ENV["JULIA_DEBUG"] = "BettiCurves"
else
    ENV["JULIA_DEBUG"] = "none"
end

cd("../eirene-tests")

# ==============================================
# ============= matrix parameters ==============
dims = collect(5:5:105)
    repetitions = 100
    min_B_dim = 1
    max_B_dim = 3
    size_start = 10
    size_step = 5
    size_stop = 110

if loading
    dict = load(result_path*"multiscale_matrix_testing_2020-01-27.jld")
    geom_mat_results = dict["geom_mat_results"]
else
    geom_mat_results = multiscale_matrix_testing(dims,repetitions,min_B_dim,
                                    max_B_dim, size_start,size_step,size_stop;
                                        control_saving=true,
                                         perform_eavl=true)
end

# ==============================================================================
# ================= get the averages and stds ==========================
if plotting

    repetitions = size_start:size_step:size_stop
    num_of_repetitions = length(repetitions)
    num_of_bettis = length(collect(min_B_dim:max_B_dim))
    num_of_dims = length(dims)

    betti_avgs_geom = zeros(num_of_repetitions, num_of_bettis, num_of_dims)
    betti_stds_geom = zeros(num_of_repetitions, num_of_bettis, num_of_dims)

    iter = 1
    for d in 1:num_of_dims
        global iter
        for k in 1:length(collect(repetitions))
            betti_avgs_geom[k,:,d] = geom_mat_results[iter]["avg_cycles"]
            betti_stds_geom[k,:,d] = geom_mat_results[iter]["std_cycles"]
            iter+=1
            @info iter
        end
    end

# ==============================================================================
# ================================ Plot results ================================

    function get_surface_val(x,y)
        global betti_avgs_geom, repetitions, dims
        position_size = findall(a -> a==x, repetitions)[1]
        position_dim = findall(a -> a==y, dims)[1]

        return betti_avgs_geom[position_size,betti,position_dim]
    end

    plotlyjs()

    betti=1
     plot(repetitions,dims,get_surface_val,st = [:wireframe, :surface],
                                            camera=(-40,20),
                                             color=:lightrainbow)
        xlabel!("Matrix size")
        ylabel!("Sampling space dimension")

    betti=2
     plot!(repetitions,dims,get_surface_val, st = [:wireframe, :surface],
                                            camera=(-40,20), color=:rainbow)
        xlabel!("Matrix size")
        ylabel!("Sampling space dimension")

    betti=3
     plot!(repetitions,dims,get_surface_val, st = [:wireframe, :surface],
                                                    camera=(-40,20),
                                                     color=:darkrainbow)
        xlabel!("Matrix size")
        ylabel!("Sampling space dimension")
end

# ==============================================================================
# ============================= Save dictionaries ==============================

save("multiscale_matrix_testing_dimension_2020-01-24.jld", "geom_mat_results",
                                                        geom_mat_results[:])




# === ==== === ==
