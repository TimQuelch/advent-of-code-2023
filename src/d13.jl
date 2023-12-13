module d13

using Chain
using InlineTest

function checkcolreflection(a)::Union{Int, Nothing}
    for i in 1:(size(a, 2)-1)
        reflectsize = min(i, size(a, 2) - i)
        if all(j -> a[:, i-j+1] == a[:, i+j], 1:reflectsize)
            return i
        end
    end
    return nothing
end

function findcolsmudge(a)
    for i in 1:(size(a, 2)-1)
        reflectsize = min(i, size(a, 2) - i)
        l = a[:, i-reflectsize+1:i]
        r = a[:, i+reflectsize:-1:i+1]
        diff = xor.(l, r)
        if count(==(true), diff) == 1
            return i
        end
    end
    return nothing
end

function checkreflection(d, checkfn)
    mapreduce(+, d) do a
        bools = a .== '#'
        horizontal = checkfn(bools)
        if !isnothing(horizontal)
            return something(horizontal)
        end
        vertical = checkfn(transpose(bools))
        return 100 * something(vertical)
    end
end

function part1(d)
    checkreflection(d, checkcolreflection)
end

function part2(d)
    checkreflection(d, findcolsmudge)
end

function parseinput(io)
    strs = @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
    end
    map(strs) do s
        mapreduce(vcat, split(s, '\n')) do l
            reshape(collect(l), 1, :)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """
const testarr = [
    [
        '#' '.' '#' '#' '.' '.' '#' '#' '.'
        '.' '.' '#' '.' '#' '#' '.' '#' '.'
        '#' '#' '.' '.' '.' '.' '.' '.' '#'
        '#' '#' '.' '.' '.' '.' '.' '.' '#'
        '.' '.' '#' '.' '#' '#' '.' '#' '.'
        '.' '.' '#' '#' '.' '.' '#' '#' '.'
        '#' '.' '#' '.' '#' '#' '.' '#' '.'
    ], [
        '#' '.' '.' '.' '#' '#' '.' '.' '#'
        '#' '.' '.' '.' '.' '#' '.' '.' '#'
        '.' '.' '#' '#' '.' '.' '#' '#' '#'
        '#' '#' '#' '#' '#' '.' '#' '#' '.'
        '#' '#' '#' '#' '#' '.' '#' '#' '.'
        '.' '.' '#' '#' '.' '.' '#' '#' '#'
        '#' '.' '.' '.' '.' '#' '.' '.' '#'
    ]
]

@testset "d13" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 405
    @test part2([testarr[1]]) == 300
    @test part2([testarr[2]]) == 100
    @test part2(testarr) == 400
end

end
