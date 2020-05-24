function integral(x::CellVar, grid::TreeGrid; filter::Function = active)
    int = zero(eltype(x.data))
    for cell ∈ cells(grid, filter = filter)
        int += volume(cell) * value(x, cell)
    end
    return int
end

function inner_product(x::CellVar, y::CellVar, grid::TreeGrid; filter::Function = active)
    int = zero(eltype(x.data))
    for cell ∈ cells(grid, filter = filter)
        int += volume(cell) * value(x, cell) * value(y, cell)
    end
    return int
end

@inline norm(x::CellVar, grid::TreeGrid; filter::Function = active) = sqrt(inner_product(x, x, grid, filter))
