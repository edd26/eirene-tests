using Eirene
using DelimitedFiles
 include("julia-functions/BettiCurves.jl")


dist_mat_ball = readdlm( "dist_mat_ball.csv",  ',', Float64, '\n') .+1
dist_mat_cylin = readdlm( "dist_mat_cylin.csv",  ',', Float64, '\n') .+1
dist_mat_plane = readdlm( "dist_mat_plane.csv",  ',', Float64, '\n').+1
dist_mat_sphr_r = readdlm( "dist_mat_sphr_r.csv",  ',', Float64, '\n').+1
dist_mat_sphr_s = readdlm( "dist_mat_sphr_s.csv",  ',', Float64, '\n').+1
# ending = 20

# inv_corr_mat = (corr_matrix_mouse.*4).+10

topology_results_ball = eirene(dist_mat_ball,maxdim=3,model="vr")
plot_ref_ball = plot_bettis(topology_results_ball, "ball")

topology_results_cylin = eirene(dist_mat_cylin,maxdim=3,model="vr")
plot_ref_cylin = plot_bettis(topology_results_cylin, "cylinder")

topology_results_plane = eirene(dist_mat_plane,maxdim=3,model="vr")
plot_ref_plane = plot_bettis(topology_results_plane, "plane")

topology_results_sphr_r = eirene(dist_mat_sphr_r,maxdim=3,model="vr")
plot_ref_sphr_r = plot_bettis(topology_results_sphr_r, "shifted spheres")

topology_results_sphr_s = eirene(dist_mat_sphr_s,maxdim=3,model="vr")
plot_ref_sphr_s = plot_bettis(topology_results_sphr_s, "reduced spheres")


cd("/home/ed19aaf/Programming/Julia/olfaction/")
savefig(plot_ref_ball, "results/eirene_dist_mat_ball.png")
savefig(plot_ref_cylin, "results/eirene_dist_mat_cylin.png")
savefig(plot_ref_plane, "results/eirene_dist_mat_plane.png")
savefig(plot_ref_sphr_r, "results/eirene_dist_mat_sphr_r.png")
savefig(plot_ref_sphr_s, "results/eirene_dist_mat_sphr_s.png")
