
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    return string(readlines(file_path)...)
end

function solve(data::String)
    # Sum each "mul(X,Y)" match
    regex = r"mul\(([0-9]+),([0-9]+)\)"
    total::Int64 = 0    # Require Int64 to prevent overflow!
    for m in eachmatch(regex, data)
        larg, rarg = m.captures
        total += parse(Int64, larg) * parse(Int64, rarg)
    end

    return total
end

function part1()
    data = parse_input("./data3.txt")

    result = solve(data)
    return result
end

function part2()
    data = parse_input("./data3.txt")

    # Replace each subsequence "don't() ... do()" OR
    # "don't() ... EOF" by the empty string.
    # Then only "do()" copies of "mul(X,Y)" remain.
    regex = r"don't\(\).+?((do\(\))|$)"
    data = replace(data, regex => s"")

    result = solve(data)
    return result
end

println(part1())
println(part2())
