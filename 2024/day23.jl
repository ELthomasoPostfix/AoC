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

function dot(g)
    of = open("out.txt", "w")
    write(of, "digraph {\n")
    for (src, dsts) in pairs(g)
        for dst in dsts
            write(of, "  $src -> $dst\n")
        end
    end
    write(of, "}\n")
end

"""Tarjan's algorithm for SCCs.

    Pseudocode taken from https://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm
"""
function tarjan(graph::Dict)
    stack = Stack{String}()
    metadata::Dict = Dict{String, Tuple{Int64, Int64, Bool}}()
    sccs::Vector{Vector{String}} = []
    index::Int64 = 0
    for v in keys(graph)
        if !(v in keys(metadata))
            sub_sccs = strongconnect(v, index, graph, stack, metadata)
            sccs = vcat(sccs, sub_sccs)
        end
    end
    return sccs
end

function strongconnect(vertex::S, index::Int64, graph::Dict, stack::Stack, metadata::Dict) where S <: String
    sccs = []
    metadata[vertex] = (index, index, true)
    index += 1
    push!(stack, vertex)

    isonstack(v) = metadata[v][3]

    for successor in graph[vertex]
        if !(successor in keys(metadata))
            sub_sccs = strongconnect(successor, index, graph, stack, metadata)
            sccs = vcat(sccs, sub_sccs)
            _, slidx, = metadata[successor]
            vidx, vlidx, vonstack = metadata[vertex]
            metadata[vertex] = (vidx, min(vlidx, slidx), vonstack)
        elseif isonstack(successor)
            sidx, = metadata[successor]
            vidx, vlidx, vonstack = metadata[vertex]
            metadata[vertex] = (vidx, min(vlidx, sidx), vonstack)
        end
    end

    vidx, vlidx, vonstack = metadata[vertex]
    if vlidx == vidx
        scc = []
        successor = ""
        while successor != vertex
            successor = pop!(stack)
            sidx, slidx, = metadata[successor]
            metadata[successor] = (sidx, slidx, false)
            push!(scc, successor)
        end
        push!(sccs, scc)
        return sccs
    end
    return []
end

function part1()
    data = parse_input("./data23.txt")

    triangles = Set()
    for p1 in keys(data)
        if p1[1] != 't'
            continue
        end
        for p2 in data[p1]
            for p3 in data[p2]
                if p1 in data[p3]
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
        group = Set([p1])
        for p2 in data[p1]
            if intersect(group, data[p2]) == group
                push!(group, p2)
            end
        end

        push!(groups, group)
    end
    groups = unique(groups)

    _, maxidx = findmax(length.(groups))
    pwd = sort([s for s in groups[maxidx]])
    pwd = join(pwd, ',')
    return pwd
end

println(part1())
println(part2())
