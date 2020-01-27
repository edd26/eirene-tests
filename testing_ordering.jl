julia_func_path = "../julia-functions/"
    include(julia_func_path*"MatrixProcessing.jl")


some_matrix = [38 37 36 30;
               37 34 30 32;
               36 30 31 30;
               30 32 30 29]

# some_matrix = [22 23 24 25;
#               3 26 27 28;
#               4 7 29 30;
#               5 8 0 1]
    input_matrix = some_matrix
assing_same_values = true
ordered_mat = get_ordered_matrix(some_matrix; assing_same_values=false)
 for row=1:size(ordered_mat,1)
    println(ordered_mat[row,:])
 end
 println("====")


function someMyfunctiOn(aalfa; beeta = false)
    if beeta
        println("Hello")
    end
    println(size(aalfa))
    println("====")
end


someMyfunctiOn([1 2])
someMyfunctiOn([1 2]; beeta= true)


# ================================
