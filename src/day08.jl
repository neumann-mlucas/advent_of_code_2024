using LinearAlgebra
using Combinatorics

TEST_INP = """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"""
TEST_OUT_P1 = 14
TEST_OUT_P2 = 34

struct AntenaMap
    grid::Matrix{Char}
    antenas::Vector{Char}
end

function Base.:abs(x::CartesianIndex)::Int
    abs(x.I[1]) + abs(x.I[2])
end

function clean_input(inp::String)::AntenaMap
    lines = [[c for c in line] for line in split(strip(inp), "\n")]
    AntenaMap(permutedims(hcat(lines...)), setdiff(inp, ".\n"))
end

function print_grid(m::Matrix{Char})
    board = mapslices(join, m, dims = 2)
    println.(join(board, '\n'))
end

function get_all_antinodes(m::AntenaMap, mult::UnitRange)::Set{CartesianIndex}
    antinodes = Set()
    for antena in m.antenas
        for node in get_antinodes(m.grid, antena, mult)
            push!(antinodes, node)
        end
    end
    return antinodes
end

function get_antinodes(
    grid::Matrix{Char},
    id::Char,
    mult::UnitRange,
)::Vector{CartesianIndex}
    M, N = size(grid)

    anthenas = findall(x -> x == id, grid)
    pairs = combinations(anthenas, 2)

    all_antinodes = []
    for (p, q) in pairs
        p_antinodes = [p + n * (p - q) for n in mult]
        q_antinodes = [q + n * (q - p) for n in mult]
        push!(all_antinodes, [node for node in p_antinodes if inbounds(node, M, N)]...)
        push!(all_antinodes, [node for node in q_antinodes if inbounds(node, M, N)]...)
    end
    all_antinodes
end

function inbounds(p::CartesianIndex, m::Int, n::Int)::Bool
    0 < p.I[1] <= m && 0 < p.I[2] <= n
end

day08p1(inp) = get_all_antinodes(clean_input(inp), 1:1) |> length
day08p2(inp) = get_all_antinodes(clean_input(inp), 0:50) |> length

function main()
    @assert day08p1(TEST_INP) == TEST_OUT_P1
    @assert day08p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day08.txt", "r"), String)
    day08p1(input) |> println
    day08p2(input) |> println
end

main()
