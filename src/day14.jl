import Base.Iterators

TEST_INP = """
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
"""
TEST_OUT_P1 = 12

mutable struct Robot
    p::CartesianIndex
    v::CartesianIndex
end

function clean_input(inp::String)::Vector{Robot}
    clean_robot.(split(strip(inp), "\n"))
end

function clean_robot(inp::SubString)::Robot
    toint(m) = parse(Int, m.match)
    px, py, vx, vy = map(toint, eachmatch(r"(\-?\d+)", inp))
    Robot(CartesianIndex(py, px), CartesianIndex(vy, vx))
end

function move(r::Robot, m::Int, n::Int, t::Int)
    r.p = (((r.p + t * r.v).I .% (m, n)) .+ (m, n)) .% (m, n) |> CartesianIndex
end

function toquadrants(vec::Vector, m::Int, n::Int)::Vector
    cm, cn = floor(Int, m / 2), floor(Int, n / 2)
    [
        filter(x -> x.p.I[1] < cm && x.p.I[2] < cn, vec) |> collect,
        filter(x -> x.p.I[1] < cm && x.p.I[2] > cn, vec) |> collect,
        filter(x -> x.p.I[1] > cm && x.p.I[2] < cn, vec) |> collect,
        filter(x -> x.p.I[1] > cm && x.p.I[2] > cn, vec) |> collect,
    ]
end

safty_factor(robots, m, n) = toquadrants(robots, m, n) .|> length |> prod

function day14p1(inp::String, m::Int, n::Int)::Int
    robots = clean_input(inp)
    for r in robots
        move(r, m, n, 100)
    end
    safty_factor(robots, m, n)
end

function day14p2(inp::String, m::Int, n::Int)::Int
    robots = clean_input(inp)

    safty_factors = []
    for t = 1:10_000
        for r in robots
            move(r, m, n, 1)
        end
        sf = safty_factor(robots, m, n)
        push!(safty_factors, (sf, t))
    end
    minimum(safty_factors)[2]
end

function main()
    @assert day14p1(TEST_INP, 7, 11) == TEST_OUT_P1

    input = read(open("dat/day14.txt", "r"), String)
    day14p1(input, 103, 101) |> println
    day14p2(input, 103, 101) |> println
end

main()
