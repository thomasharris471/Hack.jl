abstract type Chip end

function eval!(chip::Chip)
    for part in chip.parts
        eval!(part)
    end
    return nothing
end

struct Nand <: Chip
    inputs
    parts
    outputs

    function Nand(a = Pin(), b = Pin())
        inputs = MutableNamedTuple(A = a, B = b)
        parts = nothing
        outputs = (Q = Pin(),)
        return new(inputs, parts, outputs)
    end
end

function eval!(chip::Nand)
    A = value(chip.inputs.A)
    B = value(chip.inputs.B)
    set!(chip.outputs.Q, !(A && B))
    return nothing
end

struct Not <: Chip
    inputs
    parts
    outputs

    function Not(a = Pin())
        inputs = MutableNamedTuple(A = a, )
        g1 = Nand(a, a)
        parts = [g1] 
        outputs = (Q = g1.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct And <: Chip
    inputs
    parts
    outputs

    function And(a = Pin(), b=Pin())
        inputs = MutableNamedTuple(A = a, B = b)
        g1 = Nand(a, b)
        g2 = Not(g1.outputs.Q)
        parts = [g1, g2] 
        outputs = (Q = g2.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct Or<: Chip
    inputs
    parts
    outputs

    function Or(a = Pin(), b=Pin())
        inputs = MutableNamedTuple(A = a, B = b)
        g1 = Not(a) 
        g2 = Not(b) 
        g3 = Nand(g1.outputs.Q, g2.outputs.Q)
        parts = [g1, g2, g3] 
        outputs = (Q = g3.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct Xor<: Chip
    inputs
    parts
    outputs

    function Xor(a = Pin(), b=Pin())
        inputs = MutableNamedTuple(A = a, B = b)
        g1 = Not(a) 
        g2 = Not(b)
        g3 = And(a, g2.outputs.Q)
        g4 = And(b, g1.outputs.Q)
        g5 = Or(g3.outputs.Q, g4.outputs.Q)
        parts = [g1, g2, g3, g4, g5] 
        outputs = (Q = g5.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct Mux <: Chip
    inputs
    parts
    outputs

    function Mux(a = Pin(), b=Pin(), sel=Pin())
        inputs = MutableNamedTuple(A = a, B = b, sel = sel)
        g1 = Not(sel) 
        g2 = And(a, g1.outputs.Q)
        g3 = And(b, sel)
        g4 = Or(g2.outputs.Q, g3.outputs.Q)
        parts = [g1, g2, g3, g4] 
        outputs = (Q = g4.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct DMux <: Chip
    inputs
    parts
    outputs

    function DMux(input = Pin(), sel = Pin() )
        inputs = MutableNamedTuple(input = input, sel = sel)
        g1 = Not(sel)
        aout = And(g1.outputs.Q, input)
        bout = And(sel, input)
        parts = [g1, aout, bout] 
        outputs = (a = aout.outputs.Q, b= bout.outputs.Q)
        return new(inputs, parts, outputs)
    end
end







struct Not16 <: Chip
    inputs
    parts
    outputs

    function Not16(a = [Pin() for i in 1:16])
        inputs = MutableNamedTuple(A = a, )
        parts = [Not(a[i]) for i in 1:16] 
        outputs = (Q = [chip.outputs.Q for chip in parts],)
        return new(inputs, parts, outputs)
    end
end

struct And16 <: Chip
    inputs
    parts
    outputs

    function And16(a = [Pin() for i in 1:16] , b = [Pin() for i in 1:16])
        inputs = MutableNamedTuple(A = a, B = b)
        parts = [And(a[i], b[i]) for i in 1:16] 
        outputs = (Q = [chip.outputs.Q for chip in parts],)
        return new(inputs, parts, outputs)
    end
end

struct Or16 <: Chip
    inputs
    parts
    outputs

    function Or16(a = [Pin() for i in 1:16] , b = [Pin() for i in 1:16])
        inputs = MutableNamedTuple(A = a, B = b)
        parts = [Or(a[i], b[i]) for i in 1:16] 
        outputs = (Q = [chip.outputs.Q for chip in parts],)
        return new(inputs, parts, outputs)
    end
end

struct Mux16 <: Chip
    inputs
    parts
    outputs

    function Mux16(a = [Pin() for i in 1:16] , b = [Pin() for i in 1:16], sel = Pin())
        inputs = MutableNamedTuple(A = a, B = b, sel = sel)
        parts = [Mux(a[i], b[i], sel) for i in 1:16] 
        outputs = (Q = [chip.outputs.Q for chip in parts],)
        return new(inputs, parts, outputs)
    end
end

struct Or8Way <: Chip
    inputs
    parts
    outputs

    function Or8Way(a = [Pin() for i in 1:8])
        inputs = MutableNamedTuple(A = a,)
        parts = [Or(a[1], a[2])]
        for i = 2:8
            append!(parts, [Or(parts[i-1].outputs.Q, a[i])])
        end
        outputs = (Q = parts[end].outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct Mux4Way16 <: Chip
    inputs
    parts
    outputs

    function Mux4Way16(a = [Pin() for i in 1:16], b = [Pin() for i in 1:16], c = [Pin() for i in 1:16], d = [Pin() for i in 1:16], sel = [Pin() for i in 1:2]) 
        inputs = MutableNamedTuple(A = a, B = b, C = c, D = d, sel = sel)

        g1 = Mux16(a, b, sel[1])
        g2 = Mux16(c, d, sel[1])
        g3 = Mux16(g1.outputs.Q, g2.outputs.Q, sel[2])
        parts = [g1, g2, g3]
        
        outputs = (Q = parts[end].outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct Mux8Way16 <: Chip
    inputs
    parts
    outputs

    function Mux8Way16(a = [Pin() for i in 1:16], b = [Pin() for i in 1:16], c = [Pin() for i in 1:16], d = [Pin() for i in 1:16],  e = [Pin() for i in 1:16], f = [Pin() for i in 1:16], g = [Pin() for i in 1:16], h = [Pin() for i in 1:16], sel = [Pin() for i in 1:3]) 
        inputs = MutableNamedTuple(A = a, B = b, C = c, D = d, E = e, F = f, G = g, H = h, sel = sel)

        g1 = Mux4Way16(a, b, c, d, [sel[1], sel[2]])
        g2 = Mux4Way16(e, f, g, h, [sel[1], sel[2]])
        g3 = Mux16(g1.outputs.Q, g2.outputs.Q, sel[3])

        parts = [g1, g2, g3]
        
        outputs = (Q = parts[end].outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct DMux4Way <: Chip
    inputs
    parts
    outputs

    function DMux4Way(input = Pin(), sel = [Pin() for i in 1:2]) 
        inputs = MutableNamedTuple(input = input, sel = sel)

        g1 = DMux(input, sel[2])
        g2 = DMux(g1.outputs.a, sel[1])
        g3 = DMux(g1.outputs.b, sel[1])
        parts = [g1, g2, g3]
        
        outputs = (a = g2.outputs.a, b = g2.outputs.b, c = g3.outputs.a, d = g3.outputs.b)
        return new(inputs, parts, outputs)
    end
end

struct DMux8Way <: Chip
    inputs
    parts
    outputs

    function DMux8Way(input = Pin(), sel = [Pin() for i in 1:3]) 
        inputs = MutableNamedTuple(input = input, sel = sel)

        g1 = DMux(input, sel[3])
        g2 = DMux4Way(g1.outputs.a, [sel[1], sel[2]])
        g3 = DMux4Way(g1.outputs.b, [sel[1], sel[2]])
        parts = [g1, g2, g3]
        
        outputs = (a = g2.outputs.a, b = g2.outputs.b, c = g2.outputs.c, d = g2.outputs.d, e = g3.outputs.a, f = g3.outputs.b, g = g3.outputs.c, h = g3.outputs.d)
        return new(inputs, parts, outputs)
    end
end

struct Nand3Way <: Chip
    inputs
    parts
    outputs

    function Nand3Way(a = Pin(), b = Pin(), c = Pin()) 
        inputs = MutableNamedTuple(A = a, B = b, C = c)

        g1 = Nand(a, b)
        g2 = Not(c)
        g3 = Or(g1.outputs.Q, g2.outputs.Q)

        parts = [g1, g2, g3]
        
        outputs = (Q = g3.outputs.Q,)
        return new(inputs, parts, outputs)
    end

end


