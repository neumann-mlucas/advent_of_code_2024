TEST_INP = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""
TEST_OUT_P1 = 143
TEST_OUT_P2 = 123

function clean_input(inp::String)
    rules, pages = split(strip(inp), "\n\n")

    rules = [parse.(Int, split(line, "|")) for line in split(rules)]
    pages = [parse.(Int, split(line, ",")) for line in split(pages)]

    rules, pages
end

function gen_isless(A::Int, B::Int)
    function fn(x::Int, y::Int)::Bool
        if x == A && y == B
            return true
        end
        return false
    end
end

function filter_good_pages(rules, pages)
    rules = [gen_isless(a, b) for (a, b) in rules]
    isless = (x, y) -> any(fn(x, y) for fn in rules)

    filter(x -> issorted(x, lt = isless), pages)
end

function sort_bad_pages(rules, pages)
    rules = [gen_isless(a, b) for (a, b) in rules]
    isless = (x, y) -> any(fn(x, y) for fn in rules)

    pages = filter(x -> !issorted(x, lt = isless), pages)
    [sort(p, lt = isless) for p in pages]
end

function middle_elem(arr)
    arr[ceil(Int, length(arr) / 2)]
end

day05p1(inp) = sum(middle_elem(page) for page in filter_good_pages(clean_input(inp)...))
day05p2(inp) = sum(middle_elem(page) for page in sort_bad_pages(clean_input(inp)...))

function main()
    @assert day05p1(TEST_INP) == TEST_OUT_P1
    @assert day05p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day05.txt", "r"), String)
    day05p1(input) |> println
    day05p2(input) |> println
end

main()
