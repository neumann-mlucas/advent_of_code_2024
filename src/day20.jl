using Combinatorics
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
TEST_OUT_P1 = 44
TEST_OUT_P2 = 285

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

function walk_dijkstra(M::Matrix{Char})::Matrix{Float64}
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

function find_2t_cheats(D::Matrix{Float64}, lim::Int)::Int
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

    return sum((v for (k, v) in pairs(hist) if k >= lim), init=0)
end

function find_20t_cheats(D::Matrix{Float64}, lim::Int)::Int
    total = 0
    for (p, q) in combinations(CartesianIndices(D), 2)
        if D[p] == Inf || D[q] == Inf
            continue
        end

        manhattan = sum(abs.((p - q).I))
        if manhattan <= 20
            d = abs(D[p] - D[q]) - manhattan
            d >= lim ? total += 1 : nothing
        end
    end
    return total
end

day20p1(inp, lim) = clean_input(inp) |> walk_dijkstra |> x -> find_2t_cheats(x, lim)
day20p2(inp, lim) = clean_input(inp) |> walk_dijkstra |> x -> find_20t_cheats(x, lim)

function main()
    @assert day20p1(TEST_INP, 1) == TEST_OUT_P1
    @assert day20p2(TEST_INP, 50) == TEST_OUT_P2

    input = read(open("dat/day20.txt", "r"), String)
    day20p1(input, 100) |> println
    day20p2(input, 100) |> println
end

main()
