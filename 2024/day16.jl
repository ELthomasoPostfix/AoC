using DataStructures


CHR_START::Char = 'S'
CHR_STOP::Char = 'E'
CHR_WALL::Char = '#'
CHR_FREE::Char = '.'

ESWN = [
    CartesianIndex(0, 1),   # East
    CartesianIndex(1, 0),   # South
    CartesianIndex(0, -1),  # West
    CartesianIndex(-1, 0),  # North
]

cycle(heading::Int64) = (heading-1)%length(ESWN) + 1

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    maze::Matrix{Char} = Matrix{Char}(undef, length(lines), length(lines[1]))
    start::CartesianIndex = CartesianIndex(0, 0)
    stop::CartesianIndex = CartesianIndex(0, 0)
    for (idx, line) in enumerate(lines)
        maze[idx,:] .= collect(line)
        start_ = findfirst(==(CHR_START), line)
        stop_ = findfirst(==(CHR_STOP), line)
        if start_ !== nothing
            start_ = CartesianIndex(idx, start_)
            maze[start_] = CHR_FREE
            start = start_
        end
        if stop_ !== nothing
            stop_ = CartesianIndex(idx, stop_)
            maze[stop_] = CHR_FREE
            stop = stop_
        end
    end
    return maze, start, stop
end

function solve(start::CartesianIndex, stop::CartesianIndex, heading::Int64,
               maze::Matrix{Char}, visited::Matrix{Bool})
    pqueue = PriorityQueue{Tuple{CartesianIndex, Int64}, Int64}()
    enqueue!(pqueue, (start, heading), 0)

    while true
        key, val = peek(pqueue)
        delete!(pqueue, key)
        pos, heading = key

        visited[pos] = true

        if pos == stop
            return val
        end

        for (offset, cost) in [(0, 1), (3, 1001), (1, 1001), (2, 2001)]
            heading_next = cycle(heading + offset)
            next = pos + ESWN[heading_next]
            key = (next, heading_next)
            priority = val + cost
            if !visited[next] && (maze[next] == CHR_FREE)
                visited[next] = true
                enqueue!(pqueue, key, priority)
            end
        end
    end

    @assert false "Should not reach here."
end

function part1()
    data = parse_input("./data16.txt")

    maze, start, stop = data
    visited::Matrix{Bool} = falses(size(maze)...)

    return solve(start, stop, 1, maze, visited)
end

function part2()
    data = parse_input("./data16.txt")

    result = data
    return result
end

println(part1())
# println(part2())