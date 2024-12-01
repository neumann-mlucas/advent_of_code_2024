TEST_INP = """
3   4
4   3
2   5
1   3
3   9
3   3
"""
TEST_OUT_P1 = 11
TEST_OUT_P2 = 31

function clean_input(inp:: String)::Matrix{Int64}
    # Split the input into lines, then split each line into integers
    hcat([parse.(Int, split(line)) for line in split(strip(inp), "\n")]...)
end

function sum_distances(inp::Matrix{Int64})::Int
    # Sort the two matrix columns and sum the differences
    sort(inp[1,:]) - sort(inp[2,:]) .|> abs |> sum
end

function sim_scores(inp::Matrix{Int64})::Int
    # Similarity score btw column 1 and 2
    l1, l2 = inp[1,:], inp[2,:]
    score(x) = x * sum((==(x)).(l2))
    score.(l1) |> sum
end

day01p1 = sum_distances ∘ clean_input
day01p2 = sim_scores ∘ clean_input

function main()
    @assert day01p1(TEST_INP) == TEST_OUT_P1
    @assert day01p2(TEST_INP) == TEST_OUT_P2
    input = read(open("dat/day01.txt", "r"), String)
    day01p1(input) |> println
    day01p2(input) |> println
end

main()
