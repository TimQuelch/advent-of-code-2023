module d01

using Chain
using InlineTest

function part1(d)
    mapreduce(+, d) do l
        @chain l begin
            collect
            filter(c -> occursin(r"[0-9]", string(c)), _)
            string(first(_), last(_))
            parse(Int, _)
        end
    end
end


function part2(d)
    lookup = Dict(
        "1" => 1,
        "2" => 2,
        "3" => 3,
        "4" => 4,
        "5" => 5,
        "6" => 6,
        "7" => 7,
        "8" => 8,
        "9" => 9,
        "one" => 1,
        "two" => 2,
        "three" => 3,
        "four" => 4,
        "five" => 5,
        "six" => 6,
        "seven" => 7,
        "eight" => 8,
        "nine" => 9,
    )
    mapreduce(+, d) do l
        @chain l begin
            eachmatch(r"([0-9]|one|two|three|four|five|six|seven|eight|nine)", _, overlap=true)
            collect
            first(_), last(_)
            map(x -> lookup[x.match], _)
            map(string, _)
            string(_...)
            parse(Int, _)
        end
    end
end

function parseinput(io)
    collect(eachline(io))
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
const testarr = [
    "1abc2"
    "pqr3stu8vwx"
    "a1b2c3d4e5f"
    "treb7uchet"
]
const testarr2 = [
    "two1nine",
    "eightwothree",
    "abcone2threexyz",
    "xtwone3four",
    "4nineeightseven2",
    "zoneight234",
    "7pqrstsixteen",
]

@testset "d01" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 142
    @test part2(testarr2) == 281
end

end
