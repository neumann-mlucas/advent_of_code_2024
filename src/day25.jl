TEST_INP = """
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
"""
TEST_OUT_P1 = 3
TEST_OUT_P2 = 285

function clean_input(inp::String)::Vector{Matrix{Char}}
    parse_grid(grid) = begin
        hcat(collect.(split(strip(grid)))...) |> permutedims
    end
    parse_grid.(split(strip(inp), "\n\n"))
end

function to_height(m::Matrix{Char})::Vector{Int}
    [sum(col .== '#') - 1 for col in eachcol(m)]
end

function find_matches(grids::Vector{Matrix{Char}})
    keys = [to_height(g) for g in grids if g[1, 1] == '#']
    locks = [to_height(g) for g in grids if g[1, 1] != '#']

    matches = 0
    for lock in locks
        for key in keys
            matches += all((lock .+ key) .< 6)
        end
    end
    matches
end

@inline function inbounds(p, m)::Bool
    0 < p.I[1] <= size(m)[1] && 0 < p.I[2] <= size(m)[2]
end

function print_grid(m::Matrix{Char})
    mapslices(join, m, dims=2) .|> println
    println()
end

day25p1(inp) = clean_input(inp) |> find_matches
day25p2(inp) = clean_input(inp)

function main()
    @assert day25p1(TEST_INP) == TEST_OUT_P1
    # @assert day25p2(TEST_INP) == TEST_OUT_P1

    input = read(open("dat/day25.txt", "r"), String)
    day25p1(input) |> println
    # day25p2(input) |> println
end

main()
