
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)
    L::Array = Array{Array{Integer}}(undef, length(lines))

    for (idx, line) in enumerate(lines)
        nums = split(line, " ")
        nums = map((str) -> parse(Int64, str), nums)
        L[idx] = nums
    end
    return L
end

function part1()
    data = parse_input("./data2.txt")

    # A sequence is ascending iff. all differences are >= 0.
    safe = Array{Bool}(undef, length(data))
    for (idx, report) in enumerate(data)
        # (1) The levels are either all increasing or all decreasing.
        diffs = data[idx][2:end] - data[idx][1:end-1]

        gte0 = (val) -> val >= 0
        increasing = all(gte0, diffs)
        
        lt0 = (val) -> val < 0
        decreasing = all(lt0, diffs)

        safe1 = increasing | decreasing

        # (2) Any two adjacent levels differ by at least one and at most three.
        diffbtwn = (val) -> 1 <= abs(val) & abs(val) <= 3
        safe2 = all(diffbtwn, diffs)

        # Store
        safe[idx] = safe1 & safe2
    end

    result = sum(safe)
    return result
end

function find_error_locations(datavec::Array)
    # (1) The levels are either all increasing or all decreasing.
    diffs = datavec[2:end] - datavec[1:end-1]

    gte0 = (val) -> val >= 0
    increasing = gte0.(diffs)
    
    lt0 = (val) -> val < 0
    decreasing = lt0.(diffs)

    bools1 = @. !(increasing | decreasing)

    # (2) Any two adjacent levels differ by at least one and at most three.
    diffbtwn = (val) -> 1 <= abs(val) & abs(val) <= 3
    bools2 = diffbtwn.(diffs)
    bools2 = @. !bools2

    # The error indexes can be used to determine safety.
    return findall(e -> e, bools1 .| bools2)
end

function part2()
    data = parse_input("./data2.txt")

    # A sequence is ascending iff. all differences are >= 0.
    safe = Array{Bool}(undef, length(data))
    for (idx, report) in enumerate(data)
        datavec = data[idx]

        error_idexes = find_error_locations(datavec)
        issafe = length(error_idexes) == 0

        for idx in error_idexes
            datavec = datavec[.!in.(1:end,([idx],))]
            error_indexes_corrected = find_error_locations(datavec)
            issafe = length(error_indexes_corrected) == 0
            if issafe
                break
            end
        end

        # Store
        safe[idx] = issafe
    end

    result = sum(safe)
    return result
end

println(part1())
println(part2())
