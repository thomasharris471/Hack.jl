module Hack

using MutableNamedTuples

# Write your package code here.
export

    #utility functions
    test!,
    testseq!,
    testData,
    set!,
    eval!,
    value,
    updateNextOutput!,
    updateOutput!,
    rewire!,
    out,
    update!,
    increment!,
    tick!,
    output,
    testBit!,

    #pin
    Pin,

    #clock
    Clock,

    #one bit logic gates
    Nand, 
    Not,
    And,
    Nor,
    Xor,
    Or,
    Mux,
    DMux,

    #sixteen bit logic gates
    Not16,
    And16,
    Or16,
    Mux16,
    
    #mutliway gates
    Or8Way, 
    Mux4Way16,
    Mux8Way16,
    DMux4Way,
    DMux8Way,
    Nand3Way,

    #artihmetic chips
    Adder,
    FullAdder,
    Add16,
    Inc16,
    Zero,
    Negate,
    ALU,

    #sequential chips
    SRNand,
    SRAO,
    SR,
    DFF,
    DFF2,
    Bit



include("chips.jl")
include("pins.jl")
include("utils.jl")
include("arithmeticchips.jl")
include("sequentialchips.jl")



end
