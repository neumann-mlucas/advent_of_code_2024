TEST_INP = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"""
TEST_OUT_P1 = 36
TEST_OUT_P2 = 81

const MOVES = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]

function clean_input(inp::String)::Matrix{Int}
    parse.(Int, hcat(collect.(split(strip(inp)))...))
end

function get_scores_p1(m::Matrix{Int})::Int
    total = 0
    for p in findall(x -> x == 0, m)
        seen = fill(false, size(m)...)
        seen[p] = true

        ntrails = walk_trail(p, m, seen)
        total += ntrails
    end
    total
end

function walk_trail(p::CartesianIndex, m::Matrix{Int}, s::Matrix{Bool})::Int
    valid_move(q) = inbounds(q, size(m)...) && (m[q] - m[p]) == 1 && !s[q]

    if m[p] == 9
        return 1
    end

    count = 0
    for move in MOVES
        pnew = p + move
        if valid_move(pnew)
            s[pnew] = true
            count += walk_trail(pnew, m, s)
        end
    end
    return count
end

function get_scores_p2(m::Matrix{Int})
    total = 0
    for p in findall(x -> x == 0, m)
        seen = fill(false, size(m)...)
        seen[p] = true

        ntrails = walk_all_trails(p, m, seen)
        total += ntrails
    end
    total
end

function walk_all_trails(p::CartesianIndex, m::Matrix{Int}, s::Matrix{Bool})::Int
    valid_move(q) = inbounds(q, size(m)...) && (m[q] - m[p]) == 1 && !s[q]

    if m[p] == 9
        return 1
    end

    count = 0
    for move in MOVES
        pnew = p + move
        if valid_move(pnew)
            snew = copy(s)
            snew[pnew] = true
            count += walk_all_trails(pnew, m, snew)
        end
    end
    return count
end

function inbounds(p::CartesianIndex, m::Int, n::Int)::Bool
    0 < p.I[1] <= m && 0 < p.I[2] <= n
end

day10p1 = get_scores_p1 ∘ clean_input
day10p2 = get_scores_p2 ∘ clean_input

function main()
    @assert day10p1(TEST_INP) == TEST_OUT_P1
    @assert day10p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day10.txt", "r"), String)
    day10p1(input) |> println
    day10p2(input) |> println
end

main()
