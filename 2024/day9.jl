
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    return readlines(file_path)[1]
end

function malloc!(k::Int64, spp::Ref{Int64}, b::Ref{Int64}, freep::Ref{Int64})
    bmin = min(freep[], b[])
    m = bmin - 1
    n = spp[]

    freep[] = freep[] - bmin
    spp[] = spp[] + bmin
    b[] = b[] - bmin

    #=
            kn + k(n+1) + ... + k(n+m)
        = kn + kn     + ... + kn +
            0  + k      + ... + mk
        = kn(m+1) +
            k(1 + 2 + ... + m)
        = kn(m+1) + k(1/2 * m(m+1))
    =#
    return k*n*(m+1) + k * divrem(m*(m+1), 2)[1]
end

function part1()
    data = parse_input("./data9.txt")

    total::Int64 = 0
    min_id::Int64 = 0
    max_id::Int64, = divrem(length(data), 2)

    # Apply a two-pointer approach: Left-to-right & right-to-left
    spp = Ref(0)  # "stack pointer"
    freep = Ref(0) # The free space in the current free block
    pending = nothing
    need_free_space::Bool = true
    IDX_OFFSET::Int64 = 1 # Julia uses 1-indexed arrays =(
    while (min_id <= max_id)
        @assert freep[] >= 0 "Cannot have negative free space."
        # No known free space left, so find some.
        if need_free_space
            # The left-side files must remain in-place.
            filesize = Ref(parse(Int64, data[2*min_id+IDX_OFFSET]))
            freep[] += filesize[]
            total += malloc!(min_id, spp, filesize, freep)

            # Register free memory.
            freep[] += parse(Int64, data[2*min_id+1+IDX_OFFSET])

            min_id += 1
            need_free_space = !need_free_space
        # Known free space left, so fill it.
        else
            # Free space needs to be filled back-to-front, so use the
            # pending blocks first.
            if pending !== nothing
                id, filesize = pending
                total += malloc!(id, spp, filesize, freep)

                if filesize[] == 0
                    pending = nothing
                end
            # No pending blocks, so generate (and use) some new ones.
            else
                id = max_id
                filesize = Ref(parse(Int64, data[2*max_id+IDX_OFFSET]))
                total += malloc!(id, spp, filesize, freep)

                if filesize[] > 0
                    pending = (max_id, filesize)
                end
                # Always decrement the ID because the pending stores the old value.
                # Decrement after storing to pending, pending needs the old ID.
                max_id -= 1
            end

            # Iterating from the left has the express purpose of finding free
            # space into which we can move files from the right side.
            # Only stop iterating right when the current free space is used up.
            need_free_space = freep[] == 0
        end
    end

    # Ensure that no pending blocks remain.
    if pending !== nothing
        id, filesize = pending
        freep[] = filesize[] # don't care about "overwriting" non-free blocks
        total += malloc!(id, spp, filesize, freep)
    end

    result = total
    return result
end

function part2()
    data = parse_input("./data9.txt")

    result = data
    return result
end

println(part1())
# println(part2())
