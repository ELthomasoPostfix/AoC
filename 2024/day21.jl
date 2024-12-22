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
        # Avoid ending in '<'
        if CHR_L in hmoves
            corner = C1
        # Prefer ending in 'v'
        elseif CHR_D in vmoves
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

function transform(move::Char, pad, src)
    return transform(string(move), pad, src)
end

function transform(moves::String, pad, src)
    blank = pad[CHR_BLANK]
    destinations = [pad[c] for c in moves]
    sources = vcat(src, destinations[1:end-1])
    moves = tomoves.(sources, destinations, (blank,))
    moves = string(moves...)
    return moves, destinations[end]
end

function transform_dpads(moves::String, positions, pad, cache; dpad_idx::Int64=1)::Int64
    @assert 1 <= dpad_idx <= length(positions) "Invalid dpads index."


    # println("      dpi=$dpad_idx | $(length(moves))")

    srcs = positions[dpad_idx:end]
    key = (moves, srcs, dpad_idx)
    # TODO: forgot to check all sources and update all destinations!!!!!
    cached = get(cache, key, nothing)
    if cached !== nothing
        positions[dpad_idx:end] .= cached[2]
        return cached[1]
    end

    moves, dst = transform(moves, pad, positions[dpad_idx])
    positions[dpad_idx] = dst

    # Base case: All dpads have performed transitions, push up this substring's
    # length for aggregation.
    if dpad_idx == length(positions)
        return length(moves)
    end

    STEP::Int64 = 20
    result = sum([
        transform_dpads(moves[sidx:min(end, sidx+STEP-1)], positions, pad, cache, dpad_idx=dpad_idx+1)
        for sidx in 1:STEP:length(moves)
    ])
    cache[key] = (result, copy(positions[dpad_idx:end]))
    return result
end

function solve(data, num_dpads::Int64)
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
        println(code)
        positions::Array{CartesianIndex} =
        vcat(npad['A'], fill(dpad['A'], num_dpads))
        for c in code
            println("    $c")
            moves, dst = transform(c, npad, positions[1])
            positions[1] = dst

            if false
                @assert num_dpads < 15 "This implementation is way too slow for $num_dpads iterations."
                for idx in 1:num_dpads
                    println("      dpad=$idx")
                    moves, dst = transform(moves, dpad, positions[idx+1])
                    positions[idx+1] = dst
                end

                total += length(moves) * parse(Int64, code[1:end-1])
            else
                # A slice view is editable AND functions as a valid array pointer,
                # as opposed to a non-view slice.
                cache = Dict()
                dpad_positions = @view positions[2:end]
                total += transform_dpads(moves, dpad_positions, dpad, cache) * parse(Int64, code[1:end-1])
            end

        end
    end
    return total
end

function part1()
    data = parse_input("./data21.txt")
    return solve(data, 2)
end

function part2()
    data = parse_input("./data21.txt")
    return solve(data, 25)
end

println(part1())
println(part2())
