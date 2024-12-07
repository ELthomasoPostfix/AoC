using DataStructures

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)
    rules::Dict = Dict()
    updates::Array{Array{Int16}} = []

    for (idx, line) in enumerate(lines)
        # Parse a rule "X|Y".
        if '|' in line
            key, value = split(line, '|')
            key   = parse(Int16, key)
            value = parse(Int16, value)
            push!(get!(rules, key, []), value)
        # Parse an update list.
        elseif ',' in line
            update = split(line, ',')
            update = map((value) -> parse(Int16, value), update)
            push!(updates, update)
        end
    end
    return rules, updates
end

function part1()
    rules, updates = parse_input("./data5.txt")
    total::Int64 = 0

    for update in updates
        correct::Bool = true
        for (idx, page) in enumerate(update)
            # Violations are those pages that were already seen but should
            # actually only appear after the current one.
            reqs = get(rules, page, [])
            seen = update[1:(idx-1)]
            violations = intersect(reqs, seen)

            if length(violations) > 0
                correct = false
                break
            end
        end
        if correct
            total += update[Int16(ceil(end/2))]
        end
    end

    result = total
    return result
end

function part2()
    rules, updates = parse_input("./data5.txt")
    total::Int64 = 0

    for update in updates
        incorrect::Bool = false
        not_done::Bool = true
        idx::Int64 = 1
        fixed_update = update
        # Loop over an update to correct it.
        while not_done
            not_done = false

            # Violations are those pages that were already seen but should
            # actually only appear after the current one.
            page = fixed_update[idx]
            reqs = get(rules, page, [])
            seen = fixed_update[1:(idx-1)]
            violations = intersect(reqs, seen)

            if length(violations) > 0
                incorrect = true

                move = seen[findall(in(violations), seen)]
                keep = seen[findall(!in(violations), seen)]
                rest = fixed_update[(idx+1):end]

                # Simply move all rule violating pages immediately after
                # the current page, but leave the page ordering otherwise
                # untouched.
                fixed_update = vcat(keep, page, move, rest)

                idx = length(keep) + length(page) + 1
            else
                idx += 1
            end
            not_done = idx <= length(fixed_update)
            
        end

        if incorrect
            total += fixed_update[Int16(ceil(end/2))]
        end
    end

    result = total
    return result
end

println(part1())
println(part2())
