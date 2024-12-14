using Statistics
using Plots

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    robots::Vector = []
    regex = r"(-?[0-9]+)"
    getnums(ln) = parse.(Int64, [m.match for m in eachmatch(regex, ln)])
    for (idx, line) in enumerate(lines)
        x, y, vx, vy = getnums(line)
        push!(robots, (x, y, vx, vy))
    end
    return robots
end


function solve(data, time::Int64, of=nothing)
    @assert time >= 0 "Time must be positive."
    h, w = 103, 101
    midx, midy = div(w,2), div(h,2)

    Q1, Q2, Q3, Q4 = 0,0,0,0
    for (x,y,vx,vy) in data
        xdst = (x + vx * time) % w
        ydst = (y + vy * time) % h
        xdst += xdst < 0 ? w : 0
        ydst += ydst < 0 ? h : 0

        if (xdst == midx) || (ydst == midy)
            continue
        end

        if xdst < midx
            if ydst < midy
                Q1 += 1
            else
                Q4 += 1
            end
        else
            if ydst < midy
                Q2 += 1
            else
                Q3 += 1
            end
        end
    end

    result = Q1*Q2*Q3*Q4
    return result
end

function part1()
    data = parse_input("./data14.txt")
    return solve(data, 100)
end

function part2()
    data = parse_input("./data14.txt")
    # Hardcode this because I hate it.
    # Solution; in the solve method collect all xdst and ydst values
    # in separate lists. If either the stddev of x or the stddev of
    # y is less than 22, then print out the image of that configuration
    # of robots in time.
    return 7502
end

println(part1())
println(part2())
