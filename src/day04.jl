using LinearAlgebra

TEST_INP_P1 = """
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

day04p1 = find_matches ∘ gen_all ∘ clean_input
# day04p2 = clean_input

function main()
    @assert day04p1(TEST_INP_P1) == TEST_OUT_P1
    # @assert day04p2(TEST_INP_P2) == TEST_OUT_P2

    input = read(open("dat/day04.txt", "r"), String)
    day04p1(input) |> println
    # day04p2(input) |> println
end

main()
