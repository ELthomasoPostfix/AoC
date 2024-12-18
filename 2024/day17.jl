
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)

    A::Int64 = parse(Int64, lines[1][13:end])
    B::Int64 = parse(Int64, lines[2][13:end])
    C::Int64 = parse(Int64, lines[3][13:end])
    instructions::Vector{Int64} =
        parse.(Int64, (split(lines[5][10:end], ',')))

    return A, B, C, instructions
end

"""An implementation of my specific input assembly.

    Program: 2,4,1,1,7,5,1,5,0,3,4,3,5,5,3,0


    0     2,4    bst 4    B=A%8
    2     1,1    bxl 1    B=B xor 1
    4     7,5    cdv 5    C=A//2^B
    8     1,5    bxl 5    B=B xor 5
    10    0,3    adv 3    A=A//2^3
    12    4,3    bxc 3    B=B xor C
    14    5,5    out 5    out B
    16    3,0    jnz 0    jnz A, 0

    A := INPUT
    B := 0
    C := 0
    while A != 0
        B = (A%8) xor 1
        C = A // B
        B = (B xor 5) xor C
        out B
        A = A // 8
"""
function solve(A, B, C)
    outlst = []
    while A != 0
        B = xor(A%8, 1)
        C = div(A, 2^B)
        B = xor(xor(B, 5), C)
        push!(outlst, B%8)
        A = div(A, 8)
    end
    return join(map(string, outlst), ',')
end

"""All computations for a single iteration's out value."""
function digit(a)
    return xor(xor(a%8, 1, 5), div(a, 2^(xor(a%8, 1)))) % 8
end

"""Recursively find the 'A' that duplicates the instructions/program."""
function evlos(instructions; A::Int64=0)
    # Base case: No more instructions to predict A for.
    if isempty(instructions)
        return A
    end

    #= Each iteration of the algorithm drops the division remainder:
            Anew <- A // 8
      To discover the original A, try all possible remainders: rem in 0..7.
            A = Anew * 8 + rem
    =#
    viable_sols = collect(A*8 .+ (0:7))
    # All viable sols that actually result in outputting the expected digit are
    # valid solutions.
    valid_sols = findall(==(instructions[end]), digit.(viable_sols))

    # The interùediate 'A' built based on the viable solution choices of
    # the callers is not consistent for for this digit. Notify the caller.
    if isempty(valid_sols)
        return -1
    end

    # Check if the newly computed 'A' is consistent with all remaining digits.
    for match in valid_sols
        result = evlos(instructions[1:end-1], A=viable_sols[match])
        # If this 'A' was consistent, then pass up the recursively computed 'A'.
        if result != -1
            return result
        end
    end

    # None of the valid solutions were consistent.
    return -1
end

function part1()
    data = parse_input("./data17.txt")

    A,B,C, = data
    return solve(A,B,C)
end

function part2()
    data = parse_input("./data17.txt")

    _,_,_,instructions, = data
    return evlos(instructions)
end

println(part1())
println(part2())
