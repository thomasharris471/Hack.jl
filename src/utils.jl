#a
function intToBinary(int, bits)::Vector{Bool}
    array = []
    while int > 0
        append!(array, Bool(int % 2))
        int = (int - int % 2)/2
    end
    while Base.length(array) < bits
        append!(array, Bool(0))
    end
    return array
end

function test!(chip::Chip)
    inputData = [testData(input) for input in chip.inputs]
    orderedIns = []
    orderedOuts = []
    for testvalues in Iterators.product(inputData...)
        map(set!, chip.inputs, testvalues)
        for i = 1:10
#            eval!(chip)
            updateNextOutput!(chip)
            updateOutput!(chip)
  
        end
        for input in chip.inputs
            print(value(input))
            print(" ")
            append!(orderedIns, [value(input)])
        end
        print(" | ")
        for output in chip.outputs
            print(value(output))
            print(" ")
            append!(orderedOuts, [value(output)])
        end
        println()
    end
    return (orderedIns, orderedOuts)
end

function testBit!(chip::Chip, Clock::Chip)
    inputData = [testData(chip.inputs.data), testData(chip.inputs.load)]
    orderedIns = []
    orderedOuts = []
    while !out(Clock)
        update!(clock)
    end
    previousLoad = false
    previousData = false
    previousOut = false
    for testvalues in Iterators.product(inputData...)
        map(set!, [chip.inputs.data, chip.inputs.load], testvalues)
        updateNextOutput!(Clock)
        updateNextOutput!(chip)
        updateOutput!(Clock)
        updateOutput!(chip)

        if previousLoad
            println(out(chip) == previousData)
        else
            println(out(chip) == previousOut)
        end
        
        previousData = value(chip.inputs.data)
        previousLoad = value(chip.inputs.load)
        previousOut = out(chip)
        while out(Clock)
            updateNextOutput!(Clock)
            updateNextOutput!(chip)
            updateOutput!(Clock)
            updateOutput!(chip)
        end
        while !out(Clock)
            updateNextOutput!(Clock)
            updateNextOutput!(chip)
            updateOutput!(Clock)
            updateOutput!(chip)
        end
    end

    return (orderedIns, orderedOuts)

end


function testseq!(chip::Chip)
   inputData = [[0,0,0,0,0,0,0,0,0,1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1], [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1, 0, 0, 0, 1, 1, 1]]
    
    orderedIns = []
    orderedOuts = []
    for testvalues in Iterators.product(inputData...)
        map(set!, chip.inputs, testvalues)
        for i = 1:3
            updateNextOutput!(chip)
            updateOutput!(chip)
            for input in chip.inputs
                print(value(input))
                print(" ")
                append!(orderedIns, [value(input)])
            end
            print(" | ")
            for output in chip.outputs
                print(value(output))
                print(" ")
                append!(orderedOuts, [value(output)])
            end
            println()
        end
    end
    return (orderedIns, orderedOuts)
end

