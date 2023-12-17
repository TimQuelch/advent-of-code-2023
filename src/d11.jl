module d11

using Chain
using InlineTest

function expand(d)
    expanded = deepcopy(d)
    rowi, coli = Int[], Int[]
    for i in 1:size(d, 1)
        if all(==('.'), d[i, :])
            push!(rowi, i)
        end
    end
    for j in 1:size(d, 2)
        if all(==('.'), d[:, j])
            push!(coli, j)
        end
    end
    return (rowi, coli)
end

function distsum(d, expandfactor)
    rowi, coli = expand(d)
    gs = findall(==('#'), d)
    return mapreduce(+, enumerate(gs)) do ig
        i, g = ig
        return mapreduce(+, enumerate(gs)) do jo
            j, o = jo
            if i <= j
                return 0
            end
            r1, r2 = minmax(g[1], o[1])
            c1, c2 = minmax(g[2], o[2])

            dist = r2 - r1 + c2 - c1

            xsrow = count(in(rowi), r1:r2)
            xscol = count(in(coli), c1:c2)
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
    @test expand(testarr) == ([4, 8], [3, 6, 9])
    @test part1(testarr) == 374
    @test part2(testarr, 10) == 1030
    @test part2(testarr, 100) == 8410
end

end
