function gradient(var::CellVar, grid::Grid)
    grad = zeros(eltype(var.data), grid.nr_faces)
    for face ∈ filter(active, grid.faces)
        val = zero(eltype(var.data))
        for cell ∈ FullyThreadedTree.cells(face)
            val -= FullyThreadedTree.face_area(cell, face) * normal_sign(cell, face) * value(var, cell)
        end
        grad[index(face)] = val /= FullyThreadedTree.cell_volume(face)
    end
    return FaceVar(grad)
end
