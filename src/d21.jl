module d21

using Chain
using InlineTest
using Polynomials

function sim(d, scale, steps)
    tiles = scale * 2 - 1
    a = repeat(d, outer=(tiles, tiles))
    starts = findall(==('S'), a)
    mid = div(length(starts) + 1, 2)
    start = starts[mid]
    a[starts] .= '.'

    currentsteps = [start]
    for i in 1:steps
        nextsteps = Set{CartesianIndex{2}}()
        for s in currentsteps
            neighboursall = (s,) .+ CartesianIndex.([(1, 0), (0, 1), (-1, 0), (0, -1)])
            neighbours = filter(i -> checkbounds(Bool, a, i) && a[i] == '.', neighboursall)
            foreach(ns -> push!(nextsteps, ns), neighbours)
        end
        currentsteps = nextsteps
    end
    return length(currentsteps)
end

function part1(d, steps=64)
    return sim(d, 1, steps)
end

function part2(d, steps=26501365)
    l = size(d, 1)
    offset = steps % div(steps, l)
    xs = offset .+ collect(0:2) .* l
    ys = map(x -> sim(d, 3, x), xs)
    p = fit(xs, ys)
    return Int(round(p(steps)))
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            reshape(_, 1, :)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    ...........
    .....###.#.
    .###.##..#.
    ..#.#...#..
    ....#.#....
    .##..S####.
    .##..#...#.
    .......##..
    .##.#.####.
    .##..##.##.
    ...........
    """
const testarr = [
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '#' '#' '#' '.' '#' '.'
    '.' '#' '#' '#' '.' '#' '#' '.' '.' '#' '.'
    '.' '.' '#' '.' '#' '.' '.' '.' '#' '.' '.'
    '.' '.' '.' '.' '#' '.' '#' '.' '.' '.' '.'
    '.' '#' '#' '.' '.' 'S' '#' '#' '#' '#' '.'
    '.' '#' '#' '.' '.' '#' '.' '.' '.' '#' '.'
    '.' '.' '.' '.' '.' '.' '.' '#' '#' '.' '.'
    '.' '#' '#' '.' '#' '.' '#' '#' '#' '#' '.'
    '.' '#' '#' '.' '.' '#' '#' '.' '#' '#' '.'
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '.' '.'
]

@testset "d21" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr, 6) == 16
    # @test part2(testarr, 100) == 6536
    # @test part2(testarr, 5000) == 16733044
end

end
