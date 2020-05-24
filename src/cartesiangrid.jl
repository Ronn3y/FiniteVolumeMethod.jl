struct CartesianGrid{N} <: AbstractGrid{N}
    position::Vector    # TODO position is bottom-left corner of domain (in contrast to TreeGrid where it is the center)
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
@inline cells(grid::CartesianGrid{N}; filter::Function = _ -> true) where N = Iterators.filter(filter, Iterators.product(CartesianIndices(size(CellVar, grid)), (grid, ), (CellVar{N, Number}, )))
@inline faces(grid::CartesianGrid{N}; filter::Function = _ -> true) where N = Iterators.filter(filter, Iterators.product(CartesianIndices(size(FaceVar, grid)), (grid, ), (FaceVar{N, Number}, )))

@inline size(type::Type{CellVar}, grid::CartesianGrid) = grid.nx
@inline size(type::Type{FaceVar}, grid::CartesianGrid{N}) where N = ((Tuple(grid.nx .+ 1))..., N)


@inline index((ind, grid, type)::Tuple{CartesianIndex, CartesianGrid, DataType}) = ind
@inline volume((ind, grid, type)::Tuple{CartesianIndex, CartesianGrid, DataType}) = 1. / prod(grid.nx)
@inline cell_volume((ind, grid, type)::Tuple{CartesianIndex, CartesianGrid, DataType}) = 1. / prod(grid.nx)

function area((ind, grid, type)::Tuple{CartesianIndex, CartesianGrid, DataType})

end

@inline direction((ind, grid, type)::Tuple{CartesianIndex, CartesianGrid{N}, DataType}) where N = ind[N+1]

# NB can't dispatch on Tuples parametrized by a type, so we must unpack the Tuple
@inline active(tup::Tuple{CartesianIndex, CartesianGrid, DataType}) = active(tup...)
function active(ind::CartesianIndex, grid::CartesianGrid, type::Type{CellVar{N, T}}) where {N, T}

end
function active(ind::CartesianIndex, grid::CartesianGrid, type::Type{FaceVar{N, T}}) where {N, T}

end

@inline centroid(tup::Tuple{CartesianIndex, CartesianGrid, DataType}) = centroid(tup...)
function centroid(ind::CartesianIndex, grid::CartesianGrid{N}, type::Type{CellVar{N, T}}) where {N, T}
    cent = copy(grid.position)
    for dim ∈ eachindex(cent)
        cent[dim] += (ind[dim] - 0.5) / grid.nx[dim]
    end
    return cent
end
function centroid(ind::CartesianIndex, grid::CartesianGrid{N}, type::Type{FaceVar{N, T}}) where {N, T}
    cent = copy(grid.position)
    direction = ind[N+1]
    for dim ∈ eachindex(cent)
        if dim == direction
            cent[dim] += (ind[dim] - 1.0) / grid.nx[dim]
        else
            cent[dim] += (ind[dim] - 1.5) / grid.nx[dim]
        end
    end
    return cent
end

@inline at_boundary(tup::Tuple{CartesianIndex, CartesianGrid, DataType}) = at_boundary(tup...)
function at_boundary(ind::CartesianIndex, grid::CartesianGrid, type::Type{FaceVar})

end

@inline at_refinement(it::Tuple{CartesianIndex, CartesianGrid, DataType}) = false
