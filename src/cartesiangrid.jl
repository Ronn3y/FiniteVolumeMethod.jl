struct CartesianGrid{N} <: AbstractGrid{N}
    position::Vector
    nx::NTuple{N, Int}
    periodic::Vector{Bool}

    nr_cells::Int
    nr_faces::Int
end
function CartesianGrid(position::Vector, n; periodic = fill(false, length(position)))
    N = length(position)
    if isa(periodic, Bool) periodic = fill(periodic, N) end
    nx = Tuple(fill(n, N))
    return CartesianGrid{N}(position, nx, periodic, prod(nx), prod(nx .+ 1))
end

# Simply wrap the filter such that dedicated active / at_boundary etc. are called
@inline cells(grid::CartesianGrid; filter::Function = (_...) -> true) = Iterators.filter(filter, Iterators.product(CartesianIndices(size(CellVar, grid)), ((grid, CellVar), )))
@inline faces(grid::CartesianGrid; filter::Function = (_...) -> true) = Iterators.filter(filter, Iterators.product(CartesianIndices(size(FaceVar, grid)), ((grid, FaceVar), )))

@inline size(type::Type{CellVar}, grid::CartesianGrid) = grid.nx
@inline size(type::Type{FaceVar}, grid::CartesianGrid) where N = ((Tuple(grid.nx .+ 1))..., N)

@inline index(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{<:AbstractGridVar}}}) = it[1]
@inline volume(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{AbstractGridVar}}}) = 1. / prod(grid.nx)
@inline cell_volume(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{AbstractGridVar}}}) = 1. / prod(grid.nx)
function area(it::Tuple{CartesianIndex, Tuple{CartesianGrid, FaceVar}})

end

function active(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{CellVar}}})

end
function active(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{FaceVar}}})

end
function at_boundary(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{FaceVar}}})

end

@inline at_refinement(it::Tuple{CartesianIndex, Tuple{CartesianGrid, Type{FaceVar}}}) = false


function sum_axesproduct(A::Matrix, grid::CartesianGrid)
    v = zero(eltype(A))
    sze = Tuple(grid.nx)
    axprod = Iterators.product(Base.OneTo.(sze)...)
    for (i, j) ∈ axprod
        v += A[i, j]
    end
    return v
end

function sum_axesproduct(A::Matrix, sze::Tuple{Int, Int})
    v = zero(eltype(A))
    axprod = Iterators.product(Base.OneTo.(sze)...)
    for (i, j) ∈ axprod
        v += A[i, j]
    end
    return v
end

function sum_cartesianindices(A::Matrix, sze::Tuple{Int, Int})
    v = zero(eltype(A))
    for ind ∈ CartesianIndices(sze)
        v += A[ind]
    end
    return v
end

function sum_doubleloop(A::Matrix, sze::Tuple{Int, Int})
    v = zero(eltype(A))
    for i=1:sze[1], j=1:sze[2]
        v += A[i, j]
    end
    return v
end
