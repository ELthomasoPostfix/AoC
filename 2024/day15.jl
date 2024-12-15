CHR_BOX::Char = 'O'
CHR_WALL::Char = '#'
CHR_FREE::Char = '.'
CHR_ROBOT::Char = '@'
CHR_BOX_WIDE::Char = '['
CHR_UP::Char = '^'
CHR_RIGHT::Char = '>'
CHR_DOWN::Char = 'v'
CHR_LEFT::Char = '<'
MV_UP::CartesianIndex = CartesianIndex(-1,0)
MV_RIGHT::CartesianIndex = CartesianIndex(0,1)
MV_DOWN::CartesianIndex = CartesianIndex(1,0)
MV_LEFT::CartesianIndex = CartesianIndex(0,-1)


"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)
    divider::Int64 = findfirst(==(""), lines)
    gridlines = lines[1:divider-1]
    movelines = lines[divider+1:end]

    robot::CartesianIndex = CartesianIndex(0,0)
    boxgrid::Matrix{Char} = Matrix{Char}(undef, length(gridlines), length(gridlines[1]))
    for (idx, line) in enumerate(gridlines)
        boxgrid[idx, :] .= collect(line)
        rpos = findfirst(==(CHR_ROBOT), line)
        if rpos !== nothing
            robot = CartesianIndex(idx, rpos)
            boxgrid[robot] = CHR_FREE
        end
    end

    # Concatenate all move lines for easier handling
    moves = *(movelines...)

    return boxgrid, moves, robot
end

"""Return the position of the nearest '.' symbol, else nothing."""
function findfree(pos::CartesianIndex, dir::CartesianIndex, matrix::Matrix{Char})
    r, c = pos[1], pos[2]
    h, w = size(matrix)
    @assert (1 <= r <= h) && (1 <= c <= w) "Position out of bounds."

    while matrix[pos] != CHR_WALL
        pos = pos + dir
        if matrix[pos] == CHR_FREE
            return pos
        end
    end
    return nothing
end

function solve(data)
    boxgrid, moves, robot = data

    mmap = Dict(
        CHR_UP    => MV_UP,
        CHR_RIGHT => MV_RIGHT,
        CHR_DOWN  => MV_DOWN,
        CHR_LEFT  => MV_LEFT
    )

    for move in moves
        dir = mmap[move]
        next = robot + dir

        # Walls block any movement.
        if boxgrid[next] == CHR_WALL
            continue
        end
        # If there is no free space until the neares wall, then do nothing.
        free = findfree(robot,  dir, boxgrid)
        if free === nothing
            continue
        end

        # Avoid the case where there is no b
        if boxgrid[next] == CHR_BOX
            ran(c1::Int64, c2::Int64) = min(c1, c2):1:max(c1, c2)

            # Tomfoolery because movement in a matrix is inverted compared to
            # movement in a cartesian coordinate space.
            ran_dir = dir
            lastbox = free - ran_dir
            tgt_start = next + ran_dir

            row_ran_src = ran(next[1], lastbox[1])
            row_ran_tgt = ran(tgt_start[1], free[1])
            col_ran_src = ran(next[2], lastbox[2])
            col_ran_tgt = ran(tgt_start[2], free[2])
            boxgrid[row_ran_tgt, col_ran_tgt] .= boxgrid[row_ran_src, col_ran_src]
            boxgrid[next] = CHR_FREE
        end
        robot = next
    end

    boxes = findall(==(CHR_BOX), boxgrid)
    return sum([100*(box[1]-1) + box[2]-1 for box in boxes])
end

function part1()
    data = parse_input("./data15.txt")
    return solve(data)
end

function part2()
    data = parse_input("./data15.txt")
    return solve(data)
end

println(part1())
# println(part2())
