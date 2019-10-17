using Plots
 using MATLAB
 using Eirene
 using Random
 using Distances
 using DelimitedFiles
 mat"addpath('/home/ed19aaf/Programming/MATLAB/clique-top')"
 cd("/home/ed19aaf/Programming/Julia/eirene-tests")


 """
 Plot Betti curves from 0 up to 3 using results from Eirene library and returns
 handler for figure. Optionally, save the figure
 """
function plot_and_save_bettis(eirene_results, plot_title,
                                data_size, results_path;
                                do_save=false, do_normalise=true)

     betti_0 = betticurve(eirene_results, dim=0)
     betti_1 = betticurve(eirene_results, dim=1)
     betti_2 = betticurve(eirene_results, dim=2)
     betti_3 = betticurve(eirene_results, dim=3)

     if do_normalise
             betti_0[:,1] /= findmax(betti_0[:,1])[1]
             betti_1[:,1] /= findmax(betti_1[:,1])[1]
             betti_2[:,1] /= findmax(betti_2[:,1])[1]
             betti_3[:,1] /= findmax(betti_3[:,1])[1]
     end

     cur_colors = get_color_palette(:auto, plot_color(:white), 17)

     final_title = "Eirene betti curves, "*plot_title*" data, size "*data_size
     p1 = plot(betti_0[:,1], betti_0[:,2], label="\\beta_0", lc=cur_colors[7],
                                                        title=final_title);
     plot!(betti_1[:,1], betti_1[:,2], label="\\beta_1", lc=cur_colors[5]);
     plot!(betti_2[:,1], betti_2[:,2], label="\\beta_2", lc=[:red]);
     plot!(betti_3[:,1], betti_3[:,2], label="\\beta_3", lc=cur_colors[1]);


     plot_ref = plot(p1)
     ylabel!("Number of cycles")

     if do_save
         current_path = pwd()
         cd(results_path)
         savefig(plot_ref, "betti_curves_"*plot_title*data_size*".png")
         cd(current_path)
     end

 end

# Generated data
eirene_model = "vr";
eirene_maxdim = 3;

n_numbered_matrix="numbered_matrix";
 data_size = ["4", "10", "70"]
 result_path = "./results/"
 figure_path = "figures/"

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
                         data_size[k], result_path*figure_path, do_save=true)
end
