function integral(x::CellVar, grid::Grid)
    int = zero(eltype(x.data))
    for cell ∈ filter(active, grid.cells)
        int += volume(cell) * value(x, cell)
    end
    return int
end

function inner_product(x::CellVar, y::CellVar, grid::Grid)
    int = zero(eltype(x.data))
    for cell ∈ filter(active, grid.cells)
        int += volume(cell) * value(x, cell) * value(y, cell)
    end
    return int
end

@inline norm(x::CellVar, grid::Grid) = sqrt(inner_product(x, x, grid))
