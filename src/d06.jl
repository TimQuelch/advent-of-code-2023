module d06

using Chain
using InlineTest

function raceVersion1(time, dist)
    count = 0
    for i in 0:time
        final = i * (time - i)
        if final > dist
            count += 1
        end
    end
    return count
end

# Find number of integers between the solutions of 0 = D - t * (t - T)
# Because the bounds are open so we need to force floor and ceil to
# round on integers with next/prevfloat
function race(time, dist)
    t1 = (time - sqrt(time^2 - 4 * dist)) / 2
    t2 = (time + sqrt(time^2 - 4 * dist)) / 2
    return Int(floor(prevfloat(t2)) - ceil(nextfloat(t1)) + 1)
end

function part1(d)
    mapreduce(race, *, d...)
end

joinraces(nums) = parse(Int, string(string.(nums)...))

function part2(d)
    return race(map(joinraces, d)...)
end

function parseinput(io)
    strs = @chain io begin
        read(_, String)
        strip
        split(_, "\n")
    end
    times = parse.(Int, split(chopprefix(strs[1], "Time: ")))
    distance = parse.(Int, split(chopprefix(strs[2], "Distance: ")))
    return (times, distance)
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Time:      7  15   30
    Distance:  9  40  200
    """
const testarr = ([7, 15, 30], [9, 40, 200])

@testset "d06" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 288
    @test part2(testarr) == 71503
    for (t, d) in zip(testarr...)
        @test race(t, d) == raceVersion1(t, d)
    end
end

end
