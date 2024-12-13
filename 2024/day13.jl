# using LinearAlgebra

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    machines::Vector = []
    regex = r"([0-9]+)"
    getnums(ln) = parse.(Int64, [m.match for m in eachmatch(regex, ln)])
    for idx in 1:4:length(lines)
        xa, ya = getnums(lines[idx])
        xb, yb = getnums(lines[idx+1])
        xp, yp = getnums(lines[idx+2])
        push!(machines, (xa, ya, xb, yb, xp, yp))
    end
    return machines
end

function solve(data, offset::Int64)::Int64
    EPS::Float64 = 0.0001
    res = []
    for (xa, ya, xb, yb, xp, yp) in data
        # The offset is the problem's way to break brute force implementations.
        xp, yp = xp + offset, yp + offset

        #= Formulate each crane game as a system of equations,
          with variables a, b and constants xa, ya, xb, yb, xp, yp:

            a*xa + b*xb = xp
            a*ya + b*yb = yp

            ...

            a = (xp - ((yp*xa*xb - ya*xp*xb) / (yb*xa - ya*xb))) / xa
            b = (yp*xa - ya*xp) / (yb*xa - ya*xb)
        =#
        xsol, ysol = [
            (xp - ((yp*xa*xb - ya*xp*xb) / (yb*xa - ya*xb))) / xa
            (yp*xa - ya*xp) / (yb*xa - ya*xb)
        ]

        xr::Int64 = Int64(round(xsol))
        yr::Int64 = Int64(round(ysol))
        # Only closed form solutions with integer results are valid.
        # But floating point errors happen, so allow approximately
        # integer solutions.
        # All non-integer solutions correspond to no actual solution!
        if isapprox(xr, xsol, atol=EPS) & isapprox(yr, ysol, atol=EPS)
            sol::Int64 = 3*xr + yr
            push!(res, sol)
        end
    end
    return sum(res)
end

function part1()
    data = parse_input("./data13.txt")
    return solve(data, 0)
end

function part2()
    data = parse_input("./data13.txt")
    return solve(data, 10000000000000)
end

println(part1())
println(part2())
