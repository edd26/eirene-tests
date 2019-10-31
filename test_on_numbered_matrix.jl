using Plots
 using MATLAB
 using Eirene
 using Random
 using Distances
 using DelimitedFiles
 mat"addpath('/home/ed19aaf/Programming/MATLAB/clique-top')"
 cd("/home/ed19aaf/Programming/Julia/eirene-tests")
 include("julia-functions/MatrixProcessing.jl")
 include("julia-functions/BettiCurves.jl")
 include("julia-functions/DirOperations.jl")

# ENV["JULIA_DEBUG"] = "all"
# Generated data
eirene_model = "vr";
eirene_maxdim = 3;

n_numbered_matrix="numbered_matrix";
 data_size = ["4", "10", "70"]
 result_path = "./results/"
 figure_path = "fig/"

data_path = "./data/"
 suffix = "_size"
 file_format = ".csv"

# euc_dist_mat_sphr_1 = readdlm(data_path*prefix*n_sphr_1*suffix*""*file_format,  ',', Float64, '\n')
for k=1:length(data_size)
        numbered_matrix = readdlm(data_path*n_numbered_matrix*suffix*data_size[k]*file_format,
                                                            ',', Float64, '\n')

        res_eirene_numbered_matrix = eirene(numbered_matrix,
                                maxdim=eirene_maxdim, model=eirene_model)

        plot_and_save_bettis(res_eirene_numbered_matrix, n_numbered_matrix,
                         data_size[k], result_path*figure_path, do_save=false)
end
