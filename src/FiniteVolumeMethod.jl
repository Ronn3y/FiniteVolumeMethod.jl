module FiniteVolumeMethod

    import FullyThreadedTree
    import FullyThreadedTree: Tree, Face, centroid, at_boundary, at_refinement, regular, active, level, parent_of_active, initialized, cells, faces, levels, face_area, area, volume, cell_volume

    export Tree,
           Face,
           at_boundary,
           at_refinement,
           regular,
           active,
           level,
           parent_of_active,
           initialized,
           centroid

    include("grid.jl")

    export Grid,
           index,
           refine!,
           coarsen!,
           CellVar,
           FaceVar

    include("interface.jl")

    export show,
           faces,
           cells

    include("operators.jl")

    export gradient,
           divergence

    include("plotting.jl")

    export plot


end # module
