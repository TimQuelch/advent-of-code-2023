module d16

using Chain
using InlineTest
using DataStructures
using StaticArrays

const dirlookup = Dict(
    CartesianIndex(1, 0) => 1,
    CartesianIndex(-1, 0) => 2,
    CartesianIndex(0, 1) => 3,
    CartesianIndex(0, -1) => 4,
)

# \
const backslashlookup = Dict(
    CartesianIndex(1, 0) => CartesianIndex(0, 1),
    CartesianIndex(-1, 0) => CartesianIndex(0, -1),
    CartesianIndex(0, 1) => CartesianIndex(1, 0),
    CartesianIndex(0, -1) => CartesianIndex(-1, 0),
)
# /
const forwardslashlookup = Dict(
    CartesianIndex(1, 0) => CartesianIndex(0, -1),
    CartesianIndex(-1, 0) => CartesianIndex(0, 1),
    CartesianIndex(0, 1) => CartesianIndex(-1, 0),
    CartesianIndex(0, -1) => CartesianIndex(1, 0),
)

function tracebeam(d, pos, dir)
    newpos = pos + dir
    if !checkbounds(Bool, d, newpos)
        return []
    end
    newtile = d[newpos]
    if newtile == '.'
        return ((newpos, dir),)
    elseif newtile == '/'
        return ((newpos, forwardslashlookup[dir]),)
    elseif newtile == '\\'
        return ((newpos, backslashlookup[dir]),)
    elseif newtile == '-'
        if dir[1] == 0
            return ((newpos, dir),)
        else
            return ((newpos, CartesianIndex(0, 1)), (newpos, CartesianIndex(0, -1)))
        end
    elseif newtile == '|'
        if dir[2] == 0
            return ((newpos, dir),)
        else
            return ((newpos, CartesianIndex(1, 0)), (newpos, CartesianIndex(-1, 0)))
        end
    end
    return tuple()
end

function runsim(d, initdir, initpos)
    visited = [MVector(false, false, false, false) for i = 1:size(d, 1), j = 1:size(d, 2)]
    stack = Stack{Tuple{CartesianIndex{2},CartesianIndex{2}}}()
    push!(stack, (initdir, initpos))
    while !isempty(stack)
        pos, dir = pop!(stack)
        if checkbounds(Bool, visited, pos)
            visited[pos][dirlookup[dir]] = true
        end
        newargs = tracebeam(d, pos, dir)
        unvisited = filter(n -> !visited[n[1]][dirlookup[n[2]]], newargs)
        foreach(newarg -> push!(stack, newarg), unvisited)
    end
    return count(any, visited)
end

function part1(d)
    runsim(d, CartesianIndex(1, 0), CartesianIndex(0, 1))
end

function part2(d)
    is = CartesianIndices(d)
    trow = map(i -> (i - CartesianIndex(1, 0), CartesianIndex(1, 0)), is[1, :])
    brow = map(i -> (i + CartesianIndex(1, 0), CartesianIndex(-1, 0)), is[end, :])
    lcol = map(i -> (i - CartesianIndex(0, 1), CartesianIndex(0, 1)), is[:, 1])
    rcol = map(i -> (i + CartesianIndex(0, 1), CartesianIndex(0, -1)), is[:, end])
    allstarts = reduce(vcat, [trow, brow, lcol, rcol])
    return maximum(s -> runsim(d, s...), allstarts)
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

const teststr = raw"""
    .|...\....
    |.-.\.....
    .....|-...
    ........|.
    ..........
    .........\
    ..../.\\..
    .-.-/..|..
    .|....-|.\
    ..//.|....
    """
const testarr = [
    '.' '|' '.' '.' '.' '\\' '.' '.' '.' '.'
    '|' '.' '-' '.' '\\' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '|' '-' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '.' '.' '|' '.'
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '\\'
    '.' '.' '.' '.' '/' '.' '\\' '\\' '.' '.'
    '.' '-' '.' '-' '/' '.' '.' '|' '.' '.'
    '.' '|' '.' '.' '.' '.' '-' '|' '.' '\\'
    '.' '.' '/' '/' '.' '|' '.' '.' '.' '.'
]

@testset "d16" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 46
    @test part2(testarr) == 51
end

end
