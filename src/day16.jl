using Images
import Base.Iterators

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
TEST_OUT_P2 = 1206

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

# function print_grid(m::Matrix{Char})
#     mapslices(join, m, dims=2) .|> println
#     println()
# end
#
# function print_grid(m::Matrix{Bool})
#     println("DIST = ", sum(m))
#     fn(x) = x ? 'X' : '.'
#     mapslices(join, fn.(m), dims=2) .|> println
#     println()
# end
#
# function print_grid(m::Matrix{Bool}, p::Int)
#     println("COST = ", p)
#     println("DIST = ", sum(m))
#     fn(x) = x ? 'X' : '.'
#     mapslices(join, fn.(m), dims=2) .|> println
#     println()
# end

function get_dist(p::CartesianIndex, q::CartesianIndex)::Int
    if p in (U, D) && q in (L, R)
        return 1001
    end
    if p in (L, R) && q in (U, D)
        return 1001
    end
    return 1
end

function walk_dijkstra(s::CartesianIndex, M::Matrix{Char})
    dist = fill(Inf, size(M)...)
    dist[s] = 0

    Q = [(s, CartesianIndex(0, 0))]
    while !isempty(Q)
        p, dir = popfirst!(Q)

        if M[p] == 'E'
            return dist[p]
        end

        for move in MOVES
            q = p + move

            if !inbounds(q, M) || M[q] == '#'
                continue
            end

            cost = dist[p] + get_dist(move, dir)

            if cost <= dist[q]
                dist[q] = cost
                push!(Q, (q, move))
            end
        end
        sort!(Q, by=i -> dist[i[1]])
    end
    return -1
end

function get_paths(m::Matrix{Char})
    p = findfirst(x -> x == 'S', m)
    walk_dijkstra(p, m)
end

day16p1(inp) = clean_input(inp) |> get_paths |> Int
# day16p2(inp) = clean_input(inp) |> calc_fence |> x -> x[2]

function main()
    @assert day16p1(TEST_INP) == TEST_OUT_P1
    # @assert day16p2(TEST_INP) == TEST_OUT_P2
    #
    input = read(open("dat/day16.txt", "r"), String)
    day16p1(input) |> println
    # day16p2(input) |> println
end

main()
