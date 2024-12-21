using Base.Iterators
using DataStructures

TEST_INP = """
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"""
TEST_OUT_P1 = 0
TEST_OUT_P2 = "6,1"

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

function walk_dijkstra(M::Matrix{Char})
    start = findfirst(x -> x == 'S', M)
    target = findfirst(x -> x == 'E', M)

    dist = fill(Inf, size(M)...)
    dist[start] = 0

    Q = PriorityQueue{CartesianIndex,Int}()
    Q[start] = 0

    while !isempty(Q)
        p = dequeue!(Q)

        if p == target
            return dist
        end

        for q in [p + move for move in MOVES]
            if !inbounds(q, M) || M[q] == '#'
                continue
            end

            cost = dist[p] + 1
            if cost <= dist[q]
                dist[q] = cost
                Q[q] = cost
            end
        end
    end
    return dist
end

function find_cheats(D::Matrix{Float64})
    pred(v, i) = v[i] != Inf && v[i+1] == Inf && v[i+2] != Inf

    dists = []

    for row in eachrow(D)
        d = [abs(row[i] - row[i+2]) for i in 1:length(row)-2 if pred(row, i)]
        append!(dists, d)
    end

    for col in eachcol(D)
        d = [abs(col[i] - col[i+2]) for i in 1:length(col)-2 if pred(col, i)]
        append!(dists, d)
    end

    hist = Dict{Float64,Int}()
    for d in (dists .- 2)
        hist[d] = get!(hist, d, 0) + 1
    end

    return sum((v for (k, v) in pairs(hist) if k > 100), init=0)
end

day20p1(inp) = clean_input(inp) |> walk_dijkstra |> find_cheats

function day20p2(inp)
    return 1
end

function main()
    @assert day20p1(TEST_INP) == TEST_OUT_P1
    # @assert day20p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day20.txt", "r"), String)
    day20p1(input) |> println
    # day20p2(input) |> println
end

main()
