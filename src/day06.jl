using LinearAlgebra

TEST_INP = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
TEST_OUT_P1 = 41
TEST_OUT_P2 = 6

mutable struct BoardState
    position::CartesianIndex
    board::Matrix{Char}
end

function clean_input(inp::String)::BoardState
    board = hcat([[c for c in line] for line in split(strip(inp), "\n")]...) |> permutedims
    position = findfirst(x -> x == '^', board)
    BoardState(position, board)
end

function run(state::BoardState)::Int
    seen, done = Set([state.position]), false
    while !done
        # print_board(state)
        state, done = step(state)
        push!(seen, state.position)
    end
    return length(seen)
end

function print_board(s::BoardState)
    t = join(mapslices(join, s.board, dims = 2), '\n')
    print("\e[H\e[2J")  # clear screen
    println(join(t, '\n'))
    sleep(0.1)
end

function step(state::BoardState)
    guard = state.board[state.position]
    new_position = state.position + toindex(guard)

    if !(inbounds(state.board, new_position))
        return (state, true)
    end

    if state.board[new_position] == '#'
        state.board[state.position] = turn(guard)
    else
        state.board[state.position] = '.'
        state.board[new_position] = guard
        state.position = new_position
    end

    return (state, false)
end

function toindex(guard::Char)::CartesianIndex
    return guard == '^' ? CartesianIndex(-1, 0) :
           guard == '>' ? CartesianIndex(0, +1) :
           guard == 'v' ? CartesianIndex(+1, 0) :
           guard == '<' ? CartesianIndex(0, -1) : CartesianIndex(0, 0)
end

function inbounds(m::Matrix{Char}, idx::CartesianIndex)
    return 1 <= idx[1] <= size(m, 1) && 1 <= idx[2] <= size(m, 2)
end

function turn(guard::Char)::Char
    return guard == '^' ? '>' :
           guard == '>' ? 'v' : guard == 'v' ? '<' : guard == '<' ? '^' : guard
end

day06p1 = run ∘ clean_input
day06p2 = run ∘ clean_input

function main()
    @assert day06p1(TEST_INP) == TEST_OUT_P1
    # @assert day06p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day06.txt", "r"), String)
    day06p1(input) |> println
    # day06p2(input) |> println
end

main()
