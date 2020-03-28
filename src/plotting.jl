import Plots, Plots.plot, Plots.annotate!, Plots.current, Plots.text, Plots.font

function plot(grid::Grid{2}; markers::Bool = false, max_marker_level::Int = 5, path::Bool = false, indices = false, filter::Function = active)
    FullyThreadedTree.plot(grid.tree, markers = markers, max_marker_level = max_marker_level, path = path, filter = filter)
    if indices
        max_level = levels(grid.tree) - 1
        font_size = 10.0/(1<<min(max_level, max_marker_level))
        for cell ∈ cells(grid, filter = filter, max_level = max_marker_level)
            pos = centroid(cell)
            annotate!(pos[1], pos[2], index(cell), font(font_size))
        end
        for face ∈ faces(grid, filter = filter, max_level = max_marker_level)
            pos = centroid(face)
            annotate!(pos[1], pos[2], index(face), font(font_size))
        end
    end
    Plots.current()
end
