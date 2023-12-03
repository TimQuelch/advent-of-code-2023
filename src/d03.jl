module d03

using Chain
using InlineTest

# Get the linear indices of the cartesian neighbours of a node in 2D array
function neighbours(d, i)
    neighbours = (CartesianIndices(d)[i],) .+ CartesianIndex.([(1, 0), (1, -1), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1)])
    neighbours = filter(n -> checkbounds(Bool, d, n), neighbours)
    return map(i -> LinearIndices(d)[i], neighbours)
end

function part1(d)
    partnums = []
    for (i, row) in enumerate(eachrow(d))
        # For each number in each row
        for m in eachmatch(r"\d+", string(row...))
            # Get all the neighbours of each number. This will include the indices of the numbers
            # and also duplicates. We don't care
            n = mapreduce(vcat, m.offset:(m.offset+length(m.match)-1)) do j
                neighbours(d, LinearIndices(d)[i, j])
            end

            # Check all the neighbours to see if any are not a '.' or a number
            if !isnothing(match(r"[^.0-9]", string(d[n]...)))
                push!(partnums, parse(Int, m.match))
            end
        end
    end
    return sum(partnums)
end

# Classify each partnum. We need this for part 2 to uniquely identify each partnum.
# Result is a array that is the same size as the input array, with each partnum numbered uniquely
# e.g.
#    467..114..
#    ...*......
#    ..35..633.
#
# transforms to (except '.' as 0)
#    111..222..
#    ..........
#    ..33..444.
function classify(d)
    class = zeros(Int, size(d))
    c = 0
    for (i, row) in enumerate(eachrow(d))
        for m in eachmatch(r"\d+", string(row...))
            c = c + 1
            class[i, m.offset:(m.offset+length(m.match)-1)] .= c
        end
    end
    return class
end

function part2(d)
    class = classify(d)

    return mapreduce(+, findall(==('*'), d)) do i
        n = neighbours(d, i)
        classes = unique(filter(!=(0), class[n]))
        if length(classes) == 2
            return mapreduce(*, classes) do c
                digits = d[findall(==(c), class)]
                return parse(Int, string(digits...))
            end
        else
            return 0
        end
    end
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            Vector
            reshape(_, 1, :)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...\$.*....
    .664.598..
    """
const testarr = [
    '4' '6' '7' '.' '.' '1' '1' '4' '.' '.'
    '.' '.' '.' '*' '.' '.' '.' '.' '.' '.'
    '.' '.' '3' '5' '.' '.' '6' '3' '3' '.'
    '.' '.' '.' '.' '.' '.' '#' '.' '.' '.'
    '6' '1' '7' '*' '.' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '+' '.' '5' '8' '.'
    '.' '.' '5' '9' '2' '.' '.' '.' '.' '.'
    '.' '.' '.' '.' '.' '.' '7' '5' '5' '.'
    '.' '.' '.' '$' '.' '*' '.' '.' '.' '.'
    '.' '6' '6' '4' '.' '5' '9' '8' '.' '.'
]

@testset "d03" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 4361
    @test part2(testarr) == 467835
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
