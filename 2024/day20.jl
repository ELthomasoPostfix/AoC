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

    maze::Matrix{Bool} = falses(length(lines), length(lines[1]))
    start::CartesianIndex = CartesianIndex(0, 0)
    stop::CartesianIndex = CartesianIndex(0, 0)
    for (idx, line) in enumerate(lines)
        coords = [CartesianIndex(idx, c) for c in findall(==('#'), line)]
        maze[coords] .= true
        ffs = findfirst(==('S'), line)
        ffe = findfirst(==('E'), line)
        start = ffs !== nothing ? CartesianIndex(idx, ffs) : start
        stop = ffe !== nothing ? CartesianIndex(idx, ffe) : stop
    end
    return maze, start, stop
end

function outbounds(pos, matrix)::Bool
    h, w = size(matrix)
    return !((1 <= pos[1] <= h) && (1 <= pos[2] <= w))
end

function solve(maze, start, stop)
    maze = copy(maze)

    scores::Matrix{Int64} = Matrix{Int64}(undef, size(maze)...)
    fill!(scores, -1)

    queue = Queue{Tuple{CartesianIndex, Int64}}()
    enqueue!(queue, (start, 0))
    maze[start] = true
    while length(queue) > 0
        pos, steps = dequeue!(queue)
        scores[pos] = steps

        # Any path must end at the goal so that longer paths may still be
        # discovered. We want to know how long it takes to reach every
        # celln since you can only cheat onece.
        if pos == stop
            continue
        end

        for move in ESWN
            next = pos + move
            if outbounds(next, maze) || maze[next]
                continue
            end
            maze[next] = true
            enqueue!(queue, (next, steps + 1))
        end
    end

    return scores
end

function part1()
    data = parse_input("./data20.txt")

    maze, start, stop = data
    for row in eachrow(data[1])
        println(string([(r ? '#' : '.') for r in row]...))
    end
    println()
    
    scores = solve(maze, start, stop)
    for row in eachrow(scores)
        println(string([(r == -1 ? "     " : rpad(r, 5, ' ')) for r in row]...))
    end
    println()

    shortcuts::Dict = Dict()
    save_min::Int64 = 100
    neighbours(pos) = [pos + move for move in ESWN]
    for (ridx, row) in enumerate(eachrow(scores))
        for (cidx, score) in enumerate(row)
            pos = CartesianIndex(ridx, cidx)
            # We can only start a shortcut from non-wall cell.
            if maze[pos]
                continue
            end
            for adjacent in neighbours(pos)
                # Shortcuts must pass through a wall adjacent to the position.
                if !maze[adjacent]
                    continue
                end
                # The neighbours of the wall are the actually reachable cells.
                for distant in neighbours(adjacent)
                    if !outbounds(distant, maze) && pos != distant
                        # You must take two steps to perform the shortcut, so +2!
                        save = scores[distant] - (scores[pos] + 2)
                        if save < save_min
                            continue
                        end
                        shortcuts[save] = 1 + get(shortcuts, save, 0)
                    end
                end
            end
        end
    end

    for (k, v) in sort(collect(pairs(shortcuts)))
        println(rpad(v, 3, ' ') * " that save " * rpad(k, 3, ' '))
    end
    println()

    return sum(values(shortcuts))
end

function part2()
    data = parse_input("./data20.txt")

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
# println(part2())
