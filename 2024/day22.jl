
"""Parse the input into a form that both parts can use.

    @param[in] The path to the input file.
"""
function parse_input(file_path::String)
    lines::Array{String} = readlines(file_path)
    return parse.(Int64, lines)
end

function solve(secret::Int64, iterations::Int64)
    @assert iterations > 0 "Positive iterations required"
    # Extract the 1-digit of the given secret: e.g. 4455662 => 2
    price(s) = s % 10
    prices::Array{Int64} = Array{Int64}(undef, iterations+1)
    prices[1] = price(secret)   # The initial price

    for it in 1:iterations
        secret = xor(secret << 6, secret) % 16777216    # op + mix
        secret = xor(secret >> 5, secret) % 16777216    # op + mix
        secret = xor(secret << 11, secret) % 16777216   # op + mix
        prices[it+1] = price(secret)
    end

    # There is one less price change than there are prices.
    changes = prices[2:end] - prices[1:end-1]
    buy_prices::Dict = Dict()
    for idx in 4:length(changes)
        # We must index the FIRST OCCURRENCE all length 4 price change slices.
        cseq = changes[idx-3:idx]
        if cseq in keys(buy_prices)
            continue
        end
        # Do +1, since price change i is the change from price i to price i+1.
        buy_prices[cseq] = prices[idx+1]
    end

    # Return the final secret and the buy prices indexed by change slice.
    return secret, buy_prices
end

function part1()
    data = parse_input("./data22.txt")
    final_secrets = getindex.(solve.(data, 2000), 1)
    return sum(final_secrets)
end

function part2()
    data = parse_input("./data22.txt")

    profits::Dict = Dict()
    buy_prices = getindex.(solve.(data, 2000), 2)
    # Aggregate the first-occurrence buy price per length 4 change slice.
    mergewith!(+, profits, buy_prices...)

    return maximum(values(profits))
end

println(part1())
println(part2())
