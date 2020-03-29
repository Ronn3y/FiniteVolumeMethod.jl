# @inline faces(grid::Grid; filter::Function = face -> true, min_level::Int = 0, max_level::Int = typemax(Int)) = FullyThreadedTree.all_faces(grid.tree, filter = filter, min_level = min_level, max_level = max_level)
# @inline faces(grid::Grid, level::Int; filter::Function = face -> true) = FullyThreadedTree.all_faces(grid.tree, level, filter = filter)


# @inline cells(grid::Grid; filter::Function = cell -> true, min_level = 0, max_level = typemax(Int)) = FullyThreadedTree.cells(grid.tree; filter = filter, min_level = min_level, max_level = max_level)
# @inline cells(grid::Grid, level::Int; filter::Function = cell -> true) = FullyThreadedTree.cells(grid.tree, level, filter = filter)

# TODO iterate cells/faces per level (they are sorted according to their level)

function show(grid::Grid)

end
