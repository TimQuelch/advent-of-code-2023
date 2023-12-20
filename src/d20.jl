module d20

using Chain
using InlineTest
using DataStructures

abstract type Module end

struct Broadcast <: Module
    dsts::Vector{String}
end

struct FlipFlop <: Module
    dsts::Vector{String}
end

struct Conjunction <: Module
    srcs::Vector{String}
    dsts::Vector{String}
end

function initstate(m::Broadcast)
    return nothing
end

function nextstate(m::Broadcast, pulse, current, src)
    return (newstate=nothing, newpulse=pulse)
end

function initstate(m::FlipFlop)
    return false
end

function nextstate(m::FlipFlop, pulse, current, src)
    if pulse == true
        return (newstate=current, newpulse=nothing)
    end
    return (newstate=!current, newpulse=!current)
end

function initstate(m::Conjunction)
    return falses(length(m.srcs))
end

function nextstate(m::Conjunction, pulse, current, src)
    if length(current) != length(m.srcs)
        error("Conjunction module has $(length(m.srcs)) inputs, but got $(length(current))")
    end
    newstate = copy(current)
    i = findfirst(==(src), m.srcs)

    if isnothing(i)
        error("Conjunction module does not have input $(src)")
    end
    newstate[i] = pulse

    return (newstate=newstate, newpulse=!all(newstate))
end

function part1(d)
    queue = Queue{Tuple{AbstractString,AbstractString,Bool}}()
    mods = Dict(d)
    pairs(mods)
    statesarray = map(collect(mods)) do (label, mod)
        (label, initstate(mod))
    end
    states = Dict{AbstractString, Union{Nothing,Bool,BitVector}}(statesarray)

    truepulsecount = 0
    falsepulsecount = 0
    for _ in 1:1000
        enqueue!(queue, ("broadcaster", "button", false))
        while !isempty(queue)
            (label, src, pulse) = dequeue!(queue)
            if pulse
                truepulsecount += 1
            else
                falsepulsecount += 1
            end
            if !haskey(mods, label)
                continue
            end
            mod = mods[label]
            current = states[label]
            (newstate, newpulse) = nextstate(mod, pulse, current, src)
            states[label] = newstate
            if !isnothing(newpulse)
                for dst in mod.dsts
                    enqueue!(queue, (dst, label, newpulse))
                end
            end
        end
    end
    return truepulsecount * falsepulsecount
end

function detectcycle(mods, start, finish)
    statesarray = map(collect(mods)) do (label, mod)
        (label, initstate(mod))
    end
    states = Dict{AbstractString, Union{Nothing,Bool,BitVector}}(statesarray)
    queue = Queue{Tuple{AbstractString,AbstractString,Bool}}()

    firsthigh::Union{Nothing,Int} = nothing
    buttoncount = 0
    while true
        enqueue!(queue, (start, "broadcaster", false))
        buttoncount += 1
        while !isempty(queue)
            (label, src, pulse) = dequeue!(queue)
            if label == finish && pulse
                if isnothing(firsthigh)
                    firsthigh = buttoncount
                else
                    return buttoncount - firsthigh
                end
            end
            if !haskey(mods, label)
                continue
            end
            mod = mods[label]
            current = states[label]
            (newstate, newpulse) = nextstate(mod, pulse, current, src)
            states[label] = newstate
            if !isnothing(newpulse)
                for dst in mod.dsts
                    enqueue!(queue, (dst, label, newpulse))
                end
            end
        end
    end
end

# Learning from day 8 we assume that they give us a really nice input where LCM is the solution
# - Broadcaster leads to four modules
# - Input to rx is a conjunction with four inputs
# - We make the assumption that there are 4 distinct subgraphs that are cyclical
# - We also assume that the cycles have not prefix before the cycle is entered
# After solving it appears that these were valid assumptions
function part2(d)
    mods = Dict(d)
    starts = mods["broadcaster"].dsts
    finish = findfirst(mod -> in("rx", mod.dsts), mods)
    cycles = map(s -> detectcycle(mods, s, finish), starts)
    return lcm(cycles)
end

function parseinput(io)
    mods = map(eachline(io)) do l
        (label, dststr) = split(l, " -> ")
        dsts = split(dststr, ", ")

        if label == "broadcaster"
            return label => Broadcast(dsts)
        end

        if startswith(label, "&")
            return label[2:end] => Conjunction([], dsts)
        end

        if startswith(label, "%")
            return label[2:end] => FlipFlop(dsts)
        end
    end

    withcon = map(mods) do (label, mod)
        if !isa(mod, Conjunction)
            return (label, mod)
        end

        srcs = filter(mods) do (l, m)
            in(label, m.dsts)
        end

        return (label, Conjunction(map(s -> s[1], srcs), mod.dsts))
    end
    return withcon
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """
const testarr = [
    ("broadcaster", Broadcast(["a", "b", "c"])),
    ("a", FlipFlop(["b"])),
    ("b", FlipFlop(["c"])),
    ("c", FlipFlop(["inv"])),
    ("inv", Conjunction(["c"], ["a"])),
]

const teststr2 = """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """

@testset "d20" begin
    # @test parseinput(IOBuffer(teststr)) == testarr
    # @test parseinput(IOBuffer(teststr))[1] == testarr[1]
    # @test parseinput(IOBuffer(teststr))[2] == testarr[2]
    @test part1(testarr) == 32000000
    @test part1(parseinput(IOBuffer(teststr2))) == 11687500
    # @test part2(testarr) == nothing
end

end
