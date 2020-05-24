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

    include("abstract.jl")

    export CellVar,
           FaceVar,
           size

    include("treegrid.jl")

    export TreeGrid,
           index,
           refine!,
           coarsen!

    include("cartesiangrid.jl")

    export CartesianGrid,
           area,
           volume,
           cell_volume

    include("interface.jl")

    export show,
           faces,
           cells

    include("operators.jl")

    export gradient,
           divergence

    include("functionals.jl")

    export integral,
           inner_product,
           norm

    include("plotting.jl")

    export plot


end # module
