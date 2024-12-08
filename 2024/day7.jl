
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    tests::Array{Array{Int64}} = []
    for (idx, line) in enumerate(lines)
        refval, terms = split(line, ": ")
        terms = split(terms, " ")
        refval = parse(Int64, refval)
        terms = map((t) -> parse(Int64, t), terms)
        push!(tests, vcat(refval, terms))
    end
    return tests
end

function valid_test(refval::Int64, running::Int64, terms::Vector{Int64}, operators::Array{Function})
    if isempty(terms)
        return refval == running
    end
    for op in operators
        # The order of terms of the operator is important when doing concat!
        #       (1 + 3) || 4  !=  4 || (1 + 3)
        # As per the wording of the problem, operations are left to right.
        # So always choose the running value as left term, and the next value
        # as the right term.
        if valid_test(refval, op(running, terms[begin]), terms[2:end], operators)
            return true
        end
    end
    return false
end

function concat(a::Int64, b::Int64)
    return parse(Int64, string(a) * string(b))
end

function solve(data, operators::Array{Function})
    total::Int64 = 0
    for test in data
        refval::Int64 = test[1]
        terms::Vector{Int64} = test[2:end]

        total += refval * valid_test(refval, terms[begin], terms[2:end], operators)
    end
    return total
end

function part1()
    data = parse_input("./data7.txt")

    result = solve(data, [+,*])
    return result
end

function part2()
    data = parse_input("./data7.txt")

    result = solve(data, [+,*,concat])
    return result
end

println(part1())
println(part2())
