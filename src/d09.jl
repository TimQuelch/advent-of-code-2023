module d09

using Chain
using InlineTest
using Polynomials

function predictVersion1(r)
    diffs = [r]
    while any(!=(0), diffs[end])
        push!(diffs, diff(diffs[end]))
    end
    inc = 0
    for i in length(diffs)-1:-1:1
        inc = diffs[i][end] + inc
    end
    return inc
end

function predictbackVersion2(r)
    diffs = [r]
    while any(!=(0), diffs[end])
        push!(diffs, diff(diffs[end]))
    end
    inc = 0
    for i in length(diffs)-1:-1:1
        inc = diffs[i][begin] - inc
    end
    return inc
end

function predict(ys, x)
    p = fit(eachindex(ys), ys)
    return Int(round(p(x)))
end

function part1(d)
    mapreduce(ys -> predict(ys, length(ys) + 1), +, d)
end

function part2(d)
    mapreduce(ys -> predict(ys, 0), +, d)
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_)
            parse.(Int, _)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
const testarr = [
    [0, 3, 6, 9, 12, 15],
    [1, 3, 6, 10, 15, 21],
    [10, 13, 16, 21, 30, 45],
]

@testset "d09" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 114
    @test part2(testarr) == 2
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
