import Base.Iterators

TEST_INP = "125 17"
TEST_OUT_P1 = 55312
TEST_OUT_P2 = 65601038650482

function clean_input(inp::String)::Dict{Int,Int}
    Dict(i=>1 for i in parse.(Int, split(strip(inp))))
end

@inline function apply_rule(val::Int)::Vector{Int}
    if val == 0
        return [1]
    elseif ndigits(val) % 2 == 0
        return Iterators.partition(digits(val), ndigits(val)÷2) .|> undigit
    else 
        return [val * 2024]
    end
end

function blink(stones::Dict{Int,Int})::Dict{Int, Int}
    d = (hist(apply_rule(stone), n) for (stone, n) in pairs(stones))
    mergewith(+, d...)
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

function hist(vec::Vector{Int}, n::Int)::Dict{Int, Int}
    dict = Dict{Int, Int}()

    for val in vec
        haskey(dict, vec) ? dict[val] += n : dict[val] = n
    end

    if length(vec) == 2 && vec[1] == vec[2]
        dict[vec[1]] *= 2
    end

    dict
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
