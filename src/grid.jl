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
    tmp = 0
    Grid(Tree(position, periodic = periodic, cell_state = cell -> 1, face_state = face -> tmp += 1), 1, 4 - count(periodic), Vector{Int64}(), Vector{Int64}())
end

@inline function refine!(grid::Grid{N}, cell::Tree{N}; recurse = false) where N
    FullyThreadedTree.refine!(cell, cell_state = cell -> cell_incrementer!(grid), face_state = face -> face_incrementer!(grid), recurse = recurse)
end

@inline function refine!(grid::Grid{N}, cells::Vector{Tree{N}}; recurse = false, issorted = false) where N
    FullyThreadedTree.refine!(cells, cell_state = cell -> cell_incrementer!(grid), face_state = face -> face_incrementer!(grid), recurse = recurse, issorted = issorted)
end

function coarsen!(grid::Grid{N}, cells::Vector{Tree{N}}) where N
    removed_cells, removed_faces = FullyThreadedTree.coarsen!(cells, face_incrementer!(grid))
    for cell ∈ removed_cells
        push!(grid.cell_index_queue, index(cell))
        grid.nr_cells -= 1
    end
    for face ∈ removed_faces
        push!(grid.face_index_queue, index(face))
        grid.nr_faces -= 1
    end
end

@inline cell_incrementer!(grid::Grid) = isempty(grid.cell_index_queue) ? grid.nr_cells += 1 : pop!(grid.cell_index_queue)
@inline face_incrementer!(grid::Grid) = isempty(grid.face_index_queue) ? grid.nr_faces += 1 : pop!(grid.face_index_queue)

abstract type AbstractGridVar end

struct CellVar <: AbstractGridVar
    data::Vector
end

@inline index(cell::Tree) = cell.state
@inline index(face::Face) = face.state
