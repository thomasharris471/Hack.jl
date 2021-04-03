struct Adder <: Chip
    inputs
    parts
    outputs

    function Adder(a = Pin(), b = Pin())
        inputs = (a = a, b = b)
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
        inputs = (a = a, b = b, c = c)
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
        inputs = (a = a, b = b)
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
        inputs = (a = a, )
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
        inputs = (x = x, zx = zx )
        notzx = Not(zx)
        parts = []
        push!(parts, notzx)
        for i in 1:16
            push!(parts, And(x[i], notzx.outputs.Q) )
        end
        outs = [parts[i].outputs.Q for i in 2:17]

        outputs = (Q = outs, )

        return new(inputs, parts, outputs)
    end
end

struct Negate <: Chip
    inputs
    parts
    outputs

    function Negate(x = [Pin() for i in 1:16],  nx = Pin())
        inputs = (x = x, nx = nx )
        inverted = Not16(x)
        negated = Inc16(inverted.outputs.Q)
        muxed = Mux16(x, negated.outputs.Q, nx)
        parts = [inverted, negated, muxed]
        outputs = (Q = muxed.outputs.Q, )

        return new(inputs, parts, outputs)
    end
end


struct ALU <: Chip
    inputs
    parts
    outputs

    function ALU(x = [Pin() for i in 1:16], y = [Pin() for i in 1:16], zx = Pin(), nx = Pin(), zy = Pin(), ny = Pin(), f = Pin(), no = Pin())
        inputs = (x = x, y = y, zx = zx, nx = nx, zy = zy, ny = ny, f = f, no = no )
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




