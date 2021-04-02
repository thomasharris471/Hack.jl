module Hack

# Write your package code here.
export

    #utility functions
    test!,

    #one bit logic gates
    Nand, 
    Not,
    And,
    Xor,
    Or,
    Mux,
    DMux,

    #sixteen bit logic gates
    Not16


include("chips.jl")
include("pins.jl")
include("utils.jl")


end
