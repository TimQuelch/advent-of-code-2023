module d02

using Chain
using InlineTest

function part1(d)
    mapreduce(+, enumerate(d)) do x
        full = reduce((a, b) -> max.(a, b), x[2])
        if all(full .<= (12, 13, 14))
            return x[1]
        end
        return 0
    end
end

function part2(d)
    mapreduce(+, enumerate(d)) do x
        full = reduce((a, b) -> max.(a, b), x[2])
        return prod(full)
    end
end

function mapgame(x)
    return reduce((a, b) -> a .+ b, map(mapentry, x))
end

function mapentry(x)
    r = match(r"([0-9]+) ([a-z]+)", x)
    if r.captures[2] == "red"
        return (parse(Int, r.captures[1]), 0, 0)
    elseif r.captures[2] == "green"
        return (0, parse(Int, r.captures[1]), 0)
    elseif r.captures[2] == "blue"
        return (0, 0, parse(Int, r.captures[1]))
    end
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            chopprefix(_, r"Game [0-9]+: ")
            split("; ")
            map(x -> split(x, ", "), _)
            map(mapgame, _)
            collect
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """
const teststr2 = """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    """
const testarr = [
    [(4, 0, 3), (1, 2, 6), (0, 2, 0)],
    [(0, 2, 1), (1, 3, 4), (0, 1, 1)],
]

@testset "d02" begin
    @test parseinput(IOBuffer(teststr2)) == testarr
    @test part1(parseinput(IOBuffer(teststr))) == 8
    @test part2(parseinput(IOBuffer(teststr))) == 2286
end

end
