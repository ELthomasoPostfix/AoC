
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    for (idx, line) in enumerate(lines)
        _ = split(line, " ")
    end
    return nothing
end

function part1()
    data = parse_input("./datax.txt")

    result = data
    return result
end

function part2()
    data = parse_input("./datax.txt")

    result = data
    return result
end

println(part1())
println(part2())
