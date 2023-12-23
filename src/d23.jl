module d23

using Chain
using InlineTest
using DataStructures

function checkslope(d, dir, i)
    val = d[i]
    validslope = (val == '>' && dir == CartesianIndex(0, 1) ||
        val == '<' && dir == CartesianIndex(0, -1) ||
        val == '^' && dir == CartesianIndex(-1, 0) ||
        val == 'v' && dir == CartesianIndex(1, 0))
    return validslope
end

function findedges(d, i, part1)
    all = map(n -> CartesianIndex(i) + n, CartesianIndex.(((0, 1), (0, -1), (1, 0), (-1, 0))))
    valid = filter(n -> checkbounds(Bool, d, n) && d[n] != '#' && (!part1 || d[n] == '.' || checkslope(d, n - i, n)), all)
    return collect(valid)
end

function buildgraph(d, part1=true)
    nodes = findall(!=('#'), d)
    edges = Dict{CartesianIndex,Vector{Tuple{CartesianIndex,Int}}}()
    for n in nodes
        edges[n] = map(e -> (e, 1), findedges(d, n, part1))
    end
    return edges
end

function reducedgraph(d)
    edges = buildgraph(d, false)

    # while any(es -> length(es == 2), e)
    while (n = findfirst(es -> length(es) == 2, edges)) !== nothing
        # @show n
        (a, b) = edges[n]
        delete!(edges, n)
        if (i = findfirst(e -> e[1] == n, edges[a[1]])) !== nothing
            deleteat!(edges[a[1]], i)
            push!(edges[a[1]], (b[1], a[2] + b[2]))
        end
        if (i = findfirst(e -> e[1] == n, edges[b[1]])) !== nothing
            deleteat!(edges[b[1]], i)
            push!(edges[b[1]], (a[1], a[2] + b[2]))
        end
    end
    return edges
end

function sim(es, finish, oldvisited, current, currentcost)
    visited = deepcopy(oldvisited)
    push!(visited, current)
    alles = es[current]
    notvisited = filter(e -> !in(e[1], visited), alles)
    if isempty(notvisited)
        return in(finish, visited) ? currentcost : 0
    end
    return maximum(n -> sim(es, finish, visited, n[1], currentcost + n[2]), notvisited)
end

function part1(d)
    start = CartesianIndex(1, 2)
    finish = CartesianIndex(size(d, 1), size(d, 2) - 1)
    visited = Set{CartesianIndex}((start,))
    edges = buildgraph(d)
    cost = sim(edges, finish, visited, start, 0)
    return cost
end

function part2(d)
    start = CartesianIndex(1, 2)
    finish = CartesianIndex(size(d, 1), size(d, 2) - 1)
    visited = Set{CartesianIndex}((start,))
    edges = reducedgraph(d)
    cost = sim(edges, finish, visited, start, 0)
    return cost
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
    #.#####################
    #.......#########...###
    #######.#########.#.###
    ###.....#.>.>.###.#.###
    ###v#####.#v#.###.#.###
    ###.>...#.#.#.....#...#
    ###v###.#.#.#########.#
    ###...#.#.#.......#...#
    #####.#.#.#######.#.###
    #.....#.#.#.......#...#
    #.#####.#.#.#########v#
    #.#...#...#...###...>.#
    #.#.#v#######v###.###v#
    #...#.>.#...>.>.#.###.#
    #####v#.#.###v#.#.###.#
    #.....#...#...#.#.#...#
    #.#########.###.#.#.###
    #...###...#...#...#.###
    ###.###.#.###v#####v###
    #...#...#.#.>.>.#.>.###
    #.###.###.#.###.#.#v###
    #.....###...###...#...#
    #####################.#
    """
# const testarr = [
# ]

@testset "d23" begin
    # @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(parseinput(IOBuffer(teststr))) == 94
    @test part2(parseinput(IOBuffer(teststr))) == 154
end

end
