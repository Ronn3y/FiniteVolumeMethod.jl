function gradient(var::CellVar, grid::TreeGrid; filter = active)
    grad = FaceVar(zeros(eltype(var), size(FaceVar, grid)))
    @inbounds for face ∈ faces(grid, filter = filter)
        val = zero(eltype(var))
        for cell ∈ FullyThreadedTree.cells(face)
            val -= FullyThreadedTree.face_area(cell, face) * normal_sign(cell, face) * var[cell]
        end
        grad[face] = val /= FullyThreadedTree.cell_volume(face)
    end
    return grad
end

function divergence(var::FaceVar, grid::TreeGrid; filter = active)
    div = CellVar(zeros(eltype(var), size(CellVar, grid)))
    @inbounds for cell ∈ cells(grid, filter = filter)
        val = zero(eltype(var))
        for face ∈ FullyThreadedTree.faces(cell)
            val += FullyThreadedTree.area(face) * normal_sign(cell, face) * var[face]
        end
        div[cell] = val /= FullyThreadedTree.volume(cell)
    end
    return div
end

function gradient(var::CellVar, grid::CartesianGrid)

end
