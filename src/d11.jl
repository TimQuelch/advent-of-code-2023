module d11

using Chain
using InlineTest

function expand(d)
    expanded = deepcopy(d)
    for i in 1:size(d, 1)
        if all(==('.'), d[i, :])
            expanded[i, :] .= 'x'
        end
    end
    for j in 1:size(d, 2)
        if all(==('.'), d[:, j])
            expanded[:, j] .= 'x'
        end
    end
    return expanded
end

function distsum(d, expandfactor)
    expanded = expand(d)
    gs = findall(==('#'), expanded)
    return mapreduce(+, enumerate(gs)) do ig
        i, g = ig
        return mapreduce(+, enumerate(gs)) do jo
            j, o = jo
            if i <= j
                return 0
            end
            dist = abs(g[1] - o[1]) + abs(g[2] - o[2])

            rowi = map(i -> CartesianIndex(g[1], i), min(o[2], g[2]):max(o[2], g[2]))
            coli = map(i -> CartesianIndex(i, g[2]), min(o[1], g[1]):max(o[1], g[1]))
            xsrow = count(==('x'), expanded[rowi])
            xscol = count(==('x'), expanded[coli])
            xs = xsrow + xscol
            return (dist - xs) + xs * expandfactor
        end
    end
end

function part1(d)
    return distsum(d, 2)
end

function part2(d, expandfactor=1000000)
    return distsum(d, expandfactor)
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
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """
const testarr = [
    '.' '.' '.' '#' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '.' '#' '.' '.'
    '#' '.' '.' '.' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '#' '.' '.' '.'
    '.' '#' '.' '.' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '#'
    '.' '.' '.' '.' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '.' '#' '.' '.'
    '#' '.' '.' '.' '#' '.' '.' '.' '.' '.'
 ]
const testarr2 = [
    '.' '.' 'x' '#' '.' 'x' '.' '.' 'x' '.'
    '.' '.' 'x' '.' '.' 'x' '.' '#' 'x' '.'
    '#' '.' 'x' '.' '.' 'x' '.' '.' 'x' '.'
    'x' 'x' 'x' 'x' 'x' 'x' 'x' 'x' 'x' 'x'
    '.' '.' 'x' '.' '.' 'x' '#' '.' 'x' '.'
    '.' '#' 'x' '.' '.' 'x' '.' '.' 'x' '.'
    '.' '.' 'x' '.' '.' 'x' '.' '.' 'x' '#'
    'x' 'x' 'x' 'x' 'x' 'x' 'x' 'x' 'x' 'x'
    '.' '.' 'x' '.' '.' 'x' '.' '#' 'x' '.'
    '#' '.' 'x' '.' '#' 'x' '.' '.' 'x' '.'
 ]

@testset "d11" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test expand(testarr) == testarr2
    @test part1(testarr) == 374
    @test part2(testarr, 10) == 1030
    @test part2(testarr, 100) == 8410
end

end
