import Base.Iterators

TEST_INP = """
1
10
100
2024
"""
TEST_OUT_P1 = 37327623
TEST_OUT_P2 = 24

function clean_input(inp::String)::Vector{Int64}
    parse.(Int, split(strip(inp), "\n"))
end

function next(n::Int64)::Int64
    n = xor(n, (n << 6)) & 0xFFFFFF
    n = xor(n, (n >> 5)) & 0xFFFFFF
    n = xor(n, (n << 11)) & 0xFFFFFF
    return n
end

function apply_next(n::Int64)::Int64
    reduce((x, _) -> next(x), 1:2000, init=n)
end

function accumulate_next(n::Int64)::Vector{Int64}
    # return only the last digit
    accumulate((x, _) -> next(x), 1:2000, init=n) .% 10
end

PRICES = Dict()

function populate_prices(v::Vector{Int})
    d = diff(v)
    seen = Set()

    for i in 1:length(d)-3
        seq = tuple(d[i:i+3]...)
        price = v[i+4]
        if !(seq in seen)
            PRICES[seq] = get!(PRICES, seq, 0) + price
            push!(seen, seq)
        end
    end

end

day22p1(inp) = clean_input(inp) .|> apply_next |> sum
day22p2(inp) = begin
    empty!(PRICES)
    clean_input(inp) .|> accumulate_next .|> populate_prices
    maximum(values(PRICES))
end

function main()
    @assert day22p1(TEST_INP) == TEST_OUT_P1
    @assert day22p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day22.txt", "r"), String)
    day22p1(input) |> println
    day22p2(input) |> println
end

main()
