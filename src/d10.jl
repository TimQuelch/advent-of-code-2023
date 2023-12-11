module d10

using Graphs: components
using Chain
using InlineTest
using Graphs

dirlookup = Dict(
    '|' => [(-1, 0), (1, 0)],
    '-' => [(0, -1), (0, 1)],
    'L' => [(-1, 0), (0, 1)],
    'J' => [(-1, 0), (0, -1)],
    '7' => [(1, 0), (0, -1)],
    'F' => [(1, 0), (0, 1)],
    'S' => [],                  # Handled elsewhere
    '.' => [],                  # Handled elsewhere
)

function getedges(d, i)
    ci = CartesianIndices(d)[i]
    dirs = dirlookup[d[i]]
    return filter(dirs) do dir
        cother = ci + CartesianIndex(dir)
        if !checkbounds(Bool, d, cother)
            return false
        end
        other = LinearIndices(d)[cother]
        otherdirs = dirlookup[d[other]]
        if ((0, 0) .- dir) in otherdirs || d[other] == 'S'
            return true
        end
        return false
    end
end

function neighbours(d, i)
    dirs = getedges(d, i)
    if isempty(dirs)
        return []
    end
    neighbours = map(ci -> CartesianIndices(d)[i] + CartesianIndex(ci), dirs)
    return map(i -> LinearIndices(d)[i], neighbours)
end

function buildgraph(d)
    edges::Vector{Tuple{Int,Int}} = []
    nodes = collect(eachindex(d))
    g = SimpleGraph{Int}(length(nodes))

    for node in nodes
        ns = neighbours(d, node)
        if !isempty(ns)
            foreach(n -> add_edge!(g, n, node), ns)
        end
    end
    return g
end

function part1(d)
    g = buildgraph(d)

    # Find the connected component that contains 'S'. This is the loop
    start = findfirst(==('S'), d[:])
    components = connected_components(g)
    loopi = findfirst(c -> !isnothing(findfirst(==(start), c)), components)
    loop = components[loopi]
    subgraph, mapping = induced_subgraph(g, loop)

    # Find the shortest path from the start
    res = Graphs.dijkstra_shortest_paths(subgraph, findfirst(==(start), mapping))

    return Int(maximum(res.dists))
end

cardinaldirs = [(0, 1), (0, -1), (1, 0), (-1, 0)]
function getloopneighbours(d, i, loopindexes)
    cothers = map(ci -> CartesianIndices(d)[i] + CartesianIndex(ci), cardinaldirs)
    cothers = filter(ci -> checkbounds(Bool, d, ci), cothers)
    others = map(ci -> LinearIndices(d)[ci], cothers)

    if i in loopindexes
        return filter(in(loopindexes), others)
    end
    return filter(!in(loopindexes), others)
end

function buildconnectedgraph(d, loopindexes)
    edges::Vector{Tuple{Int,Int}} = []
    nodes = collect(eachindex(d))
    g = SimpleGraph{Int}(length(nodes))
    for node in nodes
        ns = getloopneighbours(d, node, loopindexes)
        if !isempty(ns)
            foreach(n -> add_edge!(g, n, node), ns)
        end
    end
    return g
end

doublelookup = Dict(
    '|' => ['|' '.'; '|' '.'],
    '-' => ['-' '-'; '.' '.'],
    'L' => ['L' '-'; '.' '.'],
    'J' => ['J' '.'; '.' '.'],
    '7' => ['7' '.'; '|' '.'],
    'F' => ['F' '-'; '|' '.'],
    'S' => ['S' '-'; '|' '.'],
    '.' => ['.' '.'; '.' '.'],
)

function doubleresolution(d)
    expanded = map(x -> doublelookup[x], d)
    return reduce(hcat, map(c -> reduce(vcat, c), eachcol(expanded)))
end

function part2Version1(d)
    # Double the resolution of the grid. This ensures that there is a connected path when the loop doubles back on itself
    d = doubleresolution(d)
    g = buildgraph(d)

    # The loop is the connected component that has 'S' in it
    components = connected_components(g)
    start = findfirst(==('S'), d[:])
    loopi = findfirst(c -> !isnothing(findfirst(==(start), c)), components)
    loopindexes = components[loopi]

    # Build the graph where each node in the loop is connected to it's neighbours that are also in
    # the loop. Each node that is not in the loop is connected to it's neighbours that are also not
    # in the loop
    loopgraph = buildconnectedgraph(d, loopindexes)
    loopconnectedcomponents = connected_components(loopgraph)

    # Find the connected components that
    # 1. Are not the component that is the loop
    # 2. Do not contain any of the nodes that are on the edge of the grid
    enclosed = filter(loopconnectedcomponents) do component
        if isempty(intersect(component, loopindexes)) &&
           isempty(intersect(component, LinearIndices(d)[1, :])) &&
           isempty(intersect(component, LinearIndices(d)[end, :])) &&
           isempty(intersect(component, LinearIndices(d)[:, 1])) &&
           isempty(intersect(component, LinearIndices(d)[:, end]))
            return true
        end
        return false
    end

    # Filter the nodes in the enclosed components for those that are 'real' this is the 'top left'
    # value of the 4x4 grid that is created when doubling the resolution
    return mapreduce(+, enclosed) do component
        cis = CartesianIndices(d)
        isreal = i -> cis[i][1] % 2 == 1 && cis[i][2] % 2 == 1
        return length(filter(isreal, component))
    end
end

function part2(d)
    g = buildgraph(d)

    # The loop is the connected component that has 'S' in it
    components = connected_components(g)
    start = findfirst(==('S'), d[:])
    loopi = findfirst(c -> !isnothing(findfirst(==(start), c)), components)
    loopindexes = components[loopi]

    # Count how many north exiting there are left to right
    li = LinearIndices(d)
    count = 0
    for (i, r) in enumerate(eachrow(d))
        isinterior = false
        for (j, x) in enumerate(r)
            if li[i, j] in loopindexes
                if x in ('|', 'L', 'J')
                    isinterior = !isinterior
                end
            elseif isinterior
                count += 1
            end
        end
    end
    return count
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
    .....
    .F-7.
    .|.|.
    .L-J.
    .....
    """
const testarr = [
    '.' '.' '.' '.' '.'
    '.' 'F' '-' '7' '.'
    '.' '|' '.' '|' '.'
    '.' 'L' '-' 'J' '.'
    '.' '.' '.' '.' '.'
]
const teststr2 = """
    7-F7-
    .FJ|7
    SJLL7
    |F--J
    LJ.LJ
    """
const teststr3 = """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
const teststr4 = """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
const teststr5 = """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """


@testset "d10" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(parseinput(IOBuffer(teststr2))) == 8
    @test part2(parseinput(IOBuffer(teststr3))) == 4
    @test part2(parseinput(IOBuffer(teststr4))) == 10
    @test part2(parseinput(IOBuffer(teststr5))) == 8
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
