module d07

using Chain
using InlineTest
using DataStructures


handorder = reverse([
    [5],
    [1, 4],
    [2, 3],
    [1, 1, 3],
    [1, 2, 2],
    [1, 1, 1, 2],
    [1, 1, 1, 1, 1]
])

# Count unique cards in hand and return sorted
counthand(hand) = @chain hand counter values collect sort

# Count a hand with jokers. First filter out all the jokers, then add the number of jokers on to the
# card that there is the most of. If all cards are jokes, then return 5 jokers
function counthandjokers(hand)
    filtered = @chain hand filter(!=('J'), _) counthand
    if isempty(filtered)
        return [5]
    end
    filtered[end] += 5 - sum(filtered)
    return filtered
end

order1 = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']
order2 = ['J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A']

# Map cards to indexes in the order. Used for tie-breaks
rankcards(hand, order) = map(c -> findfirst(==(c), order), collect(hand))

function isless(a, b; order=order1, counthand=counthand)
    avals = counthand(a)
    bvals = counthand(b)

    # Determine if which hand has a better 'class' of hand
    arank = findfirst(==(avals), handorder)
    brank = findfirst(==(bvals), handorder)
    if arank < brank
        return true
    end
    if arank > brank
        return false
    end

    # Hands have same class. determine which wins the tie
    acardranks = rankcards(a, order)
    bcardranks = rankcards(b, order)
    for (ac, bc) in zip(acardranks, bcardranks)
        if ac < bc
            return true
        end
        if ac > bc
            return false
        end
    end

    # Hands are equal. This should never happen in the input data that I've been given
    if a == b
        @warn "a == b" a b
    end
    return false
end

function countwinnings(d, order, counthand)
    lt = (a, b) -> isless(a, b; order=order, counthand=counthand)
    sorted = sort(d, by=x->x[1]; lt)
    return mapreduce(+, enumerate(sorted)) do x
        rank, (hand, bid) = x
        winning = rank * bid
        return winning
    end
end

function part1(d)
    return countwinnings(d, order1, counthand)
end

function part2(d)
    return countwinnings(d, order2, counthandjokers)
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_)
            (_[1], parse(Int, _[2]))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
const testarr = [
    ("32T3K", 765),
    ("T55J5", 684),
    ("KK677", 28),
    ("KTJJT", 220),
    ("QQQJA", 483)
]

@testset "d07" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 6440
    @test part2(testarr) == 5905
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
