function integral(x::CellVar, grid::TreeGrid; filter::Function = active)
    int = zero(eltype(x.data))
    for cell ∈ cells(grid, filter = filter)
        @inbounds int += volume(cell) * x[cell]
    end
    return int
end

function inner_product(x::CellVar, y::CellVar, grid::TreeGrid; filter::Function = active)
    int = zero(eltype(x.data))
    for cell ∈ cells(grid, filter = filter)
        @inbounds int += volume(cell) * x[cell] * y[cell]
    end
    return int
end

@inline norm(x::CellVar, grid::TreeGrid; filter::Function = active) = sqrt(inner_product(x, x, grid, filter))
