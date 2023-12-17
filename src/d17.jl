module d17

using Chain
using InlineTest
using DataStructures

const dirslookup = Dict(
    (1, 0) => [(1, 0), (0, -1), (0, 1)],
    (-1, 0) => [(-1, 0), (0, -1), (0, 1)],
    (0, 1) => [(0, 1), (1, 0), (-1, 0)],
    (0, -1) => [(0, -1), (1, 0), (-1, 0)],
)

struct State
    pos::Tuple{Int,Int}
    dir::Tuple{Int,Int}
    samedircount::Int
end

function newstates(d, state::State, cost::Int)
    alldirs = dirslookup[state.dir]
    dirs = filter(dir -> checkbounds(Bool, d, CartesianIndex(state.pos .+ dir)), alldirs)
    if state.samedircount >= 3
        dirs = filter(!=(state.dir), dirs)
    end
    return map(dirs) do dir
        newpos = state.pos .+ dir
        return (
            State(
                newpos,
                dir,
                dir == state.dir ? state.samedircount + 1 : 1,
            ),
            cost + d[newpos...])
    end
end

function newstates2(d, state::State, cost::Int)
    alldirs = dirslookup[state.dir]
    dirs = filter(dir -> checkbounds(Bool, d, CartesianIndex(state.pos .+ dir)), alldirs)

    ns = Tuple{State,Int}[]

    if state.samedircount < 10
        newpos = state.pos .+ state.dir
        if checkbounds(Bool, d, CartesianIndex(newpos))
            s = State(newpos, state.dir, state.samedircount + 1)
            push!(ns, (s, cost + d[newpos...]))
        end
    end

    turndirs = filter(!=(state.dir), dirs)
    for dir in turndirs
        newpos = state.pos .+ 4 .* dir
        if checkbounds(Bool, d, CartesianIndex(newpos))
            s = State(newpos, dir, 4)
            r1, r2 = minmax(state.pos[1], newpos[1])
            c1, c2 = minmax(state.pos[2], newpos[2])
            newcost = sum(d[r1:r2, c1:c2]) - d[state.pos...]
            push!(ns, (s, cost + newcost))
        end
    end

    return ns
end

function dijkstra(queue, finish, visited, newstatefn)
    while !isempty(queue)
        state = dequeue!(queue)

        if state.pos == finish
            return visited[state]
        end

        ns = newstatefn(state, visited[state])
        for (s, cost) in ns
            if !(haskey(visited, s) && cost >= visited[s])
                visited[s] = cost
                enqueue!(queue, s, cost)
            end
        end
    end
end

function part1(d)
    queue = PriorityQueue{State,Int}()
    start = (1, 1)
    s1 = State(start, (1, 0), 0)
    s2 = State(start, (0, 1), 0)
    enqueue!(queue, s1, 0)
    enqueue!(queue, s2, 0)
    visited = Dict(s1 => 0, s2 => 0)
    return dijkstra(queue, size(d), visited, (state, cost) -> newstates(d, state, cost))
end

function part2(d)
    queue = PriorityQueue{State,Int}()
    s1 = State((1, 5), (0, 1), 4)
    s2 = State((5, 1), (1, 0), 4)
    enqueue!(queue, s1, 0)
    enqueue!(queue, s2, 0)
    visited = Dict(s1 => sum(d[1, 2:5]), s2 => sum(d[2:5, 1]))
    return dijkstra(queue, size(d), visited, (state, cost) -> newstates2(d, state, cost))
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            map(c -> parse(Int, c), _)
            reshape(_, 1, :)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    2413432311323
    3215453535623
    3255245654254
    3446585845452
    4546657867536
    1438598798454
    4457876987766
    3637877979653
    4654967986887
    4564679986453
    1224686865563
    2546548887735
    4322674655533
    """
const testarr = [
    2 4 1 3 4 3 2 3 1 1 3 2 3
    3 2 1 5 4 5 3 5 3 5 6 2 3
    3 2 5 5 2 4 5 6 5 4 2 5 4
    3 4 4 6 5 8 5 8 4 5 4 5 2
    4 5 4 6 6 5 7 8 6 7 5 3 6
    1 4 3 8 5 9 8 7 9 8 4 5 4
    4 4 5 7 8 7 6 9 8 7 7 6 6
    3 6 3 7 8 7 7 9 7 9 6 5 3
    4 6 5 4 9 6 7 9 8 6 8 8 7
    4 5 6 4 6 7 9 9 8 6 4 5 3
    1 2 2 4 6 8 6 8 6 5 5 6 3
    2 5 4 6 5 4 8 8 8 7 7 3 5
    4 3 2 2 6 7 4 6 5 5 5 3 3
]
const testarr2 = [
    1 1 1 1 1 1 1 1 1 1 1 1
    9 9 9 9 9 9 9 9 9 9 9 1
    9 9 9 9 9 9 9 9 9 9 9 1
    9 9 9 9 9 9 9 9 9 9 9 1
    9 9 9 9 9 9 9 9 9 9 9 1
]

@testset "d17" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 102
    @test part2(testarr) == 94
    @test part2(testarr2) == 71
end

end
