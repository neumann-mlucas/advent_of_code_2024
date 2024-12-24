TEST_INP = """
x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
"""
TEST_OUT_P1 = 2024

struct Instruction
    opr::String
    rst::String
    snd::String
    out::String
end

function clean_input(inp::String)
    inputs, instructions = split(inp, "\n\n")

    state = Dict{String,Int}()
    parse_state(line) = begin
        wire, value = strip.(split(strip(line), ":"))
        (wire, parse(Int, value))
    end
    for (wire, value) in parse_state.(split(inputs, "\n"))
        state[wire] = value
    end

    parse_instruction(line) = begin
        rst, opr, snd, _, out = strip.(split(strip(line)))
        Instruction(opr, rst, snd, out)
    end
    instructions = parse_instruction.(split(strip(instructions), "\n"))

    instructions, state
end

function exec(inst::Instruction, state::Dict)
    inst.opr == "OR" && (state[inst.out] = state[inst.rst] | state[inst.snd])
    inst.opr == "XOR" && (state[inst.out] = state[inst.rst] ⊻ state[inst.snd])
    inst.opr == "AND" && (state[inst.out] = state[inst.rst] & state[inst.snd])
    return state
end

function exec(insts::Vector{Instruction}, state::Dict)
    while !isempty(insts)
        inst = popfirst!(insts)
        if haskey(state, inst.rst) && haskey(state, inst.snd)
            state = exec(inst, state)
        else
            push!(insts, inst)

        end
    end
    state
end

function get_number(state::Dict)
    keys_ = sort(collect(keys(state)))

    num, iter = 0, 0
    for k in filter(k -> startswith(k, 'z'), keys_)
        num += state[k] << iter
        iter += 1
    end
    num
end

day24p1(inp) = exec(clean_input(inp)...) |> get_number
# day24p2(inp) = clean_input(inp) |> find_all_connected

function main()
    @assert day24p1(TEST_INP) == TEST_OUT_P1

    input = read(open("dat/day24.txt", "r"), String)
    day24p1(input) |> println
    # day24p2(input) |> println
end

main()
