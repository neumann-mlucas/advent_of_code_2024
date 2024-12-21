import Base.Iterators

TEST_INP = """
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"""
TEST_OUT_P1 = 6
TEST_OUT_P2 = 16

function clean_input(inp::String)
    patterns, towels = split(strip(inp), "\n\n")

    patterns = [strip(p) for p in split(patterns, ", ")]
    towels = strip.(split(towels, "\n"))

    return towels, Set(patterns)
end

function try_assemble(towel, patterns, max_prefix)
    if length(towel) == 0
        return 1
    end

    lprefix = min(length(towel), max_prefix)

    for idx in 1:lprefix
        if towel[1:idx] in patterns
            ways = try_assemble(towel[idx+1:end], patterns, max_prefix)
            if ways != 0
                return 1
            end
        end
    end
    return 0
end

function is_valid(towel, patterns)
    max_prefix = maximum(length.(patterns))
    ways = try_assemble(towel, patterns, max_prefix)
    @show ways
    return ways == 1
end

CACHE = Dict{String,Int}()

function assemble(towel, patterns, max_prefix)
    if haskey(CACHE, towel)
        return CACHE[towel]
    end

    if length(towel) == 0
        return 1
    end

    lprefix = min(length(towel), max_prefix)

    total = 0
    for idx in 1:lprefix
        if towel[1:idx] in patterns
            total += assemble(towel[idx+1:end], patterns, max_prefix)
        end
    end
    CACHE[towel] = total
    return total
end

function day19p1(inp)
    towels, patterns = clean_input(inp)
    max_prefix = maximum(length.(patterns))
    return sum(try_assemble(t, patterns, max_prefix) for t in towels)
end

function day19p2(inp)
    empty!(CACHE)
    towels, patterns = clean_input(inp)
    max_prefix = maximum(length.(patterns))
    return sum(assemble(t, patterns, max_prefix) for t in towels)
end

function main()
    @assert day19p1(TEST_INP) == TEST_OUT_P1
    @assert day19p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day19.txt", "r"), String)
    day19p1(input) |> println
    day19p2(input) |> println
end

main()
