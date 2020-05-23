using FiniteVolumeMethod
using Test

@testset "FiniteVolumeMethod.jl" begin
    uniform = Grid([0.0, 0.0])
    max_steps = 5
    lInf_linear = zeros(max_steps)
    lInf_nonlinear = zeros(max_steps)
    for step=1:max_steps
        FiniteVolumeMethod.refine!(uniform, [uniform.tree], recurse=true)

        p = CellVar(x -> pi + 7x[1] - 4x[2], uniform)
        gExact = FaceVar(x -> [7, -4], uniform)
        g = gradient(p, uniform)
        lInf_linear[step] = maximum(abs.(g.data - gExact.data))

        p = CellVar(x -> pi + 7sin(x[1]) - 4x[1]x[2]^2, uniform)
        gExact = FaceVar(x -> [7cos(x[1]) - 4x[2]^2, -8x[1]x[2]], uniform)
        g = gradient(p, uniform)
        lInf_nonlinear[step] = maximum(abs.(g.data - gExact.data))
    end

    # Gradient of a linear function should be exact
    @test all(lInf_linear .== 0.0)

    # Gradient of a nonlinear function should be second order accurate
    order = log2.(lInf_nonlinear[1:max_steps-1] ./ lInf_nonlinear[2:max_steps])
    @test all(abs.(order .- 2) .< 1E-2)


end
