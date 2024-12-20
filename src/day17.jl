import Base.Iterators

TEST_INP_P1 = """
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"""
TEST_INP_P2 = """
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
"""

TEST_OUT_P1 = "4,6,3,5,6,3,5,2,1,0"
TEST_OUT_P2 = 117440

mutable struct Computer
    A::Int
    B::Int
    C::Int
    instructions::Vector{Int}
    ptr::Int
end

function clean_input(inp::String)::Computer
    registers, program = split(strip(inp), "\n\n")

    toint(m) = parse(Int, m.match)
    A, B, C = map(toint, eachmatch(r"(\d+)", registers))
    instructions = map(toint, eachmatch(r"(\d+)", program))

    return Computer(A, B, C, instructions, 1)
end

function run(c::Computer)::Vector{Int}
    output = []
    while c.ptr <= length(c.instructions)
        opcode = c.instructions[c.ptr]
        operand = c.instructions[c.ptr+1]

        c, stdout = exec(opcode, operand, c)
        !isnothing(stdout) ? push!(output, stdout) : nothing

        c.ptr += 2
    end
    output
end

function exec(opcode, operand, computer)
    return opcode == 0 ? adv(operand, computer) :
           opcode == 1 ? bxl(operand, computer) :
           opcode == 2 ? bst(operand, computer) :
           opcode == 3 ? jnz(operand, computer) :
           opcode == 4 ? bxc(operand, computer) :
           opcode == 5 ? out(operand, computer) :
           opcode == 6 ? bdv(operand, computer) :
           opcode == 7 ? cdv(operand, computer) : ("", computer)
end

function combo(op, c)
    return op == 0 ? 0 :
           op == 1 ? 1 :
           op == 2 ? 2 :
           op == 3 ? 3 :
           op == 4 ? c.A :
           op == 5 ? c.B :
           op == 6 ? c.C :
           op == 7 ? 0 : 0
end

function adv(op, c)
    c.A = floor(Int, c.A / (2^combo(op, c)))
    (c, nothing)
end

function bxl(op, c)
    c.B = xor(c.B, op)
    (c, nothing)
end

function bst(op, c)
    c.B = combo(op, c) % 8
    (c, nothing)
end

function jnz(op, c)
    if c.A != 0
        c.ptr = op - 1
    end
    (c, nothing)
end

function bxc(op, c)
    c.B = xor(c.B, c.C)
    (c, nothing)
end

function out(op, c)
    (c, combo(op, c) % 8)
end

function bdv(op, c)
    c.B = floor(Int, c.A / (2^combo(op, c)))
    (c, nothing)
end

function cdv(op, c)
    c.C = floor(Int, c.A / (2^combo(op, c)))
    (c, nothing)
end

function search(c::Computer, A, idx)
    for n in 0:100
        A2 = (A << 3) | n
        c.A, c.ptr = A2, 1
        output = run(c)

        if output == c.instructions[end-idx:end]
            if output == c.instructions
                return A2
            end
            return search(c, A2, idx + 1)
        end
    end
    return 0
end

day17p1(inp) = clean_input(inp) |> run .|> string |> i -> join(i, ",")
day17p2(inp) = search(clean_input(inp), 0, 0)

function main()
    @assert day17p1(TEST_INP_P1) == TEST_OUT_P1
    @assert day17p2(TEST_INP_P2) == TEST_OUT_P2

    input = read(open("dat/day17.txt", "r"), String)
    day17p1(input) |> println
    day17p2(input) |> println
end

main()
