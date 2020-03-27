abstract type AbstractGrid end

mutable struct Grid <: AbstractGrid
    tree::Tree
    nr_faces
    nr_cells
end

function Grid(position::Vector; periodic = fill(false, length(position)))
    grid = Grid(Tree(position, periodic = periodic))
    set_indices!(grid)
    return grid
end

abstract type AbstractGridVar end

struct CellVar <: AbstractGridVar
    data::Vector
end

function set_indices!(grid::Grid)
    index = 0
    for cell ∈ cells(grid)
        index += 1
        cell.state = index
    end
    grid.nr_cells = index

    index = 0
    for face ∈ faces(grid)
        index += 1
        face.state = index
    end
    grid.nr_faces = index
    return nothing
end
@inline index(cell::Tree) = cell.state
@inline index(face::Face) = face.state
