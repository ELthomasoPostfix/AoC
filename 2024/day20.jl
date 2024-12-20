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

function solve_pathing(maze, start, stop)
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

function reachable(
        steps::Int64, pos::CartesianIndex, save_min:: Int64,
        shortcuts::Dict{Int64, Int64},
        maze::Matrix{Bool},
        scores::Matrix{Int64})::Nothing
    @assert steps > 0 "Must take at least one step."

    for step in 1:steps
        # The cardinal cells at distance step from the starting cell.
        starts = [
            pos + CartesianIndex(0, -step),
            pos + CartesianIndex(-step, 0),
            pos + CartesianIndex(0, step),
            pos + CartesianIndex(step, 0),
        ]
        #=
               O
              OXO
             OXOXO
            OXOSOXO
             OXOXO
              OXO
               O
        =#
        # To do a single loop at distance step around the starting cell, ...
        for (idx, start) in enumerate(starts)
            next = starts[idx%length(starts)+1]
            move = CartesianIndex(sign(next[1]-start[1]),
                                  sign(next[2]-start[2]))
            # ... we linearly move from starting point to starting point.
            reachable = start
            while reachable != next
                reachable = reachable + move
                if outbounds(reachable, scores) || maze[reachable] || pos == reachable
                    continue
                end
                # You must take X steps to perform the shortcut, so +X!
                save = scores[reachable] - (scores[pos] + step)
                if save < save_min
                    continue
                end
                shortcuts[save] = 1 + get(shortcuts, save, 0)
            end
        end
    end
end

function solve(maze, start, stop, cheat_steps::Int64, save_min::Int64)
    scores = solve_pathing(maze, start, stop)

    # A mapping: save_amount => #occurrences
    # i.e. how many cheats are there that save the given amount of steps.
    shortcuts::Dict{Int64, Int64} = Dict()
    h, w = size(scores)
    for row in 1:h
        for col in 1:w
            pos = CartesianIndex(row, col)
            # We can only start a shortcut from non-wall cell.
            if maze[pos]
                continue
            end
            reachable(cheat_steps, pos, save_min, shortcuts, maze, scores)
        end
    end

    return sum(values(shortcuts))
end

function part1()
    data = parse_input("./data20.txt")
    maze, start, stop = data
    return solve(maze, start, stop, 2, 100)
end

function part2()
    data = parse_input("./data20.txt")
    maze, start, stop = data
    return solve(maze, start, stop, 20, 100)
end

println(part1())
println(part2())
