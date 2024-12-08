
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

function valid_test(refval::Int64, running::Int64, terms::Vector{Int64})
    if isempty(terms)
        return refval == running
    end
    for op in [+,*]
        if valid_test(refval, op(terms[begin], running), terms[2:end])
            return true
        end
    end
    return false
end

function part1()
    data = parse_input("./data7.txt")

    total::Int64 = 0
    for test in data
        refval::Int64 = test[1]
        terms::Vector{Int64} = test[2:end]

        total += refval * valid_test(refval, terms[begin], terms[2:end])
    end

    result = total
    return result
end

function part2()
    data = parse_input("./data7.txt")

    result = data
    return result
end

println(part1())
# println(part2())
