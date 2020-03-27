function gradient(cel_based::Vector, grid::Grid)
    grad = Vector{eltype(cell_based)}()
    for face ∈ faces(grid)
        if at_boundary(face)
            push!(grad, 0.)
        else
            val = 0.
            for cell ∈ cells(face)
                val += cell_based[index(cell)]
            end
            val /= cell_volume(face)
            push!(grid, val)
        end
    end
end
