
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
        
        lt0 = (val) -> val <= 0
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

    # For an incr (decr) series, all decr (incr) are errors.
    gte0 = (val) -> val >= 0
    increasing = @. !gte0(diffs)

    lt0 = (val) -> val <= 0
    decreasing = @. !lt0(diffs)

    # If the series is monotonically incr (decr), then default to no errors
    # according to this property.
    is_monotonic::Bool = all(increasing) | all(decreasing)
    increasing = !is_monotonic .& increasing
    decreasing = !is_monotonic .& decreasing

    # Cyclic left shift of the list elements.
    # This breaks if the final element violates monotonicity?
    increasing = vcat(increasing[end], increasing[1:(end-1)])
    increasing = vcat(decreasing[end], decreasing[1:(end-1)])

    # (2) Any two adjacent levels differ by at least one and at most three.
    diffbtwn = (val) -> 1 <= abs(val) & abs(val) <= 3
    bools_diff = diffbtwn.(diffs)
    bools_diff = @. !bools_diff

    # Both incr and decr series must conform to the abs diff size constraints.
    bools_incr = @. increasing | bools_diff
    bools_decr = @. decreasing | bools_diff


    # The error indexes can be used to determine safety.
    indexes = findall(e -> e, bools_incr .| bools_decr)
    # Each erroneous diff results in two error indexes
    indexes = union(indexes, indexes .+ 1)
    return indexes
end

function part2()
    data = parse_input("./data2.txt")

    # A sequence is ascending iff. all differences are >= 0.
    safe = Array{Bool}(undef, length(data))
    for (idx1, report) in enumerate(data)
        datavec = report

        error_idexes = find_error_locations(datavec)
        issafe = length(error_idexes) == 0

        for idx in error_idexes
            datavec = report[.!in.(1:end,([idx],))]
            error_indexes_corrected = find_error_locations(datavec)
            issafe = length(error_indexes_corrected) == 0
            if issafe
                break
            end
        end

        # Store
        safe[idx1] = issafe
    end

    result = sum(safe)
    return result
end

println(part1())
println(part2())
