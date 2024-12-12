import Base.Iterators

TEST_INP = "125 17"
TEST_OUT_P1 = 55312
TEST_OUT_P2 = 65601038650482

function clean_input(inp::String)::Dict{Int,Int}
    Dict(i => 1 for i in parse.(Int, split(strip(inp))))
end

function blink(stones::Dict{Int,Int})::Dict{Int,Int}
    next = Dict{Int,Int}()

    for (k, v) in pairs(stones)
        if k == 0
            next[1] = get(next, 1, 0) + v
        elseif ndigits(k) % 2 == 0
            a, b = Iterators.partition(digits(k), ndigits(k) ÷ 2) .|> undigit
            next[a] = get(next, a, 0) + v
            next[b] = get(next, b, 0) + v
        else
            next[k*2024] = get(next, k * 2024, 0) + v
        end
    end

    return next
end

function undigit(d)
    s = zero(eltype(d))
    mult = one(eltype(d))
    for val in d
        s += val * mult
        mult *= 10
    end
    return s
end

apply(f::Function, n::Int) = reduce(∘, fill(f, n))

day11p1(inp) = clean_input(inp) |> apply(blink, 25) |> values |> sum
day11p2(inp) = clean_input(inp) |> apply(blink, 75) |> values |> sum

function main()
    @assert day11p1(TEST_INP) == TEST_OUT_P1
    @assert day11p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day11.txt", "r"), String)
    day11p1(input) |> println
    day11p2(input) |> println
end

main()
