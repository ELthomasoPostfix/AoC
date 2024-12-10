using DataStructures

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    topomap::Matrix{Int8} = Matrix{Int8}(undef, length(lines), length(lines[1]))
    for (idx, line) in enumerate(lines)
        topomap[idx,:] = [parse(Int8, c) for c in line]
    end
    return topomap
end

"""Find all reachable peaks from the given trailhead.

    @param[in]            topomap The topological heightmap
    @param[in]          trail_loc The current position along the trail
    @param[in] allow_duponlicates If true, find only unique peaks.
                                  Else, find a peak for each way to reach
                                  that peak.
    @return All reachable peaks (duplicates may be possible)
"""
function trail_peaks(topomap::Matrix{Int8}, trail_loc::Tuple{Int64, Int64},
                         allow_duplicates::Bool)
    # For unique peaks, count only the number of peaks with a set.
    # For all paths, count the peak once for each path found.
    container = allow_duponlicates ? Vector : Set

    r, c = trail_loc
    h, w = size(topomap)
    curr_height = topomap[r,c]
    if curr_height == 9
        return container([trail_loc])
    end
    reachable = container()
    for (dr, dc) in [(0,1), (1,0), (0,-1), (-1,0)]
        rn, cn = r+dr, c+dc
        # A trail must strictly increase in height.
        if !((1 <= rn <= w) & (1 <= cn <= h))
            continue
        end
        next_height = topomap[rn, cn]
        if next_height != (curr_height+1)
            continue
        end
        # 
        reachable = container([
            reachable...,
            trail_peaks(topomap, (rn, cn), allow_duplicates)...
        ])
    end
    return reachable
end

function solve(data, flag::Bool)
    trailheads = findall(==(0), data)
    trailheads = [Tuple(i) for i in trailheads] # Typecast
    scores = [length(trail_peaks(data, head, flag)) for head in trailheads]
    
    return sum(scores)
end

function part1()
    data = parse_input("./data10.txt")

    return solve(data, false)
end

function part2()
    data = parse_input("./data10.txt")

    return solve(data, true)
end

println(part1())
println(part2())
