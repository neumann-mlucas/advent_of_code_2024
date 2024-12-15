using Images
import Base.Iterators

TEST_INP = """
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"""
TEST_OUT_P1 = 1930
TEST_OUT_P2 = 1206

const MOVES = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]
U, D, L, R = MOVES

function clean_input(inp::String)::Matrix{Char}
    hcat(collect.(split(strip(inp)))...)
end

@inline function inbounds(p, m)::Bool
    0 < p.I[1] <= size(m)[1] && 0 < p.I[2] <= size(m)[2]
end

function flood_area(p::CartesianIndex, m::Matrix{Char}, seen::Matrix{Bool})::Int
    seen[p] = true

    total = 1
    for q in [p + move for move in MOVES]
        if inbounds(q, m) && m[q] == m[p] && !seen[q]
            total += flood_area(q, m, seen)
        end
    end
    total
end

function flood_perimeter(p::CartesianIndex, m::Matrix{Char}, seen::Matrix{Bool})::Int
    seen[p] = true

    total = 0
    for q in [p + move for move in MOVES]
        if !inbounds(q, m) || m[p] != m[q]
            total += 1
        elseif !seen[q]
            total += flood_perimeter(q, m, seen)
        end
    end
    total
end

function get_shared_borders(m::Matrix{Bool})::Int
    M = padarray(m, Fill(false, (1, 1)))

    total = 0
    for p in CartesianIndices(M)
        if !inbounds(p, M) || !M[p]
            continue
        end

        # __
        # XP
        if !M[p+U] && M[p+L] && !M[p+U+L]
            total += 1
        end

        # XP
        # __
        if !M[p+D] && M[p+L] && !M[p+D+L]
            total += 1
        end

        # X_
        # P_
        if !M[p+L] && M[p+U] && !M[p+U+L]
            total += 1
        end

        # _X
        # _P
        if !M[p+R] && M[p+U] && !M[p+U+R]
            total += 1
        end
    end
    total
end

function calc_fence(m::Matrix{Char})::Tuple{Int,Int}
    seen_area = fill(false, size(m)...)

    p1, p2 = 0, 0
    for p in CartesianIndices(m)
        if seen_area[p]
            continue
        end

        area = flood_area(p, m, seen_area)
        seen_perm = fill(false, size(m)...)
        perm = flood_perimeter(p, m, seen_perm)
        shared_borders = get_shared_borders(seen_perm)
        p1 += area * perm
        p2 += area * (perm - shared_borders)
    end
    return (p1, p2)
end

day12p1(inp) = clean_input(inp) |> calc_fence |> x -> x[1]
day12p2(inp) = clean_input(inp) |> calc_fence |> x -> x[2]

function main()
    @assert day12p1(TEST_INP) == TEST_OUT_P1
    @assert day12p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day12.txt", "r"), String)
    day12p1(input) |> println
    day12p2(input) |> println
end

main()
