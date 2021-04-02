function intToBinary(int, bits)::Vector{Bool}
    array = []
    while int > 0
        prepend!(array, Bool(int % 2))
        int = (int - int % 2)/2
    end
    while Base.length(array) < bits
        prepend!(array, Bool(0))
    end
    return array
end

function test!(chip::Chip)
    inputData = [testData(input) for input in chip.inputs]
    for testvalues in Iterators.product(inputData...)
        map(set!, chip.inputs, testvalues)
        eval!(chip)
        for input in chip.inputs
            print(value(input))
            print(" ")
        end
        print(" | ")
        for output in chip.outputs
            print(value(output))
            print(" ")
        end
        println()
    end
    return nothing
end


