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

struct Guard
    position::CartesianIndex
    state::Char
end

mutable struct BoardState
    guard::Guard
    grid::Matrix{Char}
end

function clean_input(inp::String)::BoardState
    board = hcat([[c for c in line] for line in split(strip(inp), "\n")]...) |> permutedims
    position = findfirst(x -> x == '^', board)
    board[position] = '.'
    BoardState(Guard(position, '^'), board)
end

function print_board(s::BoardState)
    g = copy(s.grid)
    g[s.guard.position] = s.guard.state
    g = mapslices(join, g, dims = 2)
    g = join(join(g, '\n'))
    print("\e[H\e[2J")  # clear screen
    println(g)
    sleep(0.05)
end

function run(board::BoardState)::Int
    seen, done = Set([board.guard.position]), false
    while !done
        board, done = step(board)
        push!(seen, board.guard.position)
    end
    return length(seen) - 1
end

function step(board::BoardState)
    new_position = board.guard.position + toindex(board.guard.state)

    if !(inbounds(board.grid, new_position))
        board.guard = Guard(new_position, board.guard.state)
        return (board, true)
    end

    if board.grid[new_position] == '#'
        board.guard = Guard(board.guard.position, turn(board.guard.state))
    else
        board.guard = Guard(new_position, board.guard.state)
    end

    return (board, false)
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

function find_cycle(board::BoardState)::Int
    seen, done = Set([board.guard]), false
    while !done
        board, done = step(board)

        if board.guard in seen
            return 1
        end
        push!(seen, board.guard)
    end
    return 0
end

function find_all_cycles(board::BoardState)::Int
    guard = Guard(board.guard.position, board.guard.state)

    total = 0
    for p in findall(x -> x == '.', board.grid)
        if p == board.guard.position
            continue
        end

        # set new stone
        board.grid[p] = '#'
        total += find_cycle(board)

        # reset board
        board.grid[p] = '.'
        board.guard = guard
    end
    total
end

day06p1 = run ∘ clean_input
day06p2 = find_all_cycles ∘ clean_input

function main()
    @assert day06p1(TEST_INP) == TEST_OUT_P1
    @assert day06p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day06.txt", "r"), String)
    day06p1(input) |> println
    day06p2(input) |> println
end

main()
