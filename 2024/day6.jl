
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

function part1()
    data = parse_input("./data6.txt")

    grid, guard = data
    h, w = size(grid)

    heading::Int16 = 0
    while guard !== nothing
        #=  heading  |  look dir  |  str dir
               0     |     UP     |   PREV
               1     |    RIGHT   |   NEXT
               2     |    DOWN    |   NEXT
               3     |    LEFT    |   PREV
        =#
        x, y = guard
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
        
        if z === nothing
            target = vertical ?
                (x, max(1, h * (heading - 1))) :
                (max(1, w * -(heading - 2)), y)

            guard = nothing
        else
            z += sign(start - z) # z is on top of the wall, move one step back
            target = vertical ? (x, z) : (z, y)
            guard = target
            heading = (heading + 1) % 4
        end
        u, v = target
        row_ran = min(u,x):max(u,x)
        col_ran = min(v,y):max(v,y)
        grid[col_ran, row_ran] .= CHR_SEEN
    end


    result = count(==(CHR_SEEN), grid)
    return result
end

function part2()
    data = parse_input("./data6.txt")

    result = data
    return result
end

println(part1())
# println(part2())
