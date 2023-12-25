module d25

using Chain
using InlineTest
using Graphs
using DataStructures
using Random

function buildgraph(d)
    allnodes = String[]
    for l in d
        push!(allnodes, l[1])
        append!(allnodes, l[2])
    end
    nodes = unique(allnodes)
    nodelookup = Dict(map((in) ->  in[2] => in[1], enumerate(nodes)))

    edges = Tuple{Int,Int}[]
    display(edges)
    for l in d
        for other in l[2]
            push!(edges, (nodelookup[l[1]], nodelookup[other]))
        end
    end
    return SimpleGraph(Edge.(edges))
end

function karger_min_cut(g)
    number_components = nv(g)
    connected_vertices = IntDisjointSets(nv(g))

    for edge in shuffle(collect(edges(g)))
        s = src(edge)
        d = dst(edge)
        if in_same_set(connected_vertices, s, d)
            continue
        end
        union!(connected_vertices, s, d)
        number_components -= 1

        if number_components <= 2
            break
        end
    end

    in_one = count(v -> in_same_set(connected_vertices, 1, v), vertices(g))
    in_other = nv(g) - in_one

    cut_size = count(e -> !in_same_set(connected_vertices, src(e), dst(e)), edges(g))

    return in_one * in_other, cut_size
end

function part1(d)
    g = buildgraph(d)

    res, cutsize = karger_min_cut(g)
    while cutsize != 3
        res, cutsize = karger_min_cut(g)
    end
    return res
end

function part2(d)
    nothing
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_, ": ")
            tuple(_[1], collect(split(_[2], " ")))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    jqt: rhn xhk nvd
    rsh: frs pzl lsr
    xhk: hfx
    cmg: qnr nvd lhk bvb
    rhn: xhk bvb hfx
    bvb: xhk hfx
    pzl: lsr hfx nvd
    qnr: nvd
    ntq: jqt hfx bvb xhk
    nvd: lhk
    lsr: lhk
    rzs: qnr cmg lsr rsh
    frs: qnr lhk lsr
    """
const testarr = [
    ("jqt", ["rhn", "xhk", "nvd"]),
    ("rsh", ["frs", "pzl", "lsr"]),
    ("xhk", ["hfx"]),
    ("cmg", ["qnr", "nvd", "lhk", "bvb"]),
    ("rhn", ["xhk", "bvb", "hfx"]),
    ("bvb", ["xhk", "hfx"]),
    ("pzl", ["lsr", "hfx", "nvd"]),
    ("qnr", ["nvd"]),
    ("ntq", ["jqt", "hfx", "bvb", "xhk"]),
    ("nvd", ["lhk"]),
    ("lsr", ["lhk"]),
    ("rzs", ["qnr", "cmg", "lsr", "rsh"]),
    ("frs", ["qnr", "lhk", "lsr"]),
]

@testset "d25" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 54
    # @test part2(testarr) == nothing
end

end
