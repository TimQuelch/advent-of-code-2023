module d19
using Chain
using InlineTest

abstract type AbstractRule end

struct Part
    x::Int
    m::Int
    a::Int
    s::Int
end
total(p::Part) = p.x + p.m + p.a + p.s
Base.getindex(p::Part, c::Char) = getproperty(p, Symbol(c))

struct PartRange
    x::Tuple{Int,Int}
    m::Tuple{Int,Int}
    a::Tuple{Int,Int}
    s::Tuple{Int,Int}
end

function PartRange(pr, component, newrange)
    if component == 'x'
        return PartRange(newrange, pr.m, pr.a, pr.s)
    elseif component == 'm'
        return PartRange(pr.x, newrange, pr.a, pr.s)
    elseif component == 'a'
        return PartRange(pr.x, pr.m, newrange, pr.s)
    elseif component == 's'
        return PartRange(pr.x, pr.m, pr.a, newrange)
    end
end

Base.getindex(p::PartRange, c::Char) = getindex(p, Val(c))
Base.getindex(p::PartRange, ::Val{'x'}) = p.x
Base.getindex(p::PartRange, ::Val{'m'}) = p.m
Base.getindex(p::PartRange, ::Val{'a'}) = p.a
Base.getindex(p::PartRange, ::Val{'s'}) = p.s

Base.iterate(a::PartRange) = (a.x, Val('x'))
Base.iterate(a::PartRange, ::Val{'x'}) = (a.m, Val('m'))
Base.iterate(a::PartRange, ::Val{'m'}) = (a.a, Val('a'))
Base.iterate(a::PartRange, ::Val{'a'}) = (a.s, Val('s'))
Base.iterate(::PartRange, ::Val{'s'}) = nothing
Base.length(::PartRange) = 4

fullpartrange() = PartRange(fill((1, 4001), 1:4)...)
emptypartrange() = PartRange(fill((0, 0), 1:4)...)
total(pr::PartRange) = mapreduce(c -> c[2] - c[1], *, pr)
Base.isempty(pr::PartRange) = total(pr) == 0

struct GTRule <: AbstractRule
    component::Char
    value::Int
    dst::String
end

struct LTRule <: AbstractRule
    component::Char
    value::Int
    dst::String
end

struct DefaultRule <: AbstractRule
    dst::String
end

function newdest(workflow::Vector{AbstractRule}, part)
    passedrule = findfirst(r -> rulepass(r, part), workflow)
    return workflow[passedrule].dst
end

function rulepass(rule::GTRule, part)
    return part[rule.component] > rule.value
end

function rulepass(rule::LTRule, part)
    return part[rule.component] < rule.value
end

function rulepass(rule::DefaultRule, part)
    return true
end

function processpart(workflows, part)
    curr = "in"
    while true
        next = newdest(workflows[curr], part)
        if next == "R"
            return false
        elseif next == "A"
            return true
        end
        curr = next
    end
end

function inputrange(rule::GTRule, pr)
    r = pr[rule.component]
    r[1] > rule.value ? r : PartRange(pr, rule.component, (rule.value + 1, r[2]))
end

function nextrange(rule::GTRule, pr)
    r = pr[rule.component]
    r[1] > rule.value ? emptypartrange() : PartRange(pr, rule.component, (r[1], rule.value + 1))
end

function inputrange(rule::LTRule, pr)
    r = pr[rule.component]
    r[2] <= rule.value ? r : PartRange(pr, rule.component, (r[1], rule.value))
end

function nextrange(rule::LTRule, pr)
    r = pr[rule.component]
    r[2] <= rule.value ? emptypartrange() : PartRange(pr, rule.component, (rule.value, r[2]))
end

function inputrange(::DefaultRule, pr)
    return pr
end

function nextrange(::DefaultRule, pr)
    return emptypartrange()
end

function countaccepted(workflows, current_wf, partrange)
    if isempty(partrange) || current_wf == "R"
        return 0
    end
    if current_wf == "A"
        return total(partrange)
    end

    count = 0
    currentrange = partrange
    for r in workflows[current_wf]
        input = inputrange(r, currentrange)
        count += countaccepted(workflows, r.dst, input)
        currentrange = nextrange(r, currentrange)
    end
    return count
end

function part1(d)
    workflows, parts = d
    accepted = filter(p -> processpart(workflows, p), parts)
    return mapreduce(total, +, accepted)
end

function part2(d)
    workflows, _ = d
    return countaccepted(workflows, "in", fullpartrange())
end

function parseinput(io)
    (rulestr, ratingstr) = @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
    end

    workflows = map(split(rulestr, '\n')) do l
        m = match(r"(\w+){(.*)}", l)
        wflabel = m.captures[1]
        rulessplit = split(m.captures[2], ',')
        rules::Vector{AbstractRule} = map(rulessplit[1:end-1]) do rule
            rulematch = match(r"([xmas])([<>])(\d+):(\w+)", rule)
            args = (only(rulematch.captures[1]), parse(Int, rulematch.captures[3]), rulematch.captures[4])
            if rulematch.captures[2] == "<"
                return LTRule(args...)
            end
            return GTRule(args...)
        end
        push!(rules, DefaultRule(rulessplit[end]))

        wflabel => rules
    end

    parts = map(split(ratingstr, '\n')) do part
        m = match(r"{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}", part)
        return Part(map(v -> parse(Int, v), m.captures)...)
    end
    return (Dict(workflows...), parts)
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}
    lnx{m>1548:A,A}
    rfg{s<537:gd,x>2440:R,A}
    qs{s>3448:A,lnx}
    qkq{x<1416:A,crn}
    crn{x>2662:A,R}
    in{s<1351:px,qqz}
    qqz{s>2770:qs,m<1801:hdj,R}
    gd{a>3333:R,R}
    hdj{m>838:A,pv}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    {x=2036,m=264,a=79,s=2244}
    {x=2461,m=1339,a=466,s=291}
    {x=2127,m=1623,a=2188,s=1013}
    """
const teststrshort = """
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    """
const testarr = [
    Dict(
        "px" => [
            LTRule('a', 2006, "qkq"),
            GTRule('m', 2090, "A"),
            DefaultRule("rfg")
        ],
        "pv" => [
            GTRule('a', 1716, "R"),
            DefaultRule("A")
        ],
    ),
    [
        Part(787, 2655, 1222, 2876),
        Part(1679, 44, 2067, 496),
    ]
]

@testset "d19" begin
    @test parseinput(IOBuffer(teststrshort))[1] == testarr[1]
    @test parseinput(IOBuffer(teststrshort))[2] == testarr[2]
    @test part1(parseinput(IOBuffer(teststr))) == 19114
    @test part2(parseinput(IOBuffer(teststr))) == 167409079868000
end

end
