
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    OP_COMBO[OP_RA] = parse(Int64, lines[1][13:end])
    OP_COMBO[OP_RB] = parse(Int64, lines[2][13:end])
    OP_COMBO[OP_RC] = parse(Int64, lines[3][13:end])

    return parse.(Int64, (split(lines[5][10:end], ',')))
end

# Use a Dict to circumvent 1-indexed arrays.
OP_RA::Int64 = 4
OP_RB::Int64 = 5
OP_RC::Int64 = 6
OP_COMBO = Dict(
    0 => 0, 1 => 1, 2 => 2, 3 => 3, # Literals
    OP_RA => 0, OP_RB => 0, OP_RC => 0, # Registers
    7 => nothing # Invalid opcode
)

INSTRUCTIONS = Dict(
    0 => ((v, pc) -> OP_COMBO[OP_RA] = div(OP_COMBO[OP_RA], 2^OP_COMBO[v])),
    1 => ((v, pc) -> OP_COMBO[OP_RB] = xor(v, OP_COMBO[OP_RB])),
    2 => ((v, pc) -> OP_COMBO[OP_RB] = OP_COMBO[v] % 8),
    # Do -2 to the program counter, to counteract the fixed incrementing of
    # the program counter?
    3 => ((v, pc) -> (OP_COMBO[OP_RA] != 0) ? (pc[] = v+1) : nothing),
    4 => ((v, pc) -> OP_COMBO[OP_RB] = xor(OP_COMBO[OP_RB], OP_COMBO[OP_RC])),
    5 => ((v, pc) -> OP_COMBO[v] % 8),
    6 => ((v, pc) -> OP_COMBO[OP_RB] = div(OP_COMBO[OP_RA], 2^OP_COMBO[v])),
    7 => ((v, pc) -> OP_COMBO[OP_RC] = div(OP_COMBO[OP_RA], 2^OP_COMBO[v])),
)

function part1()
    data = parse_input("./data17.txt")

    # Program counter, but the Julia 1-indexed version
    pc::Ref{Int64} = Ref(1)
    outlst::Array{String} = []
    while 1 <= pc[] <= length(data)
        # Load instruction
        opcode  = data[pc[]]
        operand = data[pc[]+1]

        @assert operand != 7 "Combo operand 7 is an invalid operand!"

        out = INSTRUCTIONS[opcode](operand, pc)

        if opcode == 3 && out !== nothing
            continue
        end

        if opcode == 5
            push!(outlst, string(out))
        end

        # Always move program counter
        pc[] = pc[] + 2
    end

    return join(outlst, ',')
end

function part2()
    data = parse_input("./data17.txt")

    result = data
    return result
end

println(part1())
# println(part2())
