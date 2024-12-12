
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    fields::Matrix{Char} = Matrix{Char}(undef, length(lines), length(lines[1]))
    for (idx, line) in enumerate(lines)
        fields[idx,:] = [c for c in line]
    end
    return fields
end

"""UP, RIGHT, DOWN, LEFT as cartesian coordinates."""
URDL = [(0, 1), (1, 0), (0, -1), (-1, 0)]

"""Clamp the given (row, columns) coordinates in bounds of the matrix."""
function inbounds(r, c, matrix)
    h, w = size(matrix)
    return clamp(r, 1, h), clamp(c, 1, w)
end

function outbounds(r, c, matrix)
    h, w = size(matrix)
    return !(1 <= r <= h) | !(1 <= c <= w)
end

function perimeter(pos, fields)
    r, c = pos

    return sum([
        (fields[r,c] != fields[inbounds(r+offr, c+offc, fields)...]) |
        outbounds(r+offr, c+offc, fields)
        for (offc, offr) in URDL
    ])
end

function mark_region!(start, id, fields, regions, seen)
    r, c = start
    area, perim = get!(regions, id, (0, 0))
    regions[id] = (area + 1, perim + perimeter(start, fields))
    seen[r, c] = true

    for (offc, offr) in URDL
        next = inbounds(r+offr, c+offc, fields)
        rb, cb = next
        # Clamping an out-of-bounds position may move it to the current pos.
        if (r == rb) & (c == cb)
            continue
        end
        if (fields[r, c] == fields[rb, cb]) & !seen[rb, cb]
            mark_region!(next, id, fields, regions, seen)
        end
    end
end

function part1()
    data = parse_input("./data12.txt")

    seen::Matrix{Bool} = falses(size(data)...)
    regions::Dict = Dict()

    loc = (1,1)
    id::Int64 = 0
    while loc !== nothing
        mark_region!(Tuple(loc), id, data, regions, seen)
        loc = findfirst(==(false), seen)
        id += 1
    end

    result = sum([*(regions[id]...) for id in keys(regions)])
    return result
end

function part2()
    data = parse_input("./data12.txt")

    result = data
    return result
end

println(part1())
# println(part2())
