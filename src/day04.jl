using LinearAlgebra

TEST_INP = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
TEST_OUT_P1 = 18
TEST_OUT_P2 = 9

function clean_input(inp::String)::Matrix{Char}
    hcat([[c for c in line] for line in split(strip(inp), "\n")]...)
end

function gen_horizontal(m::Matrix{Char})::Vector{String}
    mapslices(join, m, dims = 2)[:]
end

function gen_vertical(m::Matrix{Char})::Vector{String}
    mapslices(join, m, dims = 1)[:]
end

function gen_diagonal(m::Matrix{Char})::Vector{String}
    [diag(m, i) for i = -size(m, 1):size(m, 1)] .|> join
end

function backwards(v::Vector{String})::Vector{String}
    [line[end:-1:1] for line in v]
end

function gen_all(m::Matrix{Char})::Vector{String}
    result = Vector{String}()
    d, h, v = gen_diagonal(m), gen_horizontal(m), gen_vertical(m)

    append!(result, d, h, v)
    append!(result, backwards(d), backwards(h), backwards(v))

    vd = gen_diagonal(m[end:-1:1, :])
    append!(result, vd, backwards(vd))

    result
end

function find_matches(inp::Vector{String})::Int
    total = 0
    for string in inp
        total += count("XMAS", string, overlap = true)
    end
    total
end

function count_xmas(m::Matrix{Char})::Int
    (rows, cols), total = size(m), 0
    for idx in CartesianIndices(m)
        i, j = idx.I

        # out of bounds and not A
        if i == 1 || j == 1 || i == rows || j == cols || m[i, j] != 'A'
            continue
        end

        # both diagonals have M and S
        d1 = setdiff(['M', 'S'], [m[i-1, j-1], m[i+1, j+1]]) == []
        d2 = setdiff(['M', 'S'], [m[i-1, j+1], m[i+1, j-1]]) == []

        if d1 && d2
            total += 1
        end
    end
    total
end

day04p1 = find_matches ∘ gen_all ∘ clean_input
day04p2 = count_xmas ∘ clean_input

function main()
    @assert day04p1(TEST_INP) == TEST_OUT_P1
    @assert day04p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day04.txt", "r"), String)
    day04p1(input) |> println
    day04p2(input) |> println
end

main()
