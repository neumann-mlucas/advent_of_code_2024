using DataStructures

TEST_INP = """
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
"""
TEST_OUT_P1 = 10048
TEST_OUT_P2 = 64

const MOVES = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]
U, D, L, R = MOVES

function clean_input(inp::String)::Matrix{Char}
    hcat(collect.(split(strip(inp)))...) |> permutedims
end

@inline function inbounds(p, m)::Bool
    0 < p.I[1] <= size(m)[1] && 0 < p.I[2] <= size(m)[2]
end

function print_grid(m::Matrix{Char})
    mapslices(join, m, dims=2) .|> println
    println()
end

function print_grid(m::Matrix{Bool})
    println("DIST = ", sum(m))
    fn(x) = x ? 'X' : '.'
    mapslices(join, fn.(m), dims=2) .|> println
    println()
end

function get_dist(p::CartesianIndex, q::CartesianIndex)::Int
    if p in (U, D) && q in (L, R)
        return 1001
    end
    if p in (L, R) && q in (U, D)
        return 1001
    end
    return 1
end

struct Step
    loc::CartesianIndex
    dir::CartesianIndex
end

function walk_dijkstra(M::Matrix{Char})
    start = findfirst(x -> x == 'S', M)
    target = findfirst(x -> x == 'E', M)

    dist = fill(Inf, size(M)...)
    dist[start] = 0

    Q = PriorityQueue{Step,Int}()
    Q[Step(start, CartesianIndex(0, 0))] = 0

    while !isempty(Q)
        step = dequeue!(Q)
        p, dir = step.loc, step.dir

        if p == target
            return dist[p], dist
        end

        for move in MOVES
            q = p + move
            if !inbounds(q, M) || M[q] == '#'
                continue
            end

            cost = dist[p] + get_dist(move, dir)
            if cost <= dist[q]
                dist[q] = cost
                Q[Step(q, move)] = cost
            end
        end
    end
    return -1, dist
end

struct Args
    curr::CartesianIndex
    dirc::CartesianIndex
    cost::Int
    seen::Set{CartesianIndex}
end

function walk_bfs(M::Matrix{Char})
    start = findfirst(x -> x == 'S', M)
    target = findfirst(x -> x == 'E', M)

    SEEN = Set()
    LIMIT, DIST = walk_dijkstra(M)

    Q = PriorityQueue{Args,Int}()
    Q[Args(start, CartesianIndex(0, 0), 0, Set())] = 0

    while !isempty(Q)
        arg = dequeue!(Q)
        curr, dirc, cost, seen = arg.curr, arg.dirc, arg.cost, arg.seen

        push!(seen, curr)

        if curr == target
            union!(SEEN, seen)
            continue
        end

        for move in MOVES
            next = curr + move
            if !inbounds(next, M) || M[next] == '#' || (next in seen)
                continue
            end

            next_cost = cost + get_dist(move, dirc)

            # bad adhoc heuristic
            if next_cost - 5000 > DIST[next]
                continue
            end

            # lower bound approximation heuristic
            if next_cost + manhthan(next, target) <= LIMIT
                Q[Args(next, move, next_cost, copy(seen))] = next_cost
            end
        end
    end

    return SEEN
end

manhthan(p, q) = begin
    turn = iszero.((p - q).I) == (false, false)
    sum(abs.((p - q).I)) + (turn ? 1000 : 0)
end

day16p1(inp) = clean_input(inp) |> walk_dijkstra |> x -> Int(x[1])
day16p2(inp) = clean_input(inp) |> walk_bfs |> length

function main()
    @assert day16p1(TEST_INP) == TEST_OUT_P1
    @assert day16p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day16.txt", "r"), String)
    day16p1(input) |> println
    day16p2(input) |> println
end

main()
