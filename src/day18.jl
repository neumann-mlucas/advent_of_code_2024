using DataStructures

TEST_INP = """
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
"""
TEST_OUT_P1 = 22
TEST_OUT_P2 = "6,1"

const MOVES = [
    CartesianIndex(-1, 0),
    CartesianIndex(1, 0),
    CartesianIndex(0, -1),
    CartesianIndex(0, 1),
]
U, D, L, R = MOVES

function clean_pts(inp::String)
    pts = [parse.(Int, split(line, ",")) for line in split(strip(inp), "\n")]
    [CartesianIndex(y + 1, x + 1) for (x, y) in pts]
end

function clean_input(inp::String, m::Int, n::Int, nbits::Int)::Matrix{Char}
    pts = clean_pts(inp)[1:nbits]
    m = fill(' ', m + 1, n + 1)
    m[pts] .= '#'
    return m
end

@inline function inbounds(p, m)::Bool
    0 < p.I[1] <= size(m)[1] && 0 < p.I[2] <= size(m)[2]
end

@inline function delta(p, q)::Int
    +((p - q).I...)
end

function print_grid(m::Matrix{Char})
    mapslices(join, m, dims = 2) .|> println
    println()
end

function print_grid(m::Matrix{Char}, d::Matrix{Float64}, p)
    trail = [p for p in CartesianIndices(d) if d[p] != Inf]
    n = copy(m)

    n[trail] .= '.'
    n[p] = 'X'
    n[1, 1] = 'S'
    n[size(m)...] = 'T'

    grid = join(mapslices(join, n, dims = 2), "\n")

    print("\e[H\e[2J")
    println(grid)
    sleep(0.02)
end

function walk_dijkstra(M::Matrix{Char})
    start = CartesianIndex(1, 1)
    target = CartesianIndex(size(M)...)

    dist = fill(Inf, size(M)...)
    dist[start] = 0

    Q = PriorityQueue{CartesianIndex,Int}()
    Q[start] = 0

    while !isempty(Q)
        p = dequeue!(Q)

        if p == target
            return dist[p]
        end

        for q in [p + move for move in MOVES]
            if !inbounds(q, M) || M[q] == '#'
                continue
            end

            cost = dist[p] + 1
            if cost <= dist[q]
                dist[q] = cost
                Q[q] = cost
            end
        end
    end
    return -1
end

day18p1(inp, m, n, nbits) = clean_input(inp, m, n, nbits) |> walk_dijkstra

function day18p2(inp, m, n, nbits)
    to_out(p) = string(p.I[2] - 1) * "," * string(p.I[1] - 1)

    pts = clean_pts(inp)
    grid = clean_input(inp, m, n, nbits)

    for p in pts[nbits:end]
        grid[p] = '#'
        if walk_dijkstra(grid) == -1
            return to_out(p)
        end
    end
end

function main()
    @assert day18p1(TEST_INP, 6, 6, 12) == TEST_OUT_P1
    @assert day18p2(TEST_INP, 6, 6, 12)

    input = read(open("dat/day18.txt", "r"), String)
    day18p1(input, 70, 70, 1024) |> println
    day18p2(input, 70, 70, 1024) |> println
end

main()
