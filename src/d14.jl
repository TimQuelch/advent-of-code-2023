module d14

using Chain
using InlineTest
using Memoize
using LRUCache

Base.transpose(x::Char) = x

function rollnorth(a)
    for i in 1:size(a, 2)
        for j in 1:size(a, 1)
            if a[j, i] == 'O'
                a[j, i] = '.'
                newpos = findfirst(!=('.'), a[j-1:-1:1, i])
                if isnothing(newpos)
                    a[1, i] = 'O'
                else
                    a[length(j-1:-1:1)-newpos+2, i] = 'O'
                end
            end
        end
    end
    return a
end

function rotateclockwise(a)
    return transpose(a)[:, end:-1:1]
end

function spin(a)
    return a
end

function score(a)
    return mapreduce(+, eachcol(a)) do c
        rocks = findall(==('O'), c)
        if length(rocks) == 0
            return 0
        end
        mapreduce(+, rocks) do i
            return size(c, 1) - i + 1
        end
    end
end

function part1(d)
    a = copy(d)
    return score(rollnorth(a))
end

function part2(d, n=1000000000)
    a = copy(d)
    history = Dict{Vector{CartesianIndex{2}},Int}()
    i = 1
    jumpedahead = false
    while i <= n

        if !jumpedahead
            state = findall(==('O'), a)
            if haskey(history, state)
                oldi = history[state]
                idiff = i - oldi
                ncycles = div(n - i, idiff)
                i = i + ncycles * idiff
                jumpedahead = true
            end
            history[state] = i
        end

        for j in 1:4
            a = rollnorth(a)
            a = rotateclockwise(a)
        end

        i += 1
    end
    return score(a)
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
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
const testarr = [
    'O' '.' '.' '.' '.' '#' '.' '.' '.' '.'
    'O' '.' 'O' 'O' '#' '.' '.' '.' '.' '#'
    '.' '.' '.' '.' '.' '#' '#' '.' '.' '.'
    'O' 'O' '.' '#' 'O' '.' '.' '.' '.' 'O'
    '.' 'O' '.' '.' '.' '.' '.' 'O' '#' '.'
    'O' '.' '#' '.' '.' 'O' '.' '#' '.' '#'
    '.' '.' 'O' '.' '.' '#' 'O' '.' '.' 'O'
    '.' '.' '.' '.' '.' '.' '.' 'O' '.' '.'
    '#' '.' '.' '.' '.' '#' '#' '#' '.' '.'
    '#' 'O' 'O' '.' '.' '#' '.' '.' '.' '.'
]

@testset "d14" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 136
    @test part2(testarr) == 64
end

end
