TEST_INP = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""
TEST_OUT_P1 = 3749
TEST_OUT_P2 = 11387

struct Equation
    result::Any
    args::Any
end

function Base.:+(a::Equation, b::Equation)::Int
    a.result + b.result
end

function Base.:+(a::Int, b::Equation)::Int
    a + b.result
end

function clean_input(inp::String)::Vector{Equation}
    parse_line(r, inp) = Equation(parse(Int, r), parse.(Int, split(inp)))
    inp = [split(line, ":") for line in split(strip(inp), "\n")]
    [parse_line(r, inp) for (r, inp) in inp]
end

function is_valid_p1(curr, tail, goal)
    if curr > goal
        return false
    end

    if length(tail) == 0
        return curr == goal ? true : false
    end

    add = is_valid_p1(curr + tail[1], tail[2:end], goal)
    mul = is_valid_p1(curr * tail[1], tail[2:end], goal)

    return add || mul
end

function filter_equations(filter_fn)
    fn(equations) = filter(e -> filter_fn(e.args[1], e.args[2:end], e.result), equations)
    return fn
end

function is_valid_p2(curr, tail, goal)
    if curr > goal
        2
        return false
    end

    if length(tail) == 0
        return curr == goal ? true : false
    end

    add = is_valid_p2(curr + tail[1], tail[2:end], goal)
    mul = is_valid_p2(curr * tail[1], tail[2:end], goal)
    cat = is_valid_p2(cat_op(curr, tail[1]), tail[2:end], goal)

    return add || mul || cat
end

function cat_op(a::Int, b::Int)::Int
    parse(Int, string(a, b))
end

day07p1 = sum ∘ filter_equations(is_valid_p1) ∘ clean_input
day07p2 = sum ∘ filter_equations(is_valid_p2) ∘ clean_input

function main()
    @assert day07p1(TEST_INP) == TEST_OUT_P1
    @assert day07p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day07.txt", "r"), String)
    day07p1(input) |> println
    day07p2(input) |> println
end

main()
