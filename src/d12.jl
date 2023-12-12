module d12

using Chain
using InlineTest
using Memoize
using LRUCache

# We wrap this in an LRU cache as the nature of these recusion is that we will be checking the same
# substring many times close together. LRU cache size below ~100 starts getting too many misses
@memoize LRU{Tuple{AbstractVector{Char},AbstractVector{Int}},Int}(maxsize=1024) function numarrangements(spring, lengths)
    # There are too many # left over
    if count(==('#'), spring) > sum(lengths)
        return 0
    end
    # There aren't enough #/? left over
    if count(!=('.'), spring) < sum(lengths)
        return 0
    end
    # There's no more to allocate
    if isempty(lengths)
        return 1
    end
    # There's only one length left to allocate, and it's the same as the remaining spring
    if length(lengths) == 1 && length(spring) == only(lengths)
        return 1
    end

    # The next length
    l = lengths[begin]

    # The next set of potential starts are all the ? before the next # and the next # itself
    firsthash = findfirst(==('#'), spring)
    qs = findall(==('?'), spring)
    potential_starts = qs
    if !isnothing(firsthash)
        potential_starts = filter(<(firsthash), qs)
        push!(potential_starts, firsthash)
    end

    # Sum all potentials from all the potential starts
    mapreduce(+, potential_starts) do q
        # Check that we can actually fit the length from this start
        if l > 1
            if !checkbounds(Bool, spring, q+l-1)
                return 0
            end
            if @inbounds any(==('.'), spring[q+1:q+l-1])
                return 0
            end
        end
        # Check that the sequence is terminated
        if checkbounds(Bool, spring, q+l) && @inbounds spring[q+l] == '#'
            return 0
        end

        # Recurse by checking the number of arrangements in the sequence following this allocation
        startnext = q + l + 1
        nextspring = @inbounds @view spring[startnext:end]
        nextlengths = @inbounds @view lengths[2:end]
        val = numarrangements(nextspring, nextlengths)
        return val
    end
end

function part1(d)
    return mapreduce(r -> numarrangements(collect(r[1]), r[2]), +, d)
end

function part2(d)
    newinput = map(d) do r
       join(fill(r[1], 5), '?'), repeat(r[2], 5)
    end
    part1(newinput)
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(' ')
            (first(_), map(x -> parse(Int, x), split(last(_), ',')))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
const testarr = [
    ("???.###", [1, 1, 3]),
    (".??..??...?##.", [1, 1, 3]),
    ("?#?#?#?#?#?#?#?", [1, 3, 1, 6]),
    ("????.#...#...", [4, 1, 1]),
    ("????.######..#####.", [1, 6, 5]),
    ("?###????????", [3, 2, 1]),
]

@testset "d12" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr[1:1]) == 1
    @test part1(testarr[2:2]) == 4
    @test part1(testarr[3:3]) == 1
    @test part1(testarr[4:4]) == 1
    @test part1(testarr[5:5]) == 4
    @test part1(testarr[6:6]) == 10
    @test part1(testarr) == 21
    @test numarrangements(collect("#?###?.???.??????"),  [1,4,2,2,2]) == 6
    @test numarrangements(collect("???.#?????.#???"), [1,1,1,4]) == 16
    @test numarrangements(collect("...?#????????????"), [2, 4, 1]) == 36
    @test numarrangements(collect("??..?????.??"), [2, 1, 1, 2]) == 6
    @test numarrangements(collect("?#.??##??????#?#????"), [1, 4, 1, 6]) == 19
    @test part2(testarr) == 525152
end

end
