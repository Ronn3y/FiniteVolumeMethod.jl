abstract type AbstractGrid{N} end

abstract type AbstractGridVar{T, N} <: AbstractArray{T, N} end

struct CellVar{T, N} <: AbstractGridVar{T, N}
    data::Array{T, N}
    CellVar(data::Array{T, N}) where{T, N} = new{T, N}(data)
end
struct FaceVar{T, N} <: AbstractGridVar{T, N}
    data::Array{T, N}
end

import Base.size
@inline size(type::Type{CellVar}, grid::AbstractGrid) = grid.nr_cells
@inline size(type::Type{FaceVar}, grid::AbstractGrid) = grid.nr_faces

import Base.eltype
@inline eltype(var::AbstractGridVar) = eltype(var.data)

import Base: getindex, setindex!, firstindex, lastindex, size
@inline getindex(var::AbstractGridVar, i::Int) = getindex(var.data, i)
@inline getindex(var::AbstractGridVar, I::Vararg{Int, N}) where N = getindex(var.data, I...)
@inline getindex(var::AbstractGridVar, c::Colon) = getindex(var.data, c::Colon)
@inline getindex(var::AbstractGridVar, i) = getindex(var.data, index(i))

@inline setindex!(var::AbstractGridVar, v, i::Int) = setindex!(var.data, v, i)
@inline setindex!(var::AbstractGridVar, v, I::Vararg{Int, N}) where N = setindex!(var.data, v, I...)
@inline setindex!(var::AbstractGridVar, v, i) = setindex!(var.data, v, index(i))

@inline firstindex(var::AbstractGridVar) = firstindex(var.data)
@inline lastindex(var::AbstractGridVar) = lastindex(var.data)
@inline size(var::AbstractGridVar, args...) = size(var.data, args...)


function CellVar(fun::Function, grid::AbstractGrid; filter::Function = _ -> true)
    var = CellVar(zeros(size(CellVar, grid)))
    @inbounds for cell ∈ cells(grid, filter = filter)
        var[cell] = fun(centroid(cell))
    end
    return var
end
function FaceVar(fun::Function, grid::AbstractGrid; filter::Function = _ -> true)
    var = FaceVar(zeros(size(FaceVar, grid)))
    @inbounds for face ∈ faces(grid, filter = filter)
        vec = fun(centroid(face))
        var[face] = vec[direction(face)]
    end
    return var
end
