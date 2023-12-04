module d04

using Chain
using InlineTest
using DataStructures

function part1(d)
    mapreduce(+, d) do card
        winning, have = card
        nWin = length(intersect(winning, have))
        if nWin > 0
            return 2^(nWin - 1)
        else
            return 0
        end
    end
end

function part2Version1(d)
    nWins = map(d) do card
        winning, have = card
        return length(intersect(winning, have))
    end

    stack = Stack{Int}()
    foreach(i -> push!(stack, i), eachindex(d))
    count = length(stack)
    while length(stack) > 0
        i = pop!(stack)
        nWin = nWins[i]
        if nWin > 0
            count = count + nWin
            foreach(i -> push!(stack, i), i+1:i+nWin)
        end
    end
    return count
end

# Each card only adds additional cards. This method starts at the end and works backwards to figure
# out how many total cards each card will produce by summing the cumulative sum of each of the nWin
# following cards.
function part2(d)
    cumulative = zeros(Int, size(d))
    for i in reverse(eachindex(cumulative))
        nWins = length(intersect(d[i]...))
        cumulative[i] = 1 + sum(cumulative[i+1:i+nWins])
    end
    return sum(cumulative)
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            chopprefix(_, r"Card\s+[0-9]+: ")
            split(_, " | ")
            map(_) do side
                s = split(side, " ", keepempty=false)
                return parse.(Int, s)
            end
            tuple(_...)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """
const testarr = [
    ([41, 48, 83, 86, 17], [83, 86, 6, 31, 17, 9, 48, 53])
    ([13, 32, 20, 16, 61], [61, 30, 68, 82, 17, 32, 24, 19])
    ([1, 21, 53, 59, 44], [69, 82, 63, 72, 16, 21, 14, 1])
    ([41, 92, 73, 84, 69], [59, 84, 76, 51, 58, 5, 54, 83])
    ([87, 83, 26, 28, 32], [88, 30, 70, 12, 93, 22, 82, 36])
    ([31, 18, 13, 56, 72], [74, 77, 10, 23, 35, 67, 36, 11])
]

@testset "d04" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 13
    @test part2(testarr) == 30
end

end
