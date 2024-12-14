import Base.Iterators

TEST_INP = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""
TEST_OUT_P1 = 480
TEST_OUT_P2 = 875318608908

struct Arcade
    A::Matrix{Int}
    b::Vector{Int}
end

function clean_input(inp::String)::Vector{Arcade}
    clean_arcade.(split(strip(inp), "\n\n"))
end

function clean_arcade(inp)
    n = [parse(Int, m.match) for m in eachmatch(r"(\d+)", inp)]
    Arcade([n[1] n[3]; n[2] n[4]], [n[5], n[6]])
end

function solveP1(a::Arcade)::Integer
    u = a.A \ a.b
    r = round.(Int, u)
    isapprox(u, r) ? r[1] * 3 + r[2] * 1 : 0
end

function solveP2(a::Arcade)::Integer
    u = a.A \ (a.b .+ 10000000000000)
    r = round.(Int, u)
    isapprox(u, r, atol = 0.01) ? r[1] * 3 + r[2] * 1 : 0
end

day13p1(inp) = clean_input(inp) .|> solveP1 |> sum
day13p2(inp) = clean_input(inp) .|> solveP2 |> sum

function main()
    @assert day13p1(TEST_INP) == TEST_OUT_P1
    @assert day13p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day13.txt", "r"), String)
    day13p1(input) |> println
    day13p2(input) |> println
end

main()
