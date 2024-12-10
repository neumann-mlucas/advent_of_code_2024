using Base.Iterators

TEST_INP = "2333133121414131402"
TEST_OUT_P1 = 1928
TEST_OUT_P2 = 2858

function clean_input(inp::String)::Vector{Int}
    parse.(Int, collect(strip(inp)))
end

function toblocks(diskmap::Vector{Int}, id::Int = 0, phase::Bool = true)::Vector{Int}
    if length(diskmap) == 0
        return []
    end

    (num, diskmap) = Iterators.peel(diskmap)
    block = repeat(phase ? [id] : [-1], num)

    return vcat(block, toblocks(collect(diskmap), phase ? id : id + 1, !phase))
end

function reorder_blocks(blocks::Vector{Int})::Vector{Int}
    end_block = findlast(x -> x > -1, blocks)
    free_space = findfirst(x -> x == -1, blocks)

    if free_space > end_block
        return blocks
    end

    blocks[free_space] = blocks[end_block]
    blocks[end_block] = -1

    return reorder_blocks(blocks)
end

function reorder_files(blocks::Vector{Int})::Vector{Int}
    [1, 2, 3]
end

function checksum(blocks::Vector{Int})::Int
    total = 0
    for (index, value) in enumerate(blocks)
        if value == -1
            break
        end
        total += (index - 1) * value
    end
    total
end

day09p1 = checksum ∘ reorder_blocks ∘ toblocks ∘ clean_input
day09p2 = checksum ∘ reorder_files ∘ toblocks ∘ clean_input

function main()
    @assert day09p1(TEST_INP) == TEST_OUT_P1
    # @assert day09p2(TEST_INP) == TEST_OUT_P2

    input = read(open("dat/day09.txt", "r"), String)
    day09p1(input) |> println
    # day09p2(input) |> println
end

main()
