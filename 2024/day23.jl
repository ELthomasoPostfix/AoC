using DataStructures

"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    connections::Dict = Dict()
    for (idx, line) in enumerate(lines)
        name1, name2 = split(line, "-")
        name1 = string(name1)
        name2 = string(name2)
        conns = get!(connections, name1, [])
        push!(conns, name2)
        conns = get!(connections, name2, [])
        push!(conns, name1)
    end
    return connections
end

function part1()
    data = parse_input("./data23.txt")

    triangles::Set = Set()
    for p1 in keys(data)
        # We only care about triangles containing a name starting in 't'.
        # We iterate over all vertices, so enforce this for the initial vertex.
        if p1[1] != 't'
            continue
        end
        # For all states reachable in one (1) transition.
        for p2 in data[p1]
            # For all states reachable in two (2) transitions.
            for p3 in data[p2]
                # Add only the triangles: p1 -> p2 -> p3 -> p1
                if p1 in data[p3]
                    # Sort so that the set of triangles retains only one
                    # copy of each triangle.
                    push!(triangles, sort([p1, p2, p3]))
                end
            end
        end
    end
    return length(triangles)
end

function part2()
    data = parse_input("./data23.txt")


    groups = []
    for p1 in keys(data)
        # Note: WE DONT CARE ABOUT 't' BEING IN A NAME ANYMORE.
        # We just want to find the largest LAN party in general.
        group = Set([p1])
        # A LAN party is a k-clique in the graph.
        # Only nodes directly reachable from / adjacent to the initial vertex
        # could ever be in the same clique.
        # If an adjacent vertex is also adjacent to all other vertices in the
        # intermediate clique, then it is in the clique.
        for p2 in data[p1]
            if intersect(group, data[p2]) == group
                push!(group, p2)
            end
        end

        push!(groups, group)
    end

    _, maxidx = findmax(length.(groups))
    pwd = sort([s for s in groups[maxidx]])
    pwd = join(pwd, ',')
    return pwd
end

println(part1())
println(part2())
