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
function plot_and_save_bettis(eirene_results, plot_title; do_save=false,
                     save_path = "/home/ed19aaf/Programming/Julia/eirene-tests/results")
     betti_0 = betticurve(eirene_results, dim=0)
     betti_1 = betticurve(eirene_results, dim=1)
     betti_2 = betticurve(eirene_results, dim=2)
     betti_3 = betticurve(eirene_results, dim=3)

     p1 = plot(betti_0[:,1], betti_0[:,2], label="beta_0", title=plot_title);
     plot!(betti_1[:,1], betti_1[:,2], label="beta_1");
     plot!(betti_2[:,1], betti_2[:,2], label="beta_2");
     plot!(betti_3[:,1], betti_3[:,2], label="beta_3");

     plot_ref = plot(p1)

     if do_save
         cd(save_path)
         savefig(plot_ref, "betti_curves_"*plot_title*".png")
     end

 end

# Generated data
eirene_model = "vr";
eirene_maxdim = 3;

n_sphr_1="sphr_1";
 n_sphr_s="sphr_s";
 n_sphr_r="sphr_r";
 n_ball="ball";
 n_cylin="cylinder";
 n_plane="plane";

 sphr_size = "70"
 data_size = "70"

data_path = "./data/"
 prefix = "euc_dist_mat_"
 suffix = "_size"
 file_format = ".csv"

# euc_dist_mat_sphr_1 = readdlm(data_path*prefix*n_sphr_1*suffix*""*file_format,  ',', Float64, '\n')
euc_dist_mat_sphr_s = readdlm(data_path*prefix*n_sphr_s*suffix*sphr_size*file_format,  ',', Float64, '\n')
 euc_dist_mat_sphr_r = readdlm(data_path*prefix*n_sphr_r*suffix*sphr_size*file_format,  ',', Float64, '\n')
 euc_dist_mat_ball = readdlm(data_path*prefix*n_ball*suffix*data_size*file_format,  ',', Float64, '\n')
 euc_dist_mat_cylinder = readdlm(data_path*prefix*n_cylin*suffix*data_size*file_format,  ',', Float64, '\n')
 euc_dist_mat_plane = readdlm(data_path*prefix*n_plane*suffix*data_size*file_format,  ',', Float64, '\n')

ending = 20

res_eirene_sphr_s = eirene(euc_dist_mat_sphr_s,maxdim=eirene_maxdim,model=eirene_model)
res_eirene_sphr_r = eirene(euc_dist_mat_sphr_r,maxdim=eirene_maxdim,model=eirene_model)
res_eirene_ball = eirene(euc_dist_mat_ball,maxdim=eirene_maxdim,model=eirene_model)
res_eirene_cylinder = eirene(euc_dist_mat_cylinder,maxdim=eirene_maxdim,model=eirene_model)
res_eirene_plane = eirene(euc_dist_mat_plane,maxdim=eirene_maxdim,model=eirene_model)



plot_and_save_bettis(res_eirene_sphr_s, n_sphr_s, do_save=false)
plot_and_save_bettis(res_eirene_sphr_r, n_sphr_r; do_save=false)
plot_and_save_bettis(res_eirene_ball, n_ball; do_save=false);
plot_and_save_bettis(res_eirene_cylinder, n_cylin; do_save=false);
plot_and_save_bettis(res_eirene_plane, n_plane; do_save=false);


# ###########################
# eirene examples
# Code below ca not be run due to occrug errors
# x = rand(3,50)
#     C = eirene(x, model = "pc")
#     plotbarcode_pjs(C,dim=1)
#     plotpersistencediagram_pjs(C,dim=1)
#     plotclassrep_pjs(C,dim=1,class=1)
#     plotbetticurve_pjs(C, dim=1)



filepath_1 = eirenefilepath("noisycircle")
pointcloud_1 = readdlm(filepath_1, ',', Float64, '\n')
set_size = size(pointcloud_1)[2]
lim = 200;
reduced_1 = pointcloud_1[:, Int.(floor.(range(1, stop=set_size, step = set_size/lim)))]

ezplot_pjs(reduced_1)
pointcloud_1_distances = pairwise(Euclidean(), reduced_1, dims=2)

C = eirene(reduced_1, model = "pc", maxdim=3)
plot_and_save_bettis(C, "noisycircle", do_save=true)
plotbetticurve_pjs(C, dim=1)
plotpersistencediagram_pjs(C, dim=1)
plotbarcode_pjs(C, dim=0:2)



filepath_2 = eirenefilepath("noisytorus")
pointcloud_2 = readdlm(filepath_2, ',', Float64, '\n')
set_size = size(pointcloud_2)[2]
reduced_2 = pointcloud_2[:, Int.(floor.(range(1, stop=set_size, step = set_size/lim)))]

ezplot_pjs(reduced_2)
pointcloud_2_distances = pairwise(Euclidean(), reduced_2, dims=2)

C = eirene(reduced_2, model = "pc", maxdim=3)
plot_and_save_bettis(C, "noisytorus"; do_save=true)
plotbetticurve_pjs(C, dim=1)
plotpersistencediagram_pjs(C, dim=1)
plotbarcode_pjs(C, dim=0:2)
