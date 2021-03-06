struct Adder <: Chip
    inputs
    parts
    outputs

    function Adder(a = Pin(), b = Pin())
        inputs = MutableNamedTuple(a = a, b = b)
        sumChip = Xor(a, b)
        carryChip = And(a, b)
        parts = [sumChip, carryChip] 
        outputs = (sum = sumChip.outputs.Q, carry = carryChip.outputs.Q)
        return new(inputs, parts, outputs)
    end
end

struct FullAdder <: Chip
    inputs
    parts
    outputs

    function FullAdder(a = Pin(), b = Pin(), c = Pin())
        inputs = MutableNamedTuple(a = a, b = b, c = c)
        g1 = Adder(a, b)
        g2 = Adder(g1.outputs.sum, c)
        g3 = Or(g1.outputs.carry, g2.outputs.carry)
        parts = [g1, g2, g3] 
        outputs = (sum = g2.outputs.sum, carry = g3.outputs.Q)
        return new(inputs, parts, outputs)
    end
end

struct Add16 <: Chip
    inputs
    parts
    outputs

    function Add16(a = [Pin() for i in 1:16], b = [Pin() for i in 1:16])
        inputs = MutableNamedTuple(a = a, b = b)
        parts = []
        push!(parts, Adder(a[1], b[1]))
        for i in 2:16
            previousCarry = parts[i-1].outputs.carry 
            nextSumPart = FullAdder(a[i], b[i], previousCarry)
            push!(parts, nextSumPart)
        end
                
        outputs = (Q = [chip.outputs.sum for chip in parts], )
        return new(inputs, parts, outputs)
    end
end

struct Inc16 <: Chip
    inputs
    parts
    outputs

    function Inc16(a = [Pin() for i in 1:16])
        inputs = MutableNamedTuple(a = a, )
        g1pins = [Pin() for i in 1:16]
        for i in 1:16
            set!(g1pins[i], i==1)
        end
        g1 = Add16(a, g1pins) 
        parts = [g1]
                        
        outputs = (Q = g1.outputs.Q, )
        return new(inputs, parts, outputs)
    end
end


struct Zero <: Chip
    inputs
    parts
    outputs

    function Zero(x = [Pin() for i in 1:16],  zx = Pin())
        inputs = MutableNamedTuple(x = x, zx = zx )
        
        zeros = [Pin() for i in 1:16]
        for z in zeros
            set!(z, false)
        end
        mux = Mux16(x, zeros, zx)

        parts = [mux]

        outputs = (Q = output(mux), )

        return new(inputs, parts, outputs)
    end
end

function rewire!(chip::Zero; x = chip.inputs.x,  zx = chip.inputs.zx)

    chip.inputs.x = x
    chip.inputs.zx = zx 

    mux = chip.parts[1]

    rewire!(mux, A = x, sel = zx)

end



struct Negate <: Chip
    inputs
    parts
    outputs

    function Negate(x = [Pin() for i in 1:16],  nx = Pin())
        inputs = MutableNamedTuple(x = x, nx = nx )
        inverted = Not16(x)
        negated = Inc16(inverted.outputs.Q)
        muxed = Mux16(x, negated.outputs.Q, nx)
        parts = [inverted, negated, muxed]
        outputs = (Q = muxed.outputs.Q, )

        return new(inputs, parts, outputs)
    end
end

function rewire!(chip::Negate; x = chip.inputs.x,  nx = chip.inputs.nx)

    chip.inputs.x = x
    chip.inputs.nx = nx

    inverted = chip.parts[1]
    muxed = chip.parts[3]

    rewire!(inverted, A = x)
    rewire!(muxed, A = x, sel = nx)

end






struct ALU <: Chip
    inputs
    parts
    outputs

    function ALU(x = [Pin() for i in 1:16], y = [Pin() for i in 1:16], zx = Pin(), nx = Pin(), zy = Pin(), ny = Pin(), f = Pin(), no = Pin())
        inputs = MutableNamedTuple(x = x, y = y, zx = zx, nx = nx, zy = zy, ny = ny, f = f, no = no )
        x1 = Zero(x, zx)
        x2 = Negate(x1.outputs.Q, nx)

        y1 = Zero(y, zy)
        y2 = Negate(y1.outputs.Q, ny)

        g1 = Add16(x2.outputs.Q, y2.outputs.Q)
        g2 = And16(x2.outputs.Q, y2.outputs.Q)

        g3 = Mux16(g2.outputs.Q, g1.outputs.Q, f)

        g4 = Negate(g3.outputs.Q, no)
        or1 = Or8Way(g4.outputs.Q[1:8])
        or2 = Or8Way(g4.outputs.Q[9:16])
            
        zr0 = Or(or1.outputs.Q, or2.outputs.Q)
        zr = Not(zr0.outputs.Q) 
        parts = [x1, x2, y1, y2, g1, g2, g3, g4, or1, or2,zr0,  zr] 
        outputs = (out = g4.outputs.Q, zr = zr.outputs.Q, ng = g4.outputs.Q[16])
        return new(inputs, parts, outputs)
    end
end

function rewire!(chip::ALU; x = chip.inputs.x, y = chip.inputs.y, zx = chip.inputs.zx, nx = chip.inputs.nx, zy = chip.inputs.zy, ny = chip.inputs.ny, f = chip.inputs.f, no = chip.inputs.no)

    chip.inputs.x = x
    chip.inputs.y = y
    chip.inputs.zx = zx
    chip.inputs.nx = nx
    chip.inputs.zy = zy
    chip.inputs.ny = ny
    chip.inputs.f = f
    chip.inputs.no = no

    x1 = chip.parts[1]
    x2 = chip.parts[2]
    y1 = chip.parts[3]
    y2 = chip.parts[4]

    g3 = chip.parts[7]
    g4 = chip.parts[8]

    rewire!(x1, x = x, zx = zx)
    rewire!(x2, nx = nx)

    rewire!(y1, x = y, zx = zy)
    rewire!(y2, nx = ny)

    rewire!(g3, sel = f)
    rewire!(g4, nx = no)

end

function output(chip::ALU)
    return chip.outputs.out
end



