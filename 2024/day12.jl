
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
URDL = [(0, 1), (1, 0), (0, -1), (-1, 0)] # Cardinal directions
URDLD = [(1, 1), (-1, 1), (1, -1), (-1, -1)] # Diagonal directions
ID_EMPTY::Int64 = 0
ID_FIRST::Int64 = ID_EMPTY+1

"""Clamp the given (row, columns) coordinates in bounds of the matrix."""
function inbounds(r, c, matrix)
    h, w = size(matrix)
    return clamp(r, 1, h), clamp(c, 1, w)
end

"""Check if the given coordinates are out-of-bounds of the matrix."""
function outbounds(r, c, matrix)
    h, w = size(matrix)
    return !(1 <= r <= h) || !(1 <= c <= w)
end

"""The possibly out-of-bounds neighbour (row, col) coordinates."""
function neighbours(r, c)
    return [(r+offr, c+offc) for (offc, offr) in URDL]
end

"""Flatten a vector of vectors."""
flatten(v) = reduce(vcat, v)

"""Compute the number of sides of a field bordering another field or the grid edge."""
function perimeter(pos::Tuple{Int64, Int64}, fields::Matrix{Char}, neighbouring)
    r, c = pos

    return sum([
        (fields[r,c] != fields[inbounds(rn, cn, fields)...]) ||
        outbounds(rn, cn, fields)
        for (rn, cn) in neighbouring(r, c)
    ])
end

"""Compute the number of faces of the region with the given id.

    Scan the id grid for a single id. Do this for every column
    and every row, plus the one column or row just out of bounds.
    In doing so, add 1 face for every cell to the left/right
    (top/bottom for rows) where you transition from a different id
    in the previous cell to the chosen id in this cell.
"""
function faces(id, idgrid)
    h, w = size(idgrid)
    faces::Int64 = 0
    lseen::Bool = false
    rseen::Bool = false

    loffset = CartesianIndex(0, -1)
    roffset = CartesianIndex(0,  1)
    for col in 0:w+1
        lseen, rseen = false, false
        for row in 0:h+1
            curr = CartesianIndex(row, col)
            left = curr + loffset
            right = curr + roffset
            if !outbounds(curr[1], curr[2], idgrid) && (idgrid[curr] == id)
                lseen, rseen = false, false
                continue
            end
            if !outbounds(left[1], left[2], idgrid)
                if idgrid[left] == id
                    faces += !lseen
                    lseen = true
                else
                    lseen = false
                end
            end
            if !outbounds(right[1], right[2], idgrid)
                if idgrid[right] == id
                    faces += !rseen
                    rseen = true
                else
                    rseen = false
                end
            end
        end
    end

    loffset = CartesianIndex(-1, 0)
    roffset = CartesianIndex( 1, 0)
    for row in 0:h+1
        lseen, rseen = false, false
        for col in 0:w+1
            curr = CartesianIndex(row, col)
            left = curr + loffset
            right = curr + roffset
            if !outbounds(curr[1], curr[2], idgrid) && (idgrid[curr] == id)
                lseen, rseen = false, false
                continue
            end
            if !outbounds(left[1], left[2], idgrid)
                if idgrid[left] == id
                    faces += !lseen
                    lseen = true
                else
                    lseen = false
                end
            end
            if !outbounds(right[1], right[2], idgrid)
                if idgrid[right] == id
                    faces += !rseen
                    rseen = true
                else
                    rseen = false
                end
            end
        end
    end

    return faces
end

function mark_region!(start, id, fields, regions, idgrid)
    r, c = start
    area, perim = get!(regions, id, (0, 0))
    regions[id] = (area + 1, perim + perimeter(start, fields, neighbours))
    idgrid[r, c] = id

    for (offc, offr) in URDL
        next = inbounds(r+offr, c+offc, fields)
        rb, cb = next
        if (r == rb) && (c == cb)
            continue
        end
        if (fields[r, c] == fields[rb, cb]) && (idgrid[rb, cb] == ID_EMPTY)
            mark_region!(next, id, fields, regions, idgrid)
        end
    end
end

function part1()
    data = parse_input("./data12.txt")

    idgrid::Matrix{Int64} = falses(size(data)...)
    regions::Dict = Dict()

    loc = CartesianIndex(1,1)
    id::Int64 = 1
    while loc !== nothing
        mark_region!(Tuple(loc), id, data, regions, idgrid)
        loc = findfirst(==(0), idgrid)
        id += 1
    end

    result = sum([*(regions[id]...) for id in keys(regions)])
    return result
end

function part2()
    data = parse_input("./data12.txt")

    idgrid::Matrix{Int64} = falses(size(data)...)
    regions::Dict = Dict()

    loc = CartesianIndex(1,1)
    id::Int64 = 1
    while loc !== nothing
        mark_region!(Tuple(loc), id, data, regions, idgrid)
        loc = findfirst(==(0), idgrid)
        id += 1
    end

    # FIXME: This just overwrites the value computed with part 1. It works though ...
    for rid in keys(regions)
        nrfaces = faces(rid, idgrid)
        regions[rid] = (regions[rid][1], nrfaces)
    end

    result = sum([*(regions[id]...) for id in keys(regions)])
    return result
end

println(part1())
println(part2())
