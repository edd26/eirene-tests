val, t, bytes, gctime, memallocs = @timed include("multiscale_matrix_testing.jl")
save("all_test_pt1.jld", "val",val, "t",t, "bytes",bytes, "gctime",gctime,
                                                        "memallocs",memallocs)


val, t, bytes, gctime, memallocs = @timed include("multiscale_matrix_testing_dimension.jl")
save("all_test_pt2.jld", "val",val, "t",t, "bytes",bytes, "gctime",gctime,
                                                        "memallocs",memallocs)

# ================================================================
loading = false
if loading

        using JLD

        result_path = "results/2020-01-27/"
        all_test_pt1 = load(result_path*"all_test_pt1_2020-01-27.jld")
        all_test_pt2 = load(result_path*"all_test_pt2_2020-01-27.jld")

        data_set = all_test_pt2

        used_gb = Int(floor(data_set["bytes"]/1e9))
        malloc_GB = Int(floor(data_set["memallocs"].malloc/1e6))
        used_hours = Int(floor(data_set["t"]/3600))
        used_minutes =  Int(floor((data_set["t"] - used_hours*3600)/60))
        used_sec =  Int(floor((data_set["t"] - used_hours*3600 - used_minutes*60)))


        println("======================================================================")
        println("Total memory used in testing random and geometric matrix: $(data_set["bytes"]) bytes")
        println("Which is: $(used_gb) GB")
        println("===")
        print("Peak memory used $(data_set["memallocs"].malloc)")
        println("Which is: $(malloc_GB) MB")
        println("===")
        println("Total time: $(data_set["t"]) second")
        println("Which is: $(used_hours) hours, $(used_minutes) minutes,  $(used_sec) seconds")
        println("===")
end
