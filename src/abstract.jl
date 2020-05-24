abstract type AbstractGrid{N} end

abstract type AbstractGridVar end

struct CellVar <: AbstractGridVar
    data::Vector
end
struct FaceVar <: AbstractGridVar
    data::Vector
end

import Base.size
@inline size(type::Type{CellVar}, grid::AbstractGrid) = grid.nr_cells
@inline size(type::Type{FaceVar}, grid::AbstractGrid) = grid.nr_faces


function CellVar(fun::Function, grid::AbstractGrid; filter::Function = _ -> true)
    data = zeros(size(CellVar, grid))
    for cell ∈ cells(grid, filter = filter)
        data[index(cell)] = fun(centroid(cell))
    end
    return CellVar(data)
end
function FaceVar(fun::Function, grid::AbstractGrid; filter::Function = _ -> true)
    data = zeros(size(FaceVar, grid))
    for face ∈ faces(grid, filter = filter)
        vec = fun(centroid(face))
        data[index(face)] = vec[FullyThreadedTree.direction(face)]
    end
    return FaceVar(data)
end

@inline value(x::CellVar, cell::Tree) = x.data[index(cell)]
@inline value(x::FaceVar, cell::Face) = x.data[index(cell)]
