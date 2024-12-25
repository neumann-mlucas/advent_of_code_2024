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
TEST_OUT_P2 = 2024

struct Instruction
    opr::String
    fst::String
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
        fst, opr, snd, _, out = strip.(split(strip(line)))
        Instruction(opr, fst, snd, out)
    end
    instructions = parse_instruction.(split(strip(instructions), "\n"))

    instructions, state
end

function exec(inst::Instruction, state::Dict)
    inst.opr == "OR" && (state[inst.out] = state[inst.fst] | state[inst.snd])
    inst.opr == "XOR" && (state[inst.out] = state[inst.fst] ⊻ state[inst.snd])
    inst.opr == "AND" && (state[inst.out] = state[inst.fst] & state[inst.snd])
    return state
end

function exec(insts::Vector{Instruction}, state::Dict)
    while !isempty(insts)
        inst = popfirst!(insts)
        if haskey(state, inst.fst) && haskey(state, inst.snd)
            state = exec(inst, state)
        else
            push!(insts, inst)

        end
    end
    state
end

function get_number(state::Dict, char::Char)
    keys_ = sort(collect(keys(state)))

    num, iter = 0, 0
    for k in filter(k -> startswith(k, char), keys_)
        num += state[k] << iter
        iter += 1
    end
    num
end

function find_swaps(insts::Vector{Instruction}, state::Dict)
    wrong = Set()
    for inst in insts
        if startswith(inst.out, 'z') && inst.opr != "XOR" && inst.out != zlast
            push!(wrong, inst.out)
        elseif inst.opr == "XOR" && all(!startswith(reg, ['x', 'y', 'z']) for reg in (inst.out, inst.fst, inst.snd))
            push!(wrong, inst.out)
        elseif inst.opr == "AND" && !("x00" in [inst.fst, inst.snd])
            for sub_inst in insts
                if (inst.out == sub_inst.fst || inst.out == sub_inst.snd) && sub_inst.opr != "OR"
                    push!(wrong, inst.out)
                end
            end
        elseif inst.opr == "XOR"
            for sub_inst in insts
                if (inst.out == sub_inst.fst || inst.out == sub_inst.snd) && sub_inst.opr == "OR"
                    push!(wrong, inst.out)
                end
            end
        end
    end
    join(sort(collect(wrong)), ",")
end

day24p1(inp) = exec(clean_input(inp)...) |> x -> get_number(x, 'z')
day24p2(inp) = find_swaps(clean_input(inp)...)

function main()
    @assert day24p1(TEST_INP) == TEST_OUT_P1

    input = read(open("dat/day24.txt", "r"), String)
    day24p1(input) |> println
    day24p2(input) |> println
end

main()
