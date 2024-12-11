"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    line::String = readlines(file_path)[1]
    nums = split(line, ' ')
    nums = parse.(Int64, nums)


    return Stone.(nums, 1)
end

"""A representation of a compacted stone.

    The count member represents the number of stones
    that have converged to the same path/sequence.
"""
struct Stone
    marking::Int64
    """The marking/number of the stone."""
    count::Int64
    """The number of stone instances compacted into this object."""
end

"""Flatten a vector of vectors."""
flatten(v) = reduce(vcat, v)

"""Transform a single stone according to the three specified rules.

    @param stone The stone to transform
    @return A list of transformed stones, since rule two may split the stone.
"""
function transform(stone::Stone)::Vector{Stone}
    # NOTE: Watch out when you replace an param Int64 by a struct object.
    #       Structs define some default == operator, which can lead to
    #       bugs when you forget to replace "value == 0" by
    #       "struct.value == 0". Found this out the hard way :(
    if stone.marking == 0
        return [Stone(1, stone.count)]
    end

    str = string(stone.marking)
    if length(str) % 2 == 0
        return [
            Stone(parse(Int64, str[1:div(end, 2)]), stone.count)
            Stone(parse(Int64, str[1+div(end, 2):end]), stone.count)
        ]
    end

    return [Stone(stone.marking * 2024, stone.count)]
end

"""Compact a list of stones by aggregating the counts of same-marking stones.

    For example, [Stone(1, 4), Stone(1, 12)] becomes [Stone(1, 16)].

    @param stones The list of stones to compact.
    @return A compacted list of stones.
"""
function compact(stones::Vector{Stone})::Vector{Stone}
    separated = Dict()
    for stone in stones
        lst = get!(separated, stone.marking, [])
        push!(lst, stone)
    end
    return [
        Stone(marking, sum([stone.count for stone in sorted]))
        for (marking, sorted) in separated
    ]
end

function solve(stones::Vector{Stone}, NR_BLINKS::Int64)::Int64
    for _ in 1:NR_BLINKS
        stones = flatten(transform.(stones))
        stones = compact(stones)
    end

    counts = [stone.count for stone in stones]
    return sum(counts)
end

function part1()
    data = parse_input("./data11.txt")
    return solve(data, 25)
end

function part2()
    data = parse_input("./data11.txt")
    return solve(data, 75)
end

println(part1())
println(part2())
