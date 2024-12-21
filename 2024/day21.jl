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

    #= Ensure the corner never resides outside the key/num pad.
        S    C1

        C2    E
    =#
    C1 = CartesianIndex(start[1], stop[2])
    C2 = CartesianIndex(stop[1], start[2])

    if true # TODO: REMOVE CASE?
        corner = C1 == blank ? C2 : C1
        if corner[1] == start[1]
            return hmoves * vmoves * "A"
        end
        return vmoves * hmoves * "A"
    else
        moves::Array{String} = []
        if C1 != blank
            push!(moves, hmoves * vmoves * "A")
        end
        if C2 != blank
            push!(moves, vmoves * hmoves * "A")
        end
        return moves
    end
end

function printm(map, pos, of)
    map = copy(map)
    map[pos] = '@'
    for row in eachrow(map)
        write(of, string(row...) * "\n")
    end
    write(of, "\n")
end

function simulate(sequence::String, npad, dpad;
                  of::Union{Nothing, IOStream}=nothing)
    moves = Dict(
        '^' => CartesianIndex(-1, 0),
        '>' => CartesianIndex(0, 1),
        '<' => CartesianIndex(0, -1),
        'v' => CartesianIndex(1, 0),
    )
    npA = npad['A']
    dpA = dpad['A']
    np = npA
    dp1 = dpA
    dp2 = dpA

    if of !== nothing
        printm(MAT_NPAD, np, of)
        printm(MAT_DPAD, dp1, of)
        printm(MAT_DPAD, dp2, of)
        write(of, "=========\n")
    end

    rev_npad = Dict(v => k for (k, v) in pairs(npad))
    rev_dpad = Dict(v => k for (k, v) in pairs(dpad))
    result = ""
    for c in sequence
        if of !== nothing
            write(of, "char=$c\n\n")
        end

        if c == 'A' && dp2 == dpA && dp1 == dpA
            result = result * rev_npad[np]
        elseif c == 'A' && dp2 == dpA
            np += moves[rev_dpad[dp1]]
        elseif c == 'A'
            dp1 += moves[rev_dpad[dp2]]
        else
            dp2 += moves[c]
        end

        if of !== nothing
            printm(MAT_NPAD, np, of)
            printm(MAT_DPAD, dp1, of)
            printm(MAT_DPAD, dp2, of)
            write(of, "========= $result\n")
        end
    end
    return result
end

function combinations(left, args...)
    if isempty(args)
        return left
    elseif length(args) == 1
        return [
            e1 * e2
            for e1 in left
                for e2 in args[1]
        ]
    end
    return [
        e1 * e2
        for e2 in combinations(args...)
            for e1 in left
    ]
end

function combinationsg(left, args...)
    if isempty(args)
        return (e for e in left)
    elseif length(args) == 1
        return (
            e1 * e2
            for e1 in left
                for e2 in args[1]
        )
    end
    return (
        e1 * e2
        for e2 in combinationsg(args...)
            for e1 in left
    )
end

function once(srcn, dstn, srcd1, srcd2, npad, dpad)
    nblank = npad[CHR_BLANK]
    dblank = dpad[CHR_BLANK]

    moves = tomoves(srcn, dstn, nblank)
    
    destinations = [dpad[c] for c in moves]
    dstd1 = destinations[end]
    sources = vcat(srcd1, destinations[1:end-1])
    moves = tomoves.(sources, destinations, (dblank,))
    moves = string(moves...)
    
    destinations = [dpad[c] for c in moves]
    dstd2 = destinations[end]
    sources = vcat(srcd2, destinations[1:end-1])
    moves = tomoves.(sources, destinations, (dblank,))
    moves = string(moves...)

    return moves, dstd1, dstd2
end

function entirely(code, npad, dpad)
    srcn  = npad['A']
    srcd1 = dpad['A']
    srcd2 = dpad['A']
    moves::String = ""
    for c in code
        dstn = npad[c]
        moves_part, srcd1, srcd2 = once(srcn, dstn, srcd1, srcd2, npad, dpad)
        srcn = dstn
        moves = moves * moves_part
    end

    return length(moves) * parse(Int64, code[1:end-1])
