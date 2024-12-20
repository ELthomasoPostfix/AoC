CHR_BOX::Char = 'O'
CHR_WALL::Char = '#'
CHR_FREE::Char = '.'
CHR_ROBOT::Char = '@'
CHR_BOX_WL::Char = '['
CHR_BOX_WR::Char = ']'
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

"""Shove all boxes in the given direction one free space forwards.

    If any wall is in front of any of the attached boxes, then the
    entire movement is nullified.
"""
function shove_boxes(positions::Array{CI}, dir::CI, matrix::Matrix{Char};
                  depth::Int64=0) where CI <: CartesianIndex
    move_is_vert::Bool = dir[2] == 0


    # Free space found so that  all boxes seen until now can be moved one
    # space, AND no walls were encountered to block this move.
    # Note: If only free spaces remained, then the list must now be empty.
    if isempty(positions)
        return nothing
    end

    # Keep all to-search positions in the same line (lock-step)
    # to detect the earliest wall blocking any box.
    positions_next::Array{CartesianIndex{2}} = []
    for pos in positions
        next = pos + dir
        if matrix[next] == CHR_BOX_WL && move_is_vert
            push!(positions_next, next + MV_RIGHT)
        elseif matrix[next] == CHR_BOX_WR && move_is_vert
            push!(positions_next, next + MV_LEFT)
        end
        push!(positions_next, next)
    end
    # Avoid duplicate coordinates, they may clash when shifting grid contents.
    positions_next = unique(positions_next)
    # A free position does not contain a to-be-moved box.
    # Each box is moved at most one free space, so we may immediately
    # discard free space positions.
    positions_next = [pos for pos in positions_next if matrix[pos] != CHR_FREE]

    # Walls block all movement.
    if any(==(CHR_WALL), matrix[positions_next])
        return nothing
    end

    shove_boxes(positions_next, dir, matrix, depth=depth+1)

    # If all positions ahead are free, then we can move all boxes one space.
    if all(==(CHR_FREE), matrix[positions_next])
        for pos in positions
            pos_next = pos + dir
            matrix[pos_next] = matrix[pos]
            matrix[pos] = CHR_FREE
        end
    end
end

function solve!(boxgrid, moves, robot, box_symbol::Char)
    mmap = Dict(
        CHR_UP    => MV_UP,
        CHR_RIGHT => MV_RIGHT,
        CHR_DOWN  => MV_DOWN,
        CHR_LEFT  => MV_LEFT
    )

    for move in moves
        dir = mmap[move]
        next = robot + dir

        shove_boxes([robot],  dir, boxgrid)

        # After pushing boxes, only move if you made room just now.
        if boxgrid[next] != CHR_FREE
            continue
        end
        robot = next
    end

    boxes = findall(==(box_symbol), boxgrid)
    return sum([100*(box[1]-1) + box[2]-1 for box in boxes])
end

function part1()
    data = parse_input("./data15.txt")
    return solve!(data..., CHR_BOX)
end

function part2()
    data = parse_input("./data15.txt")

    boxgrid, moves, robot = data
    widebot = CartesianIndex(robot[1], 2*robot[2] - 1)

    h, w = size(boxgrid)
    widegrid::Matrix{Char} = Matrix{Char}(undef, h, 2*w)
    for (rowidx, row) in enumerate(eachrow(boxgrid))
        widegrid[rowidx, 1:2:end] .= replace(row, CHR_BOX => CHR_BOX_WL)
        widegrid[rowidx, 2:2:end] .= replace(row, CHR_BOX => CHR_BOX_WR)
    end

    return solve!(widegrid, moves, widebot, CHR_BOX_WL)
end

println(part1())
println(part2())
