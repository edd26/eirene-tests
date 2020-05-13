

using Eirene
 using DelimitedFiles
 using Distances
 using LinearAlgebra
 using Statistics
 # cd("/home/ed19aaf/Programming/Julia/olfaction")
 cd("../eirene-tests")
    julia_func_path = "../julia-functions/"
    include(julia_func_path*"GeometricSampling.jl");
    include(julia_func_path*"MatrixToolbox.jl")
    include(julia_func_path*"MatrixProcessing.jl")
    include(julia_func_path*"BettiCurves.jl")
    include(julia_func_path*"ImageProcessing.jl")
    include(julia_func_path*"PlottingWrappers.jl")
    include(julia_func_path*"MatrixOrganization.jl")
    include(julia_func_path*"TopologyStructures.jl")
 # include("../julia-functions/MatrixProcessing.jl")

matrix_size = 64
max_B_dim = 5
min_dim = 1
plot_title = ""
rand_mat = generate_random_matrix(matrix_size)
ord_mat = get_ordered_matrix(rand_mat)
   C = eirene(ord_mat, maxdim=max_B_dim)
   # random_plot = get_and_plot_bettis(C,max_dim=max_B_dim,legend_on=true)

# ===
bettis = get_bettis(C, max_B_dim)
   norm_bettis = normalise_bettis(bettis)
   # =
   max_dim = size(bettis,1)
   all_dims = min_dim:max_dim

   # set_default_plotting_params()
   cur_colors = get_color_palette(:auto, 17)
   cur_colors2 = get_color_palette(:cyclic1, 40)
   if min_dim == 0
      colors_set =  [cur_colors[3], cur_colors[5], [:red], cur_colors[1]] #cur_colors[7],
   else
      colors_set =  [cur_colors[5], [:red], cur_colors[1], cur_colors[14]]
   end
   for c =  [collect(11:17);]
      push!(colors_set, cur_colors2[c])
   end

   # final_title = "Eirene betti curves, "*plot_title
   plot_ref = plot(title=plot_title)
   for p = 1:(max_dim)
      # @info p
        plot!(bettis[p][:,1], bettis[p][:,2], label="a",
                                       # label="\\beta_$(all_dims[p])",
                                       lc=colors_set[p],
                                       linewidth = 2,);
   end
   plot!(legend=true)
   ylabel!("Number of cycles")
   xlabel!("Edge density")

   # =
   # plot!(random_plot, legend=true)
   title!("random matrix, $(matrix_size) by $(matrix_size)")

   savefig(plot_ref, "results/random_matrix_samlpes$(matrix_size).pdf")

# === === === === === === === === === === === === ===
# get heatmap
plt_title=""
yflip_matrix=true
plot_params= (dpi=300,
                  size=(900,800),
                  lw=1,
                  thickness_scaling=1,
                  top_margin= 0,
                  left_margin=[0 0],
                  bottom_margin= 0
                  )
color_palete=:lightrainbow
add_labels=true
heat_map = heatmap(ord_mat,  color=color_palete,
                  title="",
                  size=plot_params.size, dpi=plot_params.dpi,
                  ticks=0:5:64);
plot!( yflip = true,);

xlabel!("Matrix index")
ylabel!("Matrix index")



plot!(plot_ref, title = "");
plot!(heat_map, title = "");
common_plot = plot(heat_map, plot_ref, layout=(1,2), size=(800,400))
savefig(common_plot, "results/random_matrix_both_$(matrix_size).pdf")
