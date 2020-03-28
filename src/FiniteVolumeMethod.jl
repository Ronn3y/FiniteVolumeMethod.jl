module FiniteVolumeMethod

    import FullyThreadedTree
    import FullyThreadedTree: Tree, Face, plot, at_boundary, at_refinement, regular, active, level, parent_of_active, initialized, faces

    export Tree,
           Face,
           plot,
           at_boundary,
           at_refinement,
           regular,
           active,
           level,
           parent_of_active,
           initialized
           
    include("grid.jl")

    export Grid,
           index,
           refine!,
           coarsen!

    include("interface.jl")

    export show,
           faces,
           cells

    include("operators.jl")

    export gradient,
           divergence


end # module
