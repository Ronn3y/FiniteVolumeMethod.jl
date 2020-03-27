abstract type AbstractGrid end

struct Grid <: AbstractGrid
    tree::Tree
end

function Grid(position::Vector; periodic = fill(false, length(position)))
    grid = Grid(Tree(position, periodic = periodic))
    set_indices!(grid)
    return grid
end

@inline index(cell::Tree) = cell.state
@inline index(face::Face) = face.state

function set_indices!(grid::Grid)
    for (cell, index) ∈ enumerate(cells(grid))
        cell.state = index
    end
    for (face, index) ∈ enumerate(faces(grid))
        face.state = index
    end
    return nothing
end
