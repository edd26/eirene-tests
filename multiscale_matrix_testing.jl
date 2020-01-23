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


cd("../eirene-tests")

# select plotting backend
# plotlyjs()

# ==============================================
# ============= matrix parameters ==============
maxsim=3;
sample_ponits=30;
dims = 3

# ==========================================
# ============= Generate data ==============
# ===
# Generate random matrix
symm_mat_rand = [generate_random_matrix(sample_ponits) for i=1:maxsim]

# ===
# Generate geometric matrix
# sample points
pts_rand = [generate_random_point_cloud(dims,sample_ponits) for i=1:maxsim]

# compute distances
symm_mat_geom = [generate_geometric_matrix(pts_rand[i]') for i=1:maxsim]


# ==========================================
# ======= Generate ordering matrix =========
ordered_mat_geom = [get_ordered_matrix(symm_mat_geom[i]) for i=1:maxsim]
ordered_mat_rand = [get_ordered_matrix(symm_mat_rand[i]) for i=1:maxsim]



# ==============================================================================
# ========================= Do the Betti statistics ============================



# ==============================================================================
# ================================ Plot results ================================
# plot_title = ""
#
# figure_name = "betti_"*type_1*"_d$(d)_n$(sample_ponits)"
# C_geom = eirene(ordered_mat_geom[data_used],maxdim=3,model="vr")
# ref = plot_and_save_bettis(C_geom, plot_title, figure_path; file_name=figure_name,
#                                 do_save=true, extend_title=false,
#                                 do_normalise=false, max_dim=3,legend_on=false,
#                                 min_dim=1)
#
#
# figure_name = "betti_"*type_2*"_d$(d)_n$(sample_ponits)"
# C_rand = eirene(ordered_mat_rand[data_used],maxdim=3,model="vr")
# ref = plot_and_save_bettis(C_rand, plot_title, figure_path; file_name=figure_name,
#                                 do_save=true, extend_title=false,
#                                 do_normalise=false, max_dim=3,legend_on=false,
#                                 min_dim=1)
