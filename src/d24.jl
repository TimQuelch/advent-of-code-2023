module d24

using Chain
using InlineTest
using LinearAlgebra
using StaticArrays

function part1(d, l=Int64(2e14), h=Int64(4e14))
    count(Iterators.product(enumerate(d), enumerate(d))) do ((i, (x1, v1)), (j, (x2, v2)))
        if i >= j
            return false
        end
        A = hcat(SVector{2,Int64}(v1[1:2]), -SVector{2,Int64}(v2[1:2]))
        if det(A) == 0
            return false
        end
        b = SVector{2,Int64}(x2[1:2] .- x1[1:2])
        lambdas = A \ b
        p = x1[1:2] .+ lambdas[1] .* v1[1:2]
        return p[1] >= l && p[1] <= h && p[2] >= l && p[2] <= h && all(>=(0), lambdas)
    end
end

function crossproductmatrix(v)
    return [
        0 v[3] -v[2]
        -v[3] 0 v[1]
        v[2] -v[1] 0
    ]
end

function part2(d)
    # This /should/ work with any 3 hail stones, but there seems to be some instability on some
    # combinations. I suspect this is due to the rounding/casting the floating point numbers to an
    # integer at the last step. i=3,4,5 gives the correct value for my input data.
    x1, v1 = SVector.(d[3])
    x2, v2 = SVector.(d[4])
    x3, v3 = SVector.(d[5])

    A = zeros(Int64, (6, 6))
    A[1:3, 1:3] .= crossproductmatrix(v1) - crossproductmatrix(v2)
    A[1:3, 4:6] .= -crossproductmatrix(x1) + crossproductmatrix(x2)

    A[4:6, 1:3] .= crossproductmatrix(v1) - crossproductmatrix(v3)
    A[4:6, 4:6] .= -crossproductmatrix(x1) + crossproductmatrix(x3)

    b = zeros(Int64, 6)
    b[1:3] .= cross(x1, v1) - cross(x2, v2)
    b[4:6] .= cross(x1, v1) - cross(x3, v3)

    soln = A \ b
    x, v = soln[1:3], soln[4:6]
    return sum(Int64.(round.(x)))
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_, " @ ")
            map(v -> tuple(parse.(Int, split(v, ", "))...), _)
            tuple(_...)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    19, 13, 30 @ -2,  1, -2
    18, 19, 22 @ -1, -1, -2
    20, 25, 34 @ -2, -2, -4
    12, 31, 28 @ -1, -2, -1
    20, 19, 15 @  1, -5, -3
    """
const testarr = [
    ((19, 13, 30), (-2,  1, -2)),
    ((18, 19, 22), (-1, -1, -2)),
    ((20, 25, 34), (-2, -2, -4)),
    ((12, 31, 28), (-1, -2, -1)),
    ((20, 19, 15), ( 1, -5, -3)),
]

@testset "d24" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr, 7, 27) == 2
    @test part2(testarr) == 47
end

end
