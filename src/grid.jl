abstract type AbstractGrid{N} end

mutable struct Grid{N} <: AbstractGrid{N}
    tree::Tree{N}
    nr_cells::Int
    nr_faces::Int
end

@inline function Grid(position::Vector; periodic = fill(false, length(position)))
    if isa(periodic, Bool) periodic = fill(periodic, length(position)) end
    tmp = 0
    Grid(Tree(position, periodic = periodic, cell_state = cell -> Ref(1), face_state = face -> Ref(tmp += 1)), 1, 4 - count(periodic))
end

@inline function refine!(grid::Grid{N}, cell::Tree{N}; recurse = false) where N
    FullyThreadedTree.refine!(cell, cell_state = cell -> cell_incrementer!(grid), face_state = face -> face_incrementer!(grid), recurse = recurse)
    # NB  Refine does not remove any cells/faces
end

@inline function refine!(grid::Grid{N}, cells::Vector{Tree{N}}; recurse = false, issorted = false) where N
    FullyThreadedTree.refine!(cells, cell_state = cell -> cell_incrementer!(grid), face_state = face -> face_incrementer!(grid), recurse = recurse, issorted = issorted)
    # NB  Refine does not remove any cells/faces
end

@inline function coarsen!(grid::Grid{N}, cells::Vector{Tree{N}}) where N
    FullyThreadedTree.coarsen!(cells, face_state = face -> face_incrementer!(grid))

    update_indices!(grid)
end

@inline cell_incrementer!(grid::Grid) = Ref(grid.nr_cells += 1)
@inline face_incrementer!(grid::Grid) = Ref(grid.nr_faces += 1)

function update_indices!(grid::Grid)
    grid.nr_cells = 0
    for cell ∈ cells(grid)
        cell.state.x = grid.nr_cells += 1
    end
    grid.nr_faces = 0
    for face ∈ faces(grid)
        face.state.x = grid.nr_faces += 1
    end
end

abstract type AbstractGridVar end

struct CellVar <: AbstractGridVar
    data::Vector
end

@inline index(cell::Tree) = cell.state.x
@inline index(face::Face) = face.state.x
