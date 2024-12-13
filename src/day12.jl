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
TEST_OUT_P2 = 65601038650482

const MOVES = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]

function clean_input(inp::String)::Matrix{Char}
    hcat(collect.(split(strip(inp)))...)
end

@inline function inbounds(p::CartesianIndex, m::Matrix)::Bool
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

function calc_fence(m::Matrix{Char})::Int
    seen_area = fill(false, size(m)...)

    total = 0
    for p in CartesianIndices(m)
        if seen_area[p]
            continue
        end

        area = flood_area(p, m, seen_area)
        seen_perm = fill(false, size(m)...)
        perm = flood_perimeter(p, m, seen_perm)
        total += area * perm
    end
    return total
end

function print_grid(m::Matrix{Bool})
    tmp = mapslices(join, Int.(m), dims = 2)
    println.(join(tmp, '\n'))
    println()
end

function print_grid(m::Matrix{Char})
    tmp = mapslices(join, m, dims = 2)
    println.(join(tmp, '\n'))
    println()
end

day12p1(inp) = clean_input(inp) |> calc_fence
# day12p2(inp) = clean_input(inp) |> apply(blink, 75) |> values |> sum

function main()
    m = clean_input(TEST_INP)
    calc_fence(m) |> println

    @assert day12p1(TEST_INP) == TEST_OUT_P1
    # @assert day12p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day12.txt", "r"), String)
    day12p1(input) |> println
    # day12p2(input) |> println
end

main()
