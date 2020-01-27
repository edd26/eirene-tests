val, t, bytes, gctime, memallocs = @timed include("multiscale_matrix_testing.jl")
save("all_test_pt1.jld", "val",val, "t",t, "bytes",bytes, "gctime",gctime,
                                                        "memallocs",memallocs)


val, t, bytes, gctime, memallocs = @timed include("multiscale_matrix_testing_dimension.jl")
save("all_test_pt2.jld", "val",val, "t",t, "bytes",bytes, "gctime",gctime,
                                                        "memallocs",memallocs)
