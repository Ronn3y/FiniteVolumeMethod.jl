module FiniteVolumeMethod

    using FullyThreadedTree
    using Lazy

    include("grid.jl")

    export Grid,
           index


    include("interface.jl")

    export show,
           faces,
           cells,
           active_cells,
           parens_of_active_cell,
           boundary_faces,
           refinement_faces,
           regular_faces,
           active_faces

    include("operators.jl")

    export gradient,
           divergence


end # module
