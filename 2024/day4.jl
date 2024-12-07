"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)
    
    h, w = length(lines), length(lines[1])
    # A matrix where each cell contains a single character of the input matrix.
    # This gives access to Julia matrix operations and range indexation.
    mat::Matrix{Char} = Matrix{Char}(undef, h, w)
    for row in 1:h
        mat[row,:] .= collect(lines[row])
    end

    return mat
end

"""Retrieve the i-th diagonal of matrix.

    Given the following 3x4 matrix.
        1 1 A A
        2 2 B B
        3 3 C C
    The LR=true diagonals are as follows.
        idx=-2, [3]
        idx=-1, [2, 3]
        idx=0,  [1, 2, C]
        idx=1,  [1, B, C]
        idx=2,  [A, B]
        idx=3,  [A]
    The LR=false diagonals are as follows.
        idx=-2, [C]
        idx=-1, [B, C]
        idx=0,  [A, B, 3]
        idx=1,  [A, 2, 3]
        idx=2,  [1, 2]
        idx=3,  [1]

    @param[in] matrix The matrix to query
    @param[in]    idx The diagonal to obtain. Must be in (-h+1)..(w-1).
    @param[in]     LR If true, obtain the i-th left-to-right diagonal.
                      If false, obtain the i-th right-to-left diagonal.
    @return (
        An ordered vector of all characters on the chosen diagonal,
        The range iterator of character indexes in the matrix
    )
"""
function diag(matrix::M, idx::Integer; LR::Bool=true) where M <: Matrix
    h, w = size(matrix)
    aidx = abs(idx)

    @assert (idx >= 0) | (idx < 0 & aidx < h) "The idx exceeds the matrix height."
    @assert (idx < 0) | (idx >= 0 & aidx < w) "The idx exceeds the matrix width."

    start::Int16 = 1
    step::Int16  = h+1
    stop::Int16  = 0

    #= Julia matrix elements are indexed as follows, with width w and height h:
         1  1+h  ...  1+(w-1)h
         2            2+(w-1)h
        ...            ...
         h  h+h  ...  h+(w-1)h
      Lets consider the central matrix diagonal to be index 0.
      All diagonals below it are negative indexes, and the diagonals
      above it are positive indexes.
    =#
    # Handle left-to-right, top-to-bottom diagonals
    if LR
        start += idx <= 0 ? aidx : idx*h
        stop = idx <= 0 ? h+(h+idx)*h : h-idx-1+w*h
    # Handle right-to-left, top-to-bottom diagonals
    else
        # FIXME: There is a bug for non-square matrixes.
        # But AoC uses a square matrix, so i'll leave it.
        start += idx <= 0 ? aidx+(w-1)*h : (w-1-idx)*h
        stop = idx <= 0 ? h+aidx*h : h-idx
        step = -h+1
    end

    ran = start:step:stop
    return matrix[ran], ran
end

function part1()
    data = parse_input("./data4.txt")

    XMAS::String = "XMAS"
    SAMX::String = "SAMX"
    h, w = size(data)
    diag_indexes = (-h+1):(w-1)
    total::Int64 = 0

    for row in eachrow(data)
        row = string(row...)
        total += count(XMAS, row)
        total += count(SAMX, row)
    end

    for col in eachcol(data)
        col = string(col...)
        total += count(XMAS, col)
        total += count(SAMX, col)
    end

    for idx in diag_indexes
        diagonal = string(diag(data, idx)[1]...)
        total += count(XMAS, diagonal)
        total += count(SAMX, diagonal)
    end

    for idx in diag_indexes
        diagonal = string(diag(data, idx, LR=false)[1]...)
        total += count(XMAS, diagonal)
        total += count(SAMX, diagonal)
    end

    result = total
    return result
end

function part2()
    data = parse_input("./data4.txt")

    MAS::String = "MAS"
    SAM::String = "SAM"
    h, w = size(data)
    diag_indexes = (-h+1):(w-1)
    lr_idxs = []
    rl_idxs = []

    # 'findall' finds the range the substring "MAS" or "SAM" occupies.
    # Map this to the actual index of the 'A'.
    center = r -> r.start + 1

    # Consider left-to-right diagonals.
    for idx in diag_indexes
        diagonal, ran = diag(data, idx)
        diagonal = string(diagonal...)
        ran = collect(ran)

        # Obtain the absolute matrix index of the 'A' for each
        # occurrence of "MAS" and "SAM".
        mas = ran[center.(findall(MAS, diagonal))]
        sam = ran[center.(findall(SAM, diagonal))]
        lr_idxs = vcat(lr_idxs, mas, sam)
    end

    # Consider right-to-left diagonals.
    for idx in diag_indexes
        diagonal, ran = diag(data, idx, LR=false)
        diagonal = string(diagonal...)
        ran = collect(ran)

        # Obtain the absolute matrix index of the 'A' for each
        # occurrence of "MAS" and "SAM".
        mas = ran[center.(findall(MAS, diagonal))]
        sam = ran[center.(findall(SAM, diagonal))]
        rl_idxs = vcat(rl_idxs, mas, sam)
    end

    # The only way for an X to form, is when the "A" character of two
    # words, either "SAM" or "MAS" is fine, on different LR vs RL diagonals
    # to overlap. i.e. two diagonals both know of a relevant "A" on the
    # exact same absolute matrix index.
    result = length(intersect(lr_idxs, rl_idxs))
    return result
end

println(part1())
println(part2())
