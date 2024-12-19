using DataStructures

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    designs::Array{String} = split(lines[1], ", ")
    patterns = lines[3:end]

    return designs, patterns
end

function run(automaton::Dict, word::String)::Tuple{Bool, Int64}
    states::Vector{Pair{Int64, Int64}} = [Pair(0, 1)]
    for c in word
        # Compact executions/paths that converge to the same state for the
        # current, to-process character into a single execution for efficiency.
        compacted = Dict()
        for (src, cnt) in states
            # There is no transition on this character; abandon this path.
            if !((src, c) in keys(automaton))
                continue
            end
            # The destinations include the initial state or and another state.
            dsts::Array{Int64} = automaton[(src, c)]
            for dst::Int64 in dsts
                compacted[dst] = get(compacted, dst, 0) + cnt
            end
        end
        states = collect(pairs(compacted))

        # No viable paths remain; fail.
        if isempty(states)
            return false, 0
        end
    end
    idx = findfirst(((state, _),) -> state == 0, states)
    if idx === nothing
        return false, 0
    end
    # Ending in the initial state is synonymous with matching the word.
    ismatched::Bool = true
    # We kept track of all ways to match the word.
    nrpaths::Int64 = states[idx][2]
    return ismatched, nrpaths
end

function solve(designs, patterns)
    automaton = Dict()
    state_next::Int64 = 1
    for design in designs
        state::Int64 = 0
        for c in design[1:end-1]
            trans = (state, c)
            dsts = get!(automaton, trans, [])
            # Create a non-existing transition, or extend a branch
            # that currently only loops back to the initial state.
            if dsts == [] || dsts == [0]
                state = state_next
                state_next += 1
                union!(dsts, state)
            else
                @assert 1 <= length(dsts) <= 2 "Expected exactly 1-2 destinations, got $(length(dsts))"
                extendable = filter(!=(0), dsts)
                @assert length(extendable) == 1 "Expected 1 extension point, got $(length(extendable))"
                state = extendable[1]
            end
        end
        # Always loop back to the initial state to end the design.
        dsts = get!(automaton, (state, design[end]), [])
        union!(dsts, 0)
    end

    totalp1::Int64 = 0
    totalp2::Int64 = 0
    for pattern in patterns
        p1, p2 = run(automaton, pattern)
        totalp1 += p1
        totalp2 += p2
    end

    return totalp1, totalp2
end

function part1()
    data = parse_input("./data19.txt")
    result, _ = solve(data...)
    return result
end

function part2()
    data = parse_input("./data19.txt")
    _, result = solve(data...)
    return result
end

println(@time part1())
println(part2())
