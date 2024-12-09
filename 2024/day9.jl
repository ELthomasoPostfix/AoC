
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    return readlines(file_path)[1]
end

"""Compute a partial checksum. Is constrained by free space available.

    @param[in]         k The file ID
    @param[in,out]   spp The "stack pointer", which is the current index
    @param[in,out]     b The file size pointer, the number of blocks to allocate
    @param[in,out] freep The free space size pointer.
    @return The partial checksum
"""
function malloc!(k::Int64, spp::Ref{Int64}, b::Ref{Int64}, freep::Ref{Int64})
    bmin = min(freep[], b[])

    freep[] = freep[] - bmin[]
    b[] = b[] - bmin[]

    return mallocu!(k, spp, bmin)
end

"""Compute a partial checksum. Does not consider free space available.

    @param[in]       k The file ID
    @param[in,out] spp The "stack pointer", which is the current index
    @param[in]       b The file size, the number of blocks to allocate
    @return The partial checksum
"""
function mallocu!(k::Int64, spp::Ref{Int64}, b::Int64)
    m = b - 1
    n = spp[]

    spp[] = spp[] + b

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

    total::Int64 = 0

    # File list format is: [(ID0, size0), ..., (IDN, sizeN)]
    files = data[1:2:length(data)]
    files = map(((idx, bsize),) -> (idx-1, parse(Int64, bsize)), enumerate(files))
    # Free block list format is: [(size0, []), ..., (sizeM, [])]
    # where the list of the free space contains moved files.
    frees = data[2:2:length(data)]
    frees = map(((idx, bsize),) -> (idx, parse(Int64, bsize), []), enumerate(frees))
    # There is always one less free space than files. Padd with a dummy space.
    push!(frees, (0, 0, []))

    for (fidx, file) in enumerate(reverse(files))
        fidx = length(files) - fidx + 1 # Compensate the reverse
        fid, filesize = file
        for (midx, free) in enumerate(frees)
            mid, freesize, moved = free
            # Files may only be moved to free space on their left.
            if mid > fid
                break
            # Files must be moved in their entirety; there must be enoug room.
            elseif freesize < filesize
                continue
            end

            # If a valid, free space is found, then move the file and quit.
            # Setting id=0 converts the file to whitespace.
            # The filesize is needed for later tallying.
            files[fidx] = (0, filesize)
            push!(moved, file)
            frees[midx] = (mid, freesize - filesize, moved)
            break
        end
    end

    @assert length(files) == length(frees) "Unequal lengths, zip will malfunction."
    spp = Ref(0) # "stack pointer"
    for (file, free) in zip(files, frees)
        fid, fsize = file
        _, msize, moved = free

        # The file precedes the free space.
        total += mallocu!(fid, spp, fsize)
        # The free space was filled left-to-right with files.
        for mfile in moved
            mfid, mfsize = mfile
            total += mallocu!(mfid, spp, mfsize)
        end
        mallocu!(0, spp, msize) # Only moves the "stack pointer'
    end

    result = total
    return result
end

println(part1())
println(part2())
