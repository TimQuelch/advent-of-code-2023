module d05

using Chain
using InlineTest
using IterTools
using Intervals

function shiftRange(i::AbstractInterval, shift)
    return first(i) + shift .. last(i) + shift
end

function shiftRange(i::IntervalSet, shift)
    return IntervalSet(map(r -> shiftRange(r, shift), convert(Array, i)))
end

function mapRange(seeds, maps)
    mapSrcs = map(m -> m[2] .. m[2] + m[3], maps)

    unmapped = setdiff(seeds, IntervalSet(mapSrcs))
    mapped = map(maps) do m
        intersection = intersect(seeds, m[2] .. (m[2] + m[3]))
        if isempty(intersection)
            return nothing
        end
        shift = m[1] - m[2]
        return shiftRange(intersection, shift)
    end

    return @chain mapped begin
        filter(!(isnothing), _)
        map(x -> something(Some(x)), _)
        reduce(union, [unmapped, _...])
    end
end

function mapInput(n, maps)
    matching = findfirst(map -> in(n, map[2]:map[2]+map[3]), maps)
    if isnothing(matching)
        return n
    end
    return n - maps[matching][2] + maps[matching][1]
end

function part1(d)
    seeds, maps = d

    return mapreduce(min, seeds) do s
        n = s
        for m in maps
            n = mapInput(n, m)
        end
        return n
    end
end

function part2(d)
    seeds, maps = d

    seeds = IntervalSet(map(s -> s[1] .. s[1] + s[2], IterTools.partition(seeds, 2)))
    for m in maps
        seeds = mapRange(seeds, m)
    end
    return first(superset(seeds))
end

function parseinput(io)
    strs = @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
    end
    seeds = @chain strs[1] begin
        chopprefix(_, "seeds: ")
        split(_)
        map(x -> parse(Int, x), _)
    end
    maps = @chain strs[2:end] begin
        map(_) do m
            nums = chopprefix(m, r".* map:\n")
            spl = split(nums, '\n')
            return map(r -> parse.(Int, split(r)), spl)
        end
    end
    return (seeds, maps)
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """
const testarr = ([79, 14, 55, 13],
    [[[50, 98, 2],
            [52, 50, 48]],
        [[0, 15, 37],
            [37, 52, 2],
            [39, 0, 15]],
        [[49, 53, 8],
            [0, 11, 42],
            [42, 0, 7],
            [57, 7, 4]],
        [[88, 18, 7],
            [18, 25, 70]],
        [[45, 77, 23],
            [81, 45, 19],
            [68, 64, 13]],
        [[0, 69, 1],
            [1, 0, 69]],
        [[60, 56, 37],
            [56, 93, 4]]])

@testset "d05" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 35
    @test part2(testarr) == 46
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
