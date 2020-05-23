using FiniteVolumeMethod
using Test

@testset "FiniteVolumeMethod.jl" begin

    init_steps = 3
    ref_steps = 2

    for dim=1:3
        uniform = Grid(zeros(dim))
        vec = 1 : dim
        vec2 = dim : -1 : 1

        # A uniform grid
        for step=1:init_steps
            FiniteVolumeMethod.refine!(uniform, [uniform.tree], recurse=true)
        end

        # Locally refined grid
        refined = Grid(zeros(dim))
        child = refined.tree
        for step=1:init_steps
            FiniteVolumeMethod.refine!(refined, [child])
            child = child.children[1+mod(step-1, 1<<dim)]
        end

        grids = [uniform, refined]
        expected_orders = [2, 1]

        div_lInf_constant = zeros(ref_steps)
        div_lInf_linear = zeros(ref_steps)
        div_lInf_nonlinear = zeros(ref_steps)
        grad_lInf_constant = zeros(ref_steps)
        grad_lInf_linear = zeros(ref_steps)
        grad_lInf_nonlinear = zeros(ref_steps)
        for (i, grid) ∈ enumerate(grids)
            for step=1:ref_steps
                FiniteVolumeMethod.refine!(grid, [grid.tree], recurse=true)

                # Gradient:
                p = CellVar(x -> pi, grid)
                g = gradient(p, grid)
                grad_lInf_constant[step] = maximum(abs.(g.data))

                p = CellVar(x -> pi + sum(vec .* x), grid)
                gExact = FaceVar(x -> vec, grid, filter = active)
                g = gradient(p, grid)
                grad_lInf_linear[step] = maximum(abs.(g.data - gExact.data))

                p = CellVar(x -> pi + sum(vec .* cos.(x)), grid)
                gExact = FaceVar(x -> -vec .* sin.(x), grid, filter = active)
                g = gradient(p, grid)
                grad_lInf_nonlinear[step] = maximum(abs.(g.data - gExact.data))

                # divergence:
                u = FaceVar(x -> vec, grid)
                d = divergence(u, grid)
                div_lInf_constant[step] = maximum(abs.(d.data))

                u = FaceVar(x -> vec .* x + vec2, grid)
                dExact = CellVar(x -> sum(vec), grid, filter = active)
                d = divergence(u, grid)
                div_lInf_linear[step] = maximum(abs.(d.data - dExact.data))

                u = FaceVar(x -> sum(x.^2) .+ vec .* x + cos.(x), grid)
                dExact = CellVar(x -> 2sum(x) + sum(vec) - sum(sin.(x)), grid, filter = active)
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
            grad_order = log2.(grad_lInf_nonlinear[1:ref_steps-1] ./ grad_lInf_nonlinear[2:ref_steps])
            div_order = log2.(div_lInf_nonlinear[1:ref_steps-1] ./ div_lInf_nonlinear[2:ref_steps])
            @test all(grad_order .>= expected_orders[i] - 1E-1)
            @test all(div_order .>= expected_orders[i] - 1E-1)
        end
    end
end
