CHR_FREE::Char = '.'


"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    antennas::Dict = Dict()
    antinodes::Matrix{Bool} = falses(length(lines), length(lines[1]))
    for (row, line) in enumerate(lines)
        for (col, char) in enumerate(line)
            if char == CHR_FREE
                continue
            end
            push!(get!(antennas, char, []), (row, col))
        end
    end
    return antennas, antinodes
end

function set!(grid, row, col, val)
    h, w = size(grid)
    if (1 <= row <= h) & (1 <= col <= w)
        grid[row, col] = val
        return true
    end
    return false
end

function part1()
    antennas, antinodes = parse_input("./data8.txt")

    for key in keys(antennas)
        positions = antennas[key]
        # Consider all possible same-signal antenna combinations.
        for (idx, pos1) in enumerate(positions)
            for pos2 in positions[(idx+1):end]
                x1, y1 = pos1
                x2, y2 = pos2
                n1x, n1y = (x1 + x1 - x2, y1 + y1 - y2)
                n2x, n2y = (x2 + x2 - x1, y2 + y2 - y1)
                set!(antinodes, n1x, n1y, true) # The x1 adjacent point
                set!(antinodes, n2x, n2y, true) # The x2 adjacent point
            end
        end
    end

    result = count(==(true), antinodes)
    return result
end

function part2()
    antennas, antinodes = parse_input("./data8.txt")

    for key in keys(antennas)
        positions = antennas[key]
        for (idx, pos1) in enumerate(positions)
            for pos2 in positions[(idx+1):end]
                x1, y1 = pos1
                x2, y2 = pos2
                s1x, s1y = x1 - x2, y1 - y2
                n1x, n1y = x1 + s1x, y1 + s1y
                # All points between x1 and the grid border.
                while set!(antinodes, n1x, n1y, true)
                    n1x += s1x
                    n1y += s1y
                end
                # Note the different start coords for this part compared to
                # the part 1 solution! This essentially also includes both
                # antennas as valid locations.
                s2x, s2y = x2 - x1, y2 - y1
                n2x, n2y = x1, y1
                # All points from and including x1 to the opposite grid border.
                while set!(antinodes, n2x, n2y, true)
                    n2x += s2x
                    n2y += s2y
                end
            end
        end
    end

    result = count(==(true), antinodes)
    return result
end

println(part1())
println(part2())
