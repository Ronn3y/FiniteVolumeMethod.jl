abstract type AbstractGrid{N} end

mutable struct Grid{N} <: AbstractGrid{N}
    tree::Tree{N}
    nr_cells::Int
    nr_faces::Int

    cell_index_queue::Vector{Int64}
    face_index_queue::Vector{Int64}
end

@inline function Grid(position::Vector; periodic = fill(false, length(position)))
    if isa(periodic, Bool) periodic = fill(periodic, length(position)) end
    Grid(Tree(position, periodic = periodic, cell_state = cell -> 1, face_state = face -> 2 + count(periodic)), 1, 2 + count(periodic), Vector{Int64}(), Vector{Int64}())
end

@inline function refine!(grid::Grid{N}, cells::Vector{Tree{N}}; recurse = false) where N
    FullyThreadedTree.refine!(cells, cell_state = cell -> cell_incrementer(grid), face_state = face -> face_incrementer(grid), recurse = recurse)
end

@inline cell_incrementer(grid::Grid) = isempty(grid.cell_index_queue) ? grid.nr_cells += 1 : pop!(grid.cell_index_queue)
@inline face_incrementer(grid::Grid) = isempty(grid.face_index_queue) ? grid.nr_faces += 1 : pop!(grid.face_index_queue)

abstract type AbstractGridVar end

struct CellVar <: AbstractGridVar
    data::Vector
end

@inline index(cell::Tree) = cell.state
@inline index(face::Face) = face.state
