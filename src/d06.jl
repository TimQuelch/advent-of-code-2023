module d06

using Chain
using InlineTest

function race(time, dist)
    count = 0
    for i in 0:time
        final = i * (time - i)
        if final > dist
            count += 1
        end
    end
    return count
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
end

end
