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

function solve(data)
    maze, start, finish = data
    # For each cell, the lowest priority that has visited that cell until now.
    visited::Matrix{Int64} = falses(size(maze)...)
    fill!(visited, typemax(Int64))
    # The initial heading is East
    heading::Int64 = 1


    pqueue = PriorityQueue{Tuple{CartesianIndex, Int64, Set}, Int64}()
    enqueue!(pqueue, (start, heading, Set([start])), 0)
    visited[start] = 0

    # The optimal score, which is the only acceptable score for any path.
    best_score::Union{Int64, Nothing} = nothing
    # The set of all positions along all optimal paths.
    best_spots::Set{CartesianIndex} = Set{CartesianIndex}()
    while length(pqueue) > 0
        key, val = peek(pqueue)
        delete!(pqueue, key)
        pos, heading, path = key

        # Quit once the next intermediate lowest score exceeds
        # the optimal score.
        if best_score !== nothing && val > best_score
            break
        end

        if pos == finish
            if best_score === nothing
                best_score = val
            end
            best_spots = union(best_spots, path)
            continue
        end

        # Always perform a turn + step at the same time.
        for (offset, cost) in [(0, 1), (3, 1001), (1, 1001), (2, 2001)]
            heading_next = cycle(heading + offset)
            next = pos + ESWN[heading_next]
            priority = val + cost
            # Avoid paths that can never attain the best score.
            if best_score !== nothing && priority > best_score
                continue
            end

            # Give one turn worth of tolerance.
            # If the visited location is a crossroads or T intersection, then
            # some paths can cross it without turning while others must turn.
            # Do max to counteract integer overflows.
            threshold::Int64 = max(visited[next], visited[next] + 1000)
            if (priority <= threshold) && maze[next] == CHR_FREE
                visited[next] = min(visited[next], priority)
                key = (next, heading_next, union(path, [next]))
                enqueue!(pqueue, key, priority)
            end
        end
    end

    return best_score, length(best_spots)
end

function part1()
    data = parse_input("./data16.txt")
    return solve(data)[1]
end

function part2()
    data = parse_input("./data16.txt")
    return solve(data)[2]
end

println(part1())
println(part2())
