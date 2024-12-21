using DataStructures

CHR_BLANK::Char = ' '
CHR_ENTER::Char = 'A'
CHR_U::Char = '^'
CHR_D::Char = 'v'
CHR_L::Char = '<'
CHR_R::Char = '>'
MAT_NPAD = [
    '7' '8' '9';
    '4' '5' '6';
    '1' '2' '3';
    ' ' '0' 'A'
]
MAT_DPAD = [
    ' ' '^' 'A';
    '<' 'v' '>'
]

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    codes = readlines(file_path)
    dpad = Dict(c => findfirst(==(c), MAT_DPAD) for c in MAT_DPAD)
    npad = Dict(c => findfirst(==(c), MAT_NPAD) for c in MAT_NPAD)
    return codes, dpad, npad
end

function tomoves(start::CartesianIndex, stop::CartesianIndex,
                 blank::CartesianIndex)
    diff = stop - start
    hmoves::String = repeat(diff[2] > 0 ? '>' : '<', abs(diff[2]))
    vmoves::String = repeat(diff[1] > 0 ? 'v' : '^', abs(diff[1]))

    #= Ensure the corner never resides outside the key/num pad:
        S    C1

        C2    E
    =#
    C1 = CartesianIndex(start[1], stop[2])
    C2 = CartesianIndex(stop[1], start[2])

    corner = C1
    # At most one corner is blank; we must not pass through a blank.
    if C1 == blank
        corner = C2
    # We can make a choice, to minimize/optimize the path length.
    elseif C1 != blank && C2 != blank
        @assert start[1] == C1[1] "Arbitrary assumption to make optimizations work: C1 is on the same row as the start."
        @assert start[2] == C2[2] "Arbitrary assumption to make optimizations work: C2 is on the same col as the start."
        # Prefer ending in 'v'
        if CHR_D in vmoves
            corner = C2
        end
    end
    # You MUST pass through the chosen corner!
    # If the corner is on the same row, then you step into the corner by
    # performing the horizontal moves first. Else, the corner must be in
    # the same column, and you must perform the vertical moves first.
    if corner[1] == start[1]
        return hmoves * vmoves * "A"
    else
        return vmoves * hmoves * "A"
    end
end

function transform(moves, pad)
    blank = pad[CHR_BLANK]
    destinations = [pad[c] for c in moves]
    sources = vcat(pad['A'], destinations[1:end-1])
    moves = tomoves.(sources, destinations, (blank,))
    moves = string(moves...)
    return moves
end

function part1()
    data = parse_input("./data21.txt")

    codes, dpad, npad = data

    #= The way we can impact the length of the output sequence is
      the order of vertical vs horizontal moves for each movement.
      e.g. when going from number 5 to 9, we have two options:
          >>^^  OR  ^^>>
      The same holds for the directional key pads (dpads).
      Only the dpads can see any redundant movements.
      All dpad key pairs have a grid distance of 1 or 2, except the pair
      ('A', '<') which has grid distance 3. So direct movements on a dpad
      between the 'A' and '<' keys must be avoided.
    =#
    total::Int64 = 0
    for code in codes
        moves = transform(code, npad)
        moves = transform(moves, dpad)
        moves = transform(moves, dpad)
        
        total += length(moves) * parse(Int64, code[1:end-1])
    end

    result = total
    return result
end

function part2()
    data = parse_input("./data21.txt")

    result = data
    return result
end

println(part1())
# println(part2())
