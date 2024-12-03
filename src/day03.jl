TEST_INP_P1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
TEST_INP_P2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
TEST_OUT_P1 = 161
TEST_OUT_P2 = 48

function run_multiplication(inp::String)::Int
    total = 0
    for m in eachmatch(r"mul\((\d{1,3}),(\d{1,3})\)", inp)
        total += parse(Int, m[1]) * parse(Int, m[2])
    end
    total
end

function run_do_multiplication(inp::String)::Int
    pattern = r"do\(\)|don't\(\)|mul\((\d{1,3}),(\d{1,3})\)"

    total, active = 0, true
    for m in eachmatch(pattern, inp)
        if m.match == "do()"
            active = true
        elseif m.match == "don't()"
            active = false
        elseif active
            total += parse(Int, m[1]) * parse(Int, m[2])
        end
    end
    return total
end

day03p1 = run_multiplication
day03p2 = run_do_multiplication

function main()
    @assert day03p1(TEST_INP_P1) == TEST_OUT_P1
    @assert day03p2(TEST_INP_P2) == TEST_OUT_P2

    input = read(open("dat/day03.txt", "r"), String)
    day03p1(input) |> println
    day03p2(input) |> println
end

main()
