using FiniteVolumeMethod
using Test

@testset "FiniteVolumeMethod.jl" begin
    dim = 2
    uniform = Grid(zeros(dim))
    max_steps = 3

    # A uniform grid
    for step=1:max_steps
        FiniteVolumeMethod.refine!(uniform, [uniform.tree], recurse=true)
    end

    # Locally refined grid
    refined = Grid(zeros(dim))
    child = refined.tree
    for step=1:max_steps
        FiniteVolumeMethod.refine!(uniform, [child])
        child = child.children[1+mod(step-1, 4)]
    end

    grids = [uniform, refined]
    grad_orders = [2, 1]

    div_lInf_constant = zeros(max_steps)
    div_lInf_linear = zeros(max_steps)
    div_lInf_nonlinear = zeros(max_steps)
    grad_lInf_constant = zeros(max_steps)
    grad_lInf_linear = zeros(max_steps)
    grad_lInf_nonlinear = zeros(max_steps)
    for (i, grid) ∈ enumerate(grids)
        for step=1:max_steps
            FiniteVolumeMethod.refine!(grid, [grid.tree], recurse=true)

            # Gradient:
            p = CellVar(x -> pi, grid)
            g = gradient(p, grid)
            grad_lInf_constant[step] = maximum(abs.(g.data))

            p = CellVar(x -> pi + 7x[1] - 4x[2], grid)
            gExact = FaceVar(x -> [7, -4], grid, filter = active)
            g = gradient(p, grid)
            grad_lInf_linear[step] = maximum(abs.(g.data - gExact.data))

            p = CellVar(x -> pi + 7sin(x[1]) - 4x[1]x[2]^2, grid)
            gExact = FaceVar(x -> [7cos(x[1]) - 4x[2]^2, -8x[1]x[2]], grid, filter = active)
            g = gradient(p, grid)
            grad_lInf_nonlinear[step] = maximum(abs.(g.data - gExact.data))

            # divergence:
            u = FaceVar(x -> [-pi, -1], grid)
            d = divergence(u, grid)
            div_lInf_constant[step] = maximum(abs.(d.data))

            u = FaceVar(x -> [x[1] - pi, x[2] - 1], grid)
            dExact = CellVar(x -> 2., grid, filter = active)
            d = divergence(u, grid)
            div_lInf_linear[step] = maximum(abs.(d.data - dExact.data))

            u = FaceVar(x -> [cos(x[1]) - pi*x[2], sin(x[2]) - x[1]^2], grid)
            dExact = CellVar(x -> cos(x[2]) - sin(x[1]), grid, filter = active)
            d = divergence(u, grid)
            div_lInf_nonlinear[step] = maximum(abs.(d.data - dExact.data))
        end

        @test all(grad_lInf_constant .== 0.0)
        @test all(div_lInf_constant .== 0.0)

        # Approximate derivative of a linear function should be exact
        @test all(grad_lInf_linear .== 0.0)
        @test all(div_lInf_linear .== 0.0)

        # Approximate derivative of a nonlinear function should be second order accurate (uniform)
        # and first order accurate at refinement interfaces
        grad_order = log2.(grad_lInf_nonlinear[1:max_steps-1] ./ grad_lInf_nonlinear[2:max_steps])
        div_order = log2.(div_lInf_nonlinear[1:max_steps-1] ./ div_lInf_nonlinear[2:max_steps])
        @test all(abs.(grad_order .- grad_orders[i]) .< 1E-1)
        @test all(abs.(div_order .- 2) .< 1E-1)

    end
end
