using DataStructures


ESWN = [
    CartesianIndex(0, 1),   # East
    CartesianIndex(1, 0),   # South
    CartesianIndex(0, -1),  # West
    CartesianIndex(-1, 0),  # North
]

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    bytes::Vector{CartesianIndex{2}} = []
    for (idx, line) in enumerate(lines)
        x, y = split(line, ",")
        x, y = parse(Int64, x), parse(Int64, y)
        x += 1
        y += 1
        push!(bytes, CartesianIndex{2}(y, x))
    end
    return bytes
end

function outbounds(pos, matrix)::Bool
    h, w = size(matrix)
    return !((1 <= pos[1] <= h) && (1 <= pos[2] <= w))
end

function solve(data, dimensions, sim_time)
    data = data[1:sim_time]

    h, w = dimensions
    # The grid of all cells that are either occupied by a corrupted
    # byte, or that have been visited at during the shortest path search.
    occupied::Matrix{Bool} = falses(h,w)
    start = CartesianIndex{2}(1,1)
    stop = CartesianIndex{2}(h,w)

    # Apply bytes to the free space
    occupied[data] .= true

    queue = Queue{Tuple{CartesianIndex, Int64}}()
    enqueue!(queue, (start, 0))
    while length(queue) > 0
        pos, steps = dequeue!(queue)

        if pos == stop
            return steps
        end

        for move in ESWN
            next = pos + move
            if outbounds(next, occupied) || occupied[next]
                continue
            end
            occupied[next] = true
            enqueue!(queue, (next, steps + 1))
        end
    end

    return -1
end

function part1()
    data = parse_input("./data18.txt")

    return solve(data, (71,71), 1024)
end

function part2()
    data = parse_input("./data18.txt")

    # Brute force the simulation, because the shortest path finding
    # is plenty efficient for this use case.
    for sim_time in eachindex(data)
        if solve(data, (71,71), sim_time) == -1
            coords = data[sim_time]
            row, col = coords[1], coords[2]
            # Julia has 1-indexed arrays, the problem assumed 0-indexed
            # arrays  and reversed order of the coordinates.
            return "$(col-1),$(row-1)"
        end
    end

    return nothing
end

println(part1())
println(part2())
