module d22

using Chain
using InlineTest
using Graphs
using DataStructures

function buildcoords(d)
    coords = map(d) do (a, b)
        if a == b
            return [a]
        end
        coords = NTuple{3,Int}[]
        idiff = findfirst(!=(0), a .- b)
        l, h = minmax(a[idiff], b[idiff])
        c = zeros(3)
        for i in l:h
            for j in 1:3
                if j == idiff
                    c[j] = i
                else
                    c[j] = a[j]
                end
            end
            push!(coords, tuple(c...))
        end
        return coords
    end

    return sort(coords, by=cs -> minimum(c -> c[3], cs))
end

function findneighbours(coords, cs)
    below = filter(!in(cs), map(c -> c .+ (0, 0, -1), cs))
    neighbours = findall(coords) do other
        ((length(other) + length(below)) >= abs(other[begin][3] - below[begin][3]) &&
         !isdisjoint(below, other))
    end
    return neighbours
end

function settlebrick(coords, cs)
    new = deepcopy(cs)
    while isempty(findneighbours(coords, new)) && all(c -> c[3] > 1, new)
        new = map(c -> c .+ (0, 0, -1), new)
    end
    return new
end

function settlebricks(coords)
    oldcoords = copy(coords)
    newcoords = Vector{NTuple{3,Int}}[]
    for old in oldcoords
        push!(newcoords, settlebrick(newcoords, old))
    end
    return sort(newcoords, by=cs -> minimum(c -> c[3], cs))
end

function buildgraph(coords)
    edges = NTuple{2,Int}[]

    for (i, cs) in enumerate(coords)
        neighbours = findneighbours(coords, cs)
        newedges = tuple.(i, neighbours)
        typeof(newedges), typeof(edges)
        if !isempty(newedges)
            append!(edges, newedges)
        end
    end

    g = Graphs.SimpleDiGraph(Edge.(edges))
    return g
end

function part1(d)
    coords = buildcoords(d)
    settled = settlebricks(coords)
    g = buildgraph(settled)

    destructible = Set{eltype(g)}()
    for v in vertices(g)
        supporting = inneighbors(g, v)
        if isempty(supporting)
            push!(destructible, v)
        end
        if all(other -> length(outneighbors(g, other)) > 1, supporting)
            push!(destructible, v)
        end
    end

    return length(destructible)
end

function part2(d)
    coords = buildcoords(d)
    settled = settlebricks(coords)
    g = buildgraph(settled)

    @show total = sum(vertices(g)) do v
        falling = Set(v)
        stack = Stack{Int}()
        foreach(n -> push!(stack, n), inneighbors(g, v))
        while !isempty(stack)
            considering = pop!(stack)
            if all(in(falling), outneighbors(g, considering))
                push!(falling, considering)
                foreach(n -> push!(stack, n), inneighbors(g, considering))
            end
        end
        @show v, falling
        return length(falling) - 1
    end
    return total
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_, '~')
            map(_) do c
                @chain c begin
                    split(_, ',')
                    map(i -> parse(Int, i), _)
                    tuple(_...)
                end
            end
            tuple(_...)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    1,0,1~1,2,1
    0,0,2~2,0,2
    0,2,3~2,2,3
    0,0,4~0,2,4
    2,0,5~2,2,5
    0,1,6~2,1,6
    1,1,8~1,1,9
    """
const testarr = [
    ((1, 0, 1), (1, 2, 1)),
    ((0, 0, 2), (2, 0, 2)),
    ((0, 2, 3), (2, 2, 3)),
    ((0, 0, 4), (0, 2, 4)),
    ((2, 0, 5), (2, 2, 5)),
    ((0, 1, 6), (2, 1, 6)),
    ((1, 1, 8), (1, 1, 9)),
]

const smalltest = [((1, 0, 1), (1, 2, 1)), ((0, 0, 2), (2, 0, 2))]
const smallcoords = [
    [(1, 0, 1), (1, 1, 1), (1, 2, 1)],
    [(0, 0, 2), (1, 0, 2), (2, 0, 2)],
]


@testset "d22" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test buildcoords(smalltest) == smallcoords
    @test part1(testarr) == 5
    @test part2(testarr) == 7
end

end
