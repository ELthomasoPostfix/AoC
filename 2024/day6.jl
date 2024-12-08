
CHR_GUARD::Char = '^'
CHR_WALL::Char = '#'
CHR_FREE::Char = '.'
CHR_SEEN::Char = 'X'

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    h, w = length(lines), length(lines[1])
    guard = nothing
    # A matrix where each cell contains a single character of the input matrix.
    # This gives access to Julia matrix operations and range indexation.
    mat::Matrix{Char} = Matrix{Char}(undef, h, w)
    for row in 1:h
        mat[row,:] .= collect(lines[row])

        col = findfirst(CHR_GUARD, lines[row])
        if col !== nothing
            guard = (col, row)
            mat[row, col] = CHR_FREE
        end
    end

    return mat, guard
end

"""Compute the results of performing one straight line walk until a wall.

    @return (
        The new guard (x, y) coords,
        The new heading (cardinal direction) ID,
        Whether this walk brings the guard outside the grid
    )
"""
function walk(grid, guard, heading)
    #=  heading  |  look dir  |  str dir
            0     |     UP     |   PREV
            1     |    RIGHT   |   NEXT
            2     |    DOWN    |   NEXT
            3     |    LEFT    |   PREV
    =#
    x, y = guard
    h, w = size(grid)
    vertical::Bool = (heading % 2) == 0

    # A method to find the nearest wall in the path of the guard.
    method = heading%3 == 0 ? findprev : findnext
    # The column or row on which the guard will now move.
    path::String = vertical ? string(grid[:,x]...) : string(grid[y,:]...)
    # The guard's starting position on the path.
    start = vertical ? y : x

    # Walk until you hit a wall, and then immediately turn.
    # This essentially reduces the two rules to one rule.
    z = method(==(CHR_WALL), path, start)

    left_grid::Bool = false
    if z === nothing
        guard = vertical ?
            (x, max(1, h * (heading - 1))) :
            (max(1, w * -(heading - 2)), y)
        left_grid = true
    else
        z += sign(start - z) # z is on top of the wall, move one step back
        guard = vertical ? (x, z) : (z, y)
        heading = (heading + 1) % 4
    end

    return guard, heading, left_grid
end

function part1()
    data = parse_input("./data6.txt")

    grid, guard = data

    heading::Int16 = 0
    done::Bool = false
    while !done
        target, heading, done = walk(grid, guard, heading)

        x, y = guard
        u, v = target
        col_ran = min(u,x):max(u,x)
        row_ran = min(v,y):max(v,y)
        grid[row_ran, col_ran] .= CHR_SEEN

        guard = target
    end

    result = count(==(CHR_SEEN), grid)
    return result
end

"""Run the guard's walk to completion to check if a loop occurs.

    @param[in]    grid The grid containing only walls.
    @param[in]   guard The guard's starting position.
    @param[in] heading The initial cardinal heading of the guard.
    @return true iff. a loop is detected. Else false.
"""
function isloop!(grid, guard, heading)
    @assert count(==(CHR_SEEN), grid) == 0 "Cannot detect loops, the initial grid is dirty."
    x, y = guard

    # Unless a loop is found, the guard leaves the grid by default.
    loop::Bool = false
    done::Bool = false
    while !done
        target, heading, done = walk(grid, guard, heading)
        u, v = target
        #= A guard can bump into a corner of walls, but simply rotating in
          does not constitute a valid loop. e.g.
            >>+#
              #
        =#
        rotated_in_place::Bool = guard == target

        # A loop is found when the same wall-adjacent spot is visited twice!
        if (grid[v, u] == CHR_SEEN) & !rotated_in_place
            loop = true
            break
        end

        # Else continue walking.
        grid[v, u] = CHR_SEEN
        guard = target
    end

    # Reset the markings for subsequent uses of the grid.
    replace!(grid, CHR_SEEN => CHR_FREE)
    return loop
end

function part2()
    data = parse_input("./data6.txt")

    grid, start = data
    obstacles = copy(grid)
    heading_start::Int16 = 0
    
    guard = start
    heading::Int16 = heading_start
    done::Bool = false
    while !done
        target, heading, done = walk(grid, guard, heading)

        x, y = guard
        u, v = target

        # We only need to place 'X' markers when trying loop detection!
        col_ran = min(u,x):max(u,x)
        row_ran = min(v,y):max(v,y)
        positions = Iterators.product(col_ran, row_ran)

        # Every position along the walk is a viable new wall position.
        for pos in positions
            col, row = pos
            old_marking = grid[row, col]
            grid[row, col] = CHR_WALL

            loop::Bool = isloop!(grid, start, heading_start)
            if loop
                obstacles[row, col] = CHR_SEEN
            end

            grid[row, col] = old_marking
        end

        guard = target
    end

    # Always exclude the guard starting position!
    sx, sy = start
    obstacles[sy, sx] = CHR_FREE

    result = count(==(CHR_SEEN), obstacles)
    return result
end

println(part1())
println(part2())
