TEST_INP = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
TEST_OUT_P1 = 2
TEST_OUT_P2 = 4

function clean_input(inp:: String)
    # Split the input into lines, then split each line into integers
    [parse.(Int, split(line)) for line in split(strip(inp), "\n")]
end

function pred(x::Int, rev::Bool=True)::Bool
    # diff between levels 0 < abs(x) <= 3
    cond = 0 < abs(x) <= 3
    # must be an increasing or decreasing sequence
    rev ? cond && x < 0 : cond && x > 0
end

function is_safe(inp::Vector{Int64})::Int
    # Find if levels meet the criteria
    rev = inp[1] > inp[end]
    pred.(diff(inp), rev) |> all
end

function is_safe_with_replacement(inp::Vector{Int64})::Int
    # Replace one value and test if resulting sequence is valid
    if is_safe(inp) == 1
        return 1
    end

    for i in 1:length(inp)
        subset = vcat(inp[1:i-1], inp[i+1:end])
        if is_safe(subset) == 1
            return 1
        end
    end
    return 0
end

day02p1(inp) = clean_input(inp) .|> is_safe |> sum
day02p2(inp) = clean_input(inp) .|> is_safe_with_replacement |> sum

function main()
    @assert day02p1(TEST_INP) == TEST_OUT_P1
    @assert day02p2(TEST_INP) == TEST_OUT_P2
    input = read(open("dat/day02.txt", "r"), String)
    day02p1(input) |> println
    day02p2(input) |> println
end

main()