end

function part1()
    data = parse_input("./data21.txt")

    codes, dpad, npad = data
    nblank = npad[CHR_BLANK]
    dblank = dpad[CHR_BLANK]

    of = open("out.txt", "w")
    
    total::Int64 = 0
    for code in codes
        # CI = CartesianIndex
        # pqueue = PriorityQueue{Tuple{String, CI, CI, CI, String}, Int64}()
        # enqueue!(pqueue, (code, "", npad['A'], dpad['A'], dpad['A']), length(code))

        # moves_shortest::String = ""
        # while !isempty(pqueue)
        #     code_rem, moves, np, dp1, dp2 = dequeue!(pqueue)


        #     if isempty(code_rem)
        #         moves_shortest = moves
        #         break
        #     end

        #     c = code_rem[end]
        #     code_rem = code_rem[1:end-1]

        # end



        # destinations = [npad[c] for c in code]
        # sources = vcat(npad['A'], destinations[1:end-1])
        # moves = tomoves.(sources, destinations, (nblank,))
        # moves = string(moves...)
        
        # destinations = [dpad[c] for c in moves]
        # sources = vcat(dpad['A'], destinations[1:end-1])
        # moves = tomoves.(sources, destinations, (dblank,))
        # moves = string(moves...)
        
        # destinations = [dpad[c] for c in moves]
        # sources = vcat(dpad['A'], destinations[1:end-1])
        # moves = tomoves.(sources, destinations, (dblank,))
        # moves = string(moves...)

        # total += length(moves) * parse(Int64, code[1:end-1])
        total += entirely(code, npad, dpad) # TODO: DELETE, DELETE

        # println("$code: $moves")
        # println("$(length(moves)) * $(parse(Int64, code[1:end-1]))")
        # println("sim=$(simulate(moves, npad, dpad, of=of))")
        # println()
    end

    # total::Int64 = 0
    # for code in codes
    #     destinations = [npad[c] for c in code]
    #     sources = vcat(npad['A'], destinations[1:end-1])
    #     moves = tomoves.(sources, destinations, (nblank,))
    #     # println(collect(zip(sources, destinations)))
    #     # println(combinations(moves...))
    #     # return
    #     moves = combinations(moves...)

    #     println("done 1")
        
    #     moves_new = []
    #     for move in moves
    #         destinations = [dpad[c] for c in move]
    #         sources = vcat(dpad['A'], destinations[1:end-1])
    #         intermediate = tomoves.(sources, destinations, (dblank,))
    #         intermediate = combinations(intermediate...)
    #         append!(moves_new, intermediate)
    #     end
    #     moves = moves_new

    #     println("done 2")
        
    #     moves_new = []
    #     println(length(moves))
    #     ctr = counter(length.(moves))
    #     for (k, v) in pairs(ctr)
    #         println("$k => $v")
    #     end
    #     moves_shortest::String = ""
    #     length_shortest::Int64 = typemax(Int64)
    #     for (idx, move) in enumerate(moves)
    #         println(idx)
    #         destinations = [dpad[c] for c in move]
    #         sources = vcat(dpad['A'], destinations[1:end-1])
    #         intermediate = tomoves.(sources, destinations, (dblank,))
    #         intermediate = combinationsg(intermediate...)
    #         println(typeof(intermediate))

    #         for comb in combinations
    #             if length(comb) < length_shortest
    #                 length_shortest = length(comb)
    #                 moves_shortest = comb
    #             end
    #         end
    #     end
    #     moves = moves_shortest

    #     println("done 3")

    #     total += minimum(length.(moves)) * parse(Int64, code[1:end-1])

    #     println("$code: $moves")
    #     println("$(length(moves)) * $(parse(Int64, code[1:end-1]))")
    #     println("sim=$(simulate(moves, npad, dpad, of=of))")
    #     println()
    # end


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
