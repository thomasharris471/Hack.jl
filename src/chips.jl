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
        inputs = (A = a, B = b)
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
        inputs = (A = a, )
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
        inputs = (A = a, B = b)
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
        inputs = (A = a, B = b)
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
        inputs = (A = a, B = b)
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
        inputs = (A = a, B = b, sel = sel)
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
        inputs = (input = input, sel = sel)
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
        inputs = (A = a, )
        parts = [Not(a[i]) for i in 1:16] 
        outputs = (Q = [chip.outputs.Q for chip in parts],)
        return new(inputs, parts, outputs)
    end
end


