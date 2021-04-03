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
    Not16,
    And16,
    Or16,
    Mux16,
    
    #mutliway gates
    Or8Way, 
    Mux4Way16,
    Mux8Way16,
    DMux4Way,
    DMux8Way



include("chips.jl")
include("pins.jl")
include("utils.jl")



end
