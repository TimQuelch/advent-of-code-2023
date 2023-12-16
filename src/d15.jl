module d15

using Chain
using InlineTest

struct BoxedLens
    label::String
    lens::Int8
    active::Bool
end

Base.show(io::IO, x::BoxedLens) = print(io, "($(x.label), $(x.lens), $(x.active))")

function hash(s)
    v = 0
    for c in s
        v = v + Int(c)
        v *= 17
        v %= 256
    end
    return v
end

function part1(d)
    return mapreduce(hash, +, d)
end

function focuspower(boxes)
    mapreduce(+, enumerate(boxes)) do (i, box)
        mapreduce(+, enumerate(Iterators.filter(l -> l.active, box)), init=0) do (j, lens)
            return i * j * Int(lens.lens)
        end
    end
end

function part2(d)
    boxes = [BoxedLens[] for _ in 1:256]
    for l in d
        opindex = findfirst(c -> c == '-' || c == '=', l)
        label = l[1:opindex-1]
        bi = hash(label) + 1
        existing = findfirst(l -> l.label == label && l.active, boxes[bi])

        if l[opindex] == '-' && !isnothing(existing)
            boxes[bi][existing] = BoxedLens(label, 0, false)
        elseif l[opindex] == '='
            lens = parse(Int, l[opindex+1:end])
            if isnothing(existing)
                push!(boxes[bi], BoxedLens(label, lens, true))
            else
                boxes[bi][existing] = BoxedLens(label, lens, true)
            end
        end
    end
    return focuspower(boxes)
end

function parseinput(io)
    str = @chain io begin
        read(_, String)
        strip
        split(_, ',')
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    """
const testarr = [
    "rn=1", "cm-", "qp=3", "cm=2", "qp-", "pc=4", "ot=9", "ab=5", "pc-", "pc=6", "ot=7"
]

@testset "d15" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 1320
    @test hash("HASH") == 52
    @test part2(testarr) == 145
end

end
