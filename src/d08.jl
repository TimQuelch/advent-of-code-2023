module d08

using Chain
using InlineTest

function part1(d)
    @show lookup = Dict(d[2])
    curr = "AAA"
    n = 0
    for d in Iterators.cycle(d[1])
        @show curr
        if curr == "ZZZ"
            return n
        end
        if d == 'L'
            n += 1
            @show curr = lookup[curr][1]
        else
            n += 1
            @show curr = lookup[curr][2]
        end
    end
end

function part2(d)
    lookup = Dict(d[2])
    @show curr = collect(filter(s -> endswith(s, 'A'), keys(lookup)))
    n = 0
    for d in Iterators.cycle(d[1])
        if all(s -> endswith(s, 'Z'), curr)
            return n
        end
        i = d == 'L' ? 1 : 2
        n += 1

        for j in eachindex(curr)
            curr[j] = lookup[curr[j]][i]
        end
    end
end

function cyclelength(start, dirs, lookup)
    n = 0
    curr = deepcopy(start)
    firstz = nothing
    zoffsets = Int[]
    for (di, dir) in Iterators.cycle(enumerate(dirs))
        i = dir == 'L' ? 1 : 2
        n += 1
        curr = lookup[curr][i]
        if curr == start
            @show curr, start
        end
        if isnothing(firstz) && endswith(curr, 'Z')
            firstz = (curr, di, n)
            continue
        end
        if !isnothing(firstz) && endswith(curr, 'Z')
            push!(zoffsets, n - firstz[3])
        end
        # @show curr, start, di
        if !isnothing(firstz) && curr == firstz[1] && di == firstz[2]
            return (firstz, zoffsets, n)
        end
    end
end
function part2v2(d)
    lookup = Dict(d[2])
    @show start = collect(filter(s -> endswith(s, 'A'), keys(lookup)))
    @show curr = deepcopy(start)
    @show cyclelengths = map(s -> cyclelength(s, d[1], lookup), start)
    lcm(map(c -> c[1][3], cyclelengths)...)
    # n = 0
    # for (di, dir) in Iterators.cycle(enumerate(d[1]))
    #     if all(s -> endswith(s, 'Z'), curr)
    #         return n
    #     end
    #     i = d == 'L' ? 1 : 2
    #     n += 1

    #     for j in eachindex(curr)
    #         curr[j] = lookup[curr[j]][i]
    #     end
    # end
end

function parseinput(io)
    strs = @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
    end
    dirs = collect(strs[1])
    nodes = map(split(strs[2], '\n')) do l
        m = match(r"([A-Z0-9]+) = \(([A-Z0-9]+), ([A-Z0-9]+)\)", l)
        (m[1], (m[2], m[3]))
    end
    return (dirs, nodes)
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
const testarr = (['R', 'L'], [
    ("AAA", ("BBB", "CCC")),
    ("BBB", ("DDD", "EEE")),
    ("CCC", ("ZZZ", "GGG")),
    ("DDD", ("DDD", "DDD")),
    ("EEE", ("EEE", "EEE")),
    ("GGG", ("GGG", "GGG")),
    ("ZZZ", ("ZZZ", "ZZZ"))
])
const teststr2 = """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
const testarr2 = (['L', 'L', 'R'], [
    ("AAA", ("BBB", "BBB")),
    ("BBB", ("AAA", "ZZZ")),
    ("ZZZ", ("ZZZ", "ZZZ"))
])
const teststr3 = """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
const testarr3 = (['L', 'R'], [
    ("11A", ("11B", "XXX")),
    ("11B", ("XXX", "11Z")),
    ("11Z", ("11B", "XXX")),
    ("22A", ("22B", "XXX")),
    ("22B", ("22C", "22C")),
    ("22C", ("22Z", "22Z")),
    ("22Z", ("22B", "22B")),
    ("XXX", ("XXX", "XXX"))
])

@testset "d08" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test parseinput(IOBuffer(teststr2)) == testarr2
    @test parseinput(IOBuffer(teststr3)) == testarr3
    @test part1(testarr) == 2
    @test part1(testarr2) == 6
    @test part2(testarr3) == 6
end

end
