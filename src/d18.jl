module d18

using Chain
using InlineTest
using OffsetArrays

const dirlookup = Dict(
    'U' => (-1, 0),
    'D' => (1, 0),
    'R' => (0, 1),
    'L' => (0, -1),
)
const hexdirlookup = Dict(
    '0' => 'R',
    '1' => 'D',
    '2' => 'L',
    '3' => 'U',
)

function part1(d)
    path = [(0, 0)]
    for step in d[1:end-1]
        push!(path, path[end] .+ (step[2] .* dirlookup[step[1]]))
    end

    # Calculate area with shoelace formula
    # zip(p, drop(cycle(p), 1)) gives pairs of points (p1, p2) where p2 is the next point after p1 in the looping path
    accum = mapreduce(+, Iterators.zip(path, Iterators.drop(Iterators.cycle(path), 1))) do (p1, p2)
        p1[2] * p2[1] - p2[2] * p1[1]
    end
    polygon_area = div(accum, 2)

    # Number of boundary points is total number of steps (-1 for the duplicate at cycle start/end)
    boundary_points = mapreduce(s -> s[2], +, d) - 1

    # Calculate number of interior points with Pick's theorem
    interior_points = abs(polygon_area) - div(boundary_points, 2) + 1
    return interior_points + boundary_points
end

function part2(d)
    newinput = map(s -> (hexdirlookup[s[3][end]], parse(Int, s[3][2:end-1]; base=16), ""), d)
    part1(newinput)
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_)
            only(_[1]), parse(Int, _[2]), _[3][2:end-1]
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    R 6 (#70c710)
    D 5 (#0dc571)
    L 2 (#5713f0)
    D 2 (#d2c081)
    R 2 (#59c680)
    D 2 (#411b91)
    L 5 (#8ceee2)
    U 2 (#caa173)
    L 1 (#1b58a2)
    U 2 (#caa171)
    R 2 (#7807d2)
    U 3 (#a77fa3)
    L 2 (#015232)
    U 2 (#7a21e3)
    """
const testarr = [
    ('R', 6, "#70c710"),
    ('D', 5, "#0dc571"),
    ('L', 2, "#5713f0"),
    ('D', 2, "#d2c081"),
    ('R', 2, "#59c680"),
    ('D', 2, "#411b91"),
    ('L', 5, "#8ceee2"),
    ('U', 2, "#caa173"),
    ('L', 1, "#1b58a2"),
    ('U', 2, "#caa171"),
    ('R', 2, "#7807d2"),
    ('U', 3, "#a77fa3"),
    ('L', 2, "#015232"),
    ('U', 2, "#7a21e3"),
]

@testset "d18" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 62
    @test part2(testarr) == 952408144115
end

end
