import Base.Iterators

TEST_INP = """
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
"""
TEST_OUT_P1 = 10092
TEST_OUT_P2 = 9021

const U, D, L, R = [
    CartesianIndex(-1, +0),
    CartesianIndex(+1, +0),
    CartesianIndex(+0, -1),
    CartesianIndex(+0, +1),
]
const MAPPING = Dict('^' => U, 'v' => D, '>' => R, '<' => L)
const IMAPPING = Dict(v => k for (k, v) in pairs(MAPPING))

mutable struct Puzzle
    grid::Matrix{Char}
    robot::CartesianIndex
    moves::Vector{CartesianIndex}
end

function clean_input(inp::String)::Puzzle
    grid, moves = split(strip(inp), "\n\n")

    grid = hcat(collect.(split(grid))...) |> permutedims
    robot = findfirst(x -> x == '@', grid)
    moves = [MAPPING[char] for char in replace(strip(moves), "\n" => "")]

    return Puzzle(grid, robot, moves)
end

function print_puzzle(p::Puzzle)
    g = copy(p.grid)
    g = mapslices(join, g, dims = 2)

    print("\e[H\e[2J")
    println()
    println("Move: ", IMAPPING[p.moves[1]])
    println.(g)
    println()

    sleep(0.10)
end

function rpush(g::Matrix{Char}, p::CartesianIndex, d::CartesianIndex)::Bool
    # true: no move has made
    # false: a move has made

    # cases for pushing a stone
    if g[p] == '#'
        return false
    end

    # cases for direct push from the robot
    if g[p] == '@' && g[p+d] == '#'
        return false
    end

    if g[p] == '@' && g[p+d] == '.'
        g[p], g[p+d] = '.', '@'
        return true
    end

    if g[p] == '@' && g[p+d] == 'O'
        if rpush(g, p + d, d)
            g[p], g[p+d] = '.', '@'
            return true
        end
        return false
    end

    # cases for pushing a box
    if g[p] == 'O' && g[p+d] == '#'
        return false
    end

    if g[p] == 'O' && g[p+d] == '.'
        g[p], g[p+d] = '.', 'O'
        return true
    end

    if g[p] == 'O' && g[p+d] == 'O'
        if rpush(g, p + d, d)
            g[p], g[p+d] = '.', 'O'
            return true
        end
        return false
    end
end

function move(p::Puzzle, m::CartesianIndex)
    if rpush(p.grid, p.robot, m)
        p.robot = p.robot + m
    end
end

function run(p::Puzzle)::Vector{CartesianIndex}
    for m in p.moves
        move(p, m)
    end
    # print_puzzle(p)
    findall(x -> x == 'O', p.grid)
end

function checksum(p::CartesianIndex)::Int
    x, y = p.I .- (1, 1)
    return 100 * x + y
end

day15p1(inp) = clean_input(inp) |> run .|> checksum |> sum

function day15p2(inp::String)::Int
    0
end

function main()
    @assert day15p1(TEST_INP) == TEST_OUT_P1

    input = read(open("dat/day15.txt", "r"), String)
    day15p1(input) |> println
    # day15p2(input) |> println
end

main()
