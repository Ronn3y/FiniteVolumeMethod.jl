function gradient(var::CellVar, grid::TreeGrid; filter = active)
    grad = zeros(eltype(var.data), grid.nr_faces)
    for face ∈ faces(grid, filter = filter)
        val = zero(eltype(var.data))
        for cell ∈ FullyThreadedTree.cells(face)
            val -= FullyThreadedTree.face_area(cell, face) * normal_sign(cell, face) * value(var, cell)
        end
        grad[index(face)] = val /= FullyThreadedTree.cell_volume(face)
    end
    return FaceVar(grad)
end

function divergence(var::FaceVar, grid::TreeGrid; filter = active)
    div = zeros(eltype(var.data), grid.nr_cells)
    for cell ∈ cells(grid, filter = filter)
        val = zero(eltype(var.data))
        for face ∈ FullyThreadedTree.faces(cell)
            val += FullyThreadedTree.area(face) * normal_sign(cell, face) * value(var, face)
        end
        div[index(cell)] = val /= FullyThreadedTree.volume(cell)
    end
    return CellVar(div)
end


function gradient(var::CellVar, grid::CartesianGrid)

end
