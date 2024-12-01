using DataStructures

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)
    L1::Array = Array{Integer}(undef, length(lines))
    L2::Array = Array{Integer}(undef, length(lines))
    for (idx, line) in enumerate(lines)
        e1, e2 = split(line, "   ")
        L1[idx] = parse(Int64, e1)
        L2[idx] = parse(Int64, e2)
    end
    return L1, L2
end

function part1()
    L1, L2 = parse_input("./data1.txt")
    S1 = sort(L1)
    S2 = sort(L2)

    diffs = abs.(S2 - S1)
    score = sum(diffs)
    return score
end

function part2()
    L1, L2 = parse_input("./data1.txt")
    O2 = counter(L2)
    score = L1 .* getindex.((O2,), L1)
    score = sum(score)
    return score
end

println(part1())
println(part2())
