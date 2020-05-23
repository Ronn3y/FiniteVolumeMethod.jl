abstract type AbstractGrid{N} end

mutable struct Grid{N} <: AbstractGrid{N}
    tree::Tree{N}
    nr_cells::Int
    nr_faces::Int

    cells::Vector{Tree{N}}
    faces::Vector{Face{N}}
end

@inline function Grid(position::Vector; periodic = fill(false, length(position)))
    if isa(periodic, Bool) periodic = fill(periodic, length(position)) end
    tmp = 0
    N = length(position)
    grid = Grid(Tree(position, periodic = periodic, cell_state = cell -> Ref(1), face_state = face -> Ref(tmp += 1)), 1, 4 - count(periodic), fill(Tree{N}(), 0), fill(Face{N}(), 0))

    update_cells!(grid)
    update_faces!(grid)
    update_indices!(grid)
    grid
end

# @inline function refine!(grid::Grid{N}, cell::Tree{N}; recurse = false) where N
#     FullyThreadedTree.refine!(cell, cell_state = cell -> cell_incrementer!(grid), face_state = face -> face_incrementer!(grid), recurse = recurse)
#     # NB  Refine does not remove any cells/faces
# end

@inline function refine!(grid::Grid{N}, cells::Vector{Tree{N}}; recurse = false, issorted = false) where N
    FullyThreadedTree.refine!(cells, cell_state = cell -> cell_incrementer!(grid), face_state = face -> face_incrementer!(grid), recurse = recurse, issorted = issorted)

    update_cells!(grid)
    update_faces!(grid)
    update_indices!(grid)
end

@inline function coarsen!(grid::Grid{N}, cells::Vector{Tree{N}}) where N
    FullyThreadedTree.coarsen!(cells, face_state = face -> face_incrementer!(grid))

    update_cells!(grid)
    update_faces!(grid)
    update_indices!(grid)
end

@inline cell_incrementer!(grid::Grid) = Ref(grid.nr_cells += 1)
@inline face_incrementer!(grid::Grid) = Ref(grid.nr_faces += 1)

function update_cells!(grid::Grid)
    grid.cells = FullyThreadedTree.collect_cells(grid.tree)
    sort(grid.cells, by = level)
end
function update_faces!(grid::Grid)
    grid.faces = FullyThreadedTree.collect_faces(grid.tree)
    sort(grid.faces, by = level)
end

function update_indices!(grid::Grid)
    grid.nr_cells = 0
    for cell ∈ grid.cells
        cell.state.x = grid.nr_cells += 1
    end
    grid.nr_faces = 0
    for face ∈ grid.faces
        face.state.x = grid.nr_faces += 1
    end
end
@inline index(cell::Tree) = cell.state.x
@inline index(face::Face) = face.state.x

# TODO this does not work with periodicity at level 0
function normal_sign(cell::Tree, face::Face)
    if at_boundary(face)
        return +1
    elseif !at_refinement(face)
        return index(cell) == index(face.cells[1]) ? +1 : -1
    else
        return level(cell) == level(face.cells[1]) ? +1 : -1
    end
end

abstract type AbstractGridVar end

struct CellVar <: AbstractGridVar
    data::Vector
end
struct FaceVar <: AbstractGridVar
    data::Vector
end

function CellVar(fun::Function, grid::Grid)
    data = zeros(grid.nr_cells)
    for cell ∈ filter(active, grid.cells)
        data[index(cell)] = fun(centroid(cell))
    end
    return CellVar(data)
end
function FaceVar(fun::Function, grid::Grid)
    data = zeros(grid.nr_faces)
    for face ∈ filter(active, grid.faces)
        vec = fun(centroid(face))
        data[index(face)] = vec[FullyThreadedTree.direction(face)]
    end
    return FaceVar(data)
end

@inline value(x::CellVar, cell::Tree) = x.data[index(cell)]
@inline value(x::FaceVar, cell::Face) = x.data[index(cell)]
