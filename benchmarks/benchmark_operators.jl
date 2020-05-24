using FiniteVolumeMethod
using BenchmarkTools


operators = ((gradient, grid -> CellVar(x -> sum(x), grid)), (divergence, grid -> FaceVar(x -> x, grid)))

suite = BenchmarkGroup()
refinement_steps = 5

for dim = 1
    suite[dim] = BenchmarkGroup()

    # Create a uniform grid
    uniform = TreeGrid(zeros(dim))
    for step=1:refinement_steps
        FiniteVolumeMethod.refine!(uniform, [uniform.tree], recurse=true)
    end

    # Create a locally refined grid
    refined = TreeGrid(zeros(dim))
    child = refined.tree
    for step=1:refinement_steps
        FiniteVolumeMethod.refine!(refined, [child])
        child = child.children[1+mod(step-1, 1<<dim)]
    end

    cartesian = CartesianGrid(1 << refinement_steps, dim)

    grids = [refined, uniform, cartesian]
    gridNames = ["refined", "uniform", "cartesian"]

    for (oper, constructor) ∈ operators
        suite[dim][string(oper)] = BenchmarkGroup()

        for (i, grid) ∈ enumerate(grids)
            var = constructor(grid)
            suite[dim][string(oper)][gridNames[i]] = @benchmarkable $(oper)($var, $grid)
        end
    end
end
