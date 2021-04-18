struct SRNand <: Chip
    inputs
    parts
    outputs
   
    function SRNand(S = Pin(), R = Pin())
        inputs = MutableNamedTuple(S = S, R = R)

        top = Nand()
        bottom = Nand()
        rewire!(top, A = R)
        rewire!(top, B = bottom.outputs.Q)

        rewire!(bottom, A = top.outputs.Q)
        rewire!(bottom, B =  S)

        parts = [top, bottom]
        outputs = (Q = top.outputs.Q, )
        return new(inputs, parts, outputs)
    end
end

 struct SRAO <: Chip
    inputs
    parts
    outputs
   
    function SRAO(S = Pin(), R = Pin())
        inputs = MutableNamedTuple(S = S, R = R)

        left = Or()
        middle = Not()
        right = And()
        
        rewire!(left, A = output(right), B = S)
        rewire!(middle, A = R)
        rewire!(right, A = output(left), B = output(middle))

        parts = [left, middle, right]
        outputs = (Q = right.outputs.Q, )

        raceClear!(parts)
        return new(inputs, parts, outputs)
    end
end

  

struct SR <: Chip
    inputs
    parts
    outputs
   
    function SR(S = Pin(), R = Pin())
        inputs = MutableNamedTuple(S = S, R = R)

        top = Nor()
        bottom = Nor()
        
        rewire!(top, A = R)
        rewire!(top, B = bottom.outputs.Q)

        rewire!(bottom, A = top.outputs.Q)
        rewire!(bottom, B = S)

        parts = [top, bottom]
        outputs = (Q = top.outputs.Q, )

        raceClear!(parts)
        return new(inputs, parts, outputs)
    end
end

struct DFF <: Chip
    inputs
    parts
    outputs

    function DFF(data = Pin(), clock = Pin())
        inputs = MutableNamedTuple(data = data, clock = clock)

        top = Nand()
        topMid = Nand()
        bottomMid = Nand3Way()
        bottom = Nand()

        forwardTop = Nand()
        forwardBottom = Nand()

        rewire!(top, A = bottom.outputs.Q, B = topMid.outputs.Q)

        rewire!(topMid, A = top.outputs.Q, B = clock)
    
        rewire!(bottomMid, A = topMid.outputs.Q, B = clock, C = bottom.outputs.Q)

        rewire!(bottom, A = bottomMid.outputs.Q, B = data)

        rewire!(forwardTop, A= topMid.outputs.Q, B = forwardBottom.outputs.Q)

        rewire!(forwardBottom, A = forwardTop.outputs.Q, B = bottomMid.outputs.Q)

                
        parts = [top, topMid, bottomMid, bottom, forwardTop, forwardBottom] 
        outputs = (Q = forwardTop.outputs.Q,)

        raceClear!(parts)
        return new(inputs, parts, outputs)
    end
end

function rewire!(chip::DFF; data = chip.inputs.data, clock = clock.inputs.clock)
    chip.inputs.data = data
    chip.inputs.clock = clock
    topMid = chip.parts[2]
    bottomMid = chip.parts[3]
    bottom = chip.parts[4]
    rewire!(topMid, B = clock)
    rewire!(bottomMid, B = clock)
    rewire!(bottom, B = data)
end


struct DFF2 <: Chip
    inputs
    parts
    outputs

    function DFF2(data = Pin(), clock = Pin())
        inputs = MutableNamedTuple(data = data, clock = clock)

        oneBottom = Not()

        twoTop = Nand()
        twoMid = Nand()
        twoBottom = Not()

        threeTop = Nand()
        threeMid = Nand()

        fourTop = Nand()
        fourBottom = Nand()

        fiveTop = Nand()
        fiveBottom = Nand()

        oneBottom.inputs.A= clock

        twoTop.inputs.A = data
        twoTop.inputs.B= oneBottom.outputs.Q

        twoMid.inputs.A = twoTop.outputs.Q
        twoMid.inputs.B =  oneBottom.outputs.Q
        
        twoBottom.inputs.A =  oneBottom.outputs.Q

        threeTop.inputs.A =   twoTop.outputs.Q
        threeTop.inputs.B =  threeMid.outputs.Q

        threeMid.inputs.A =  threeTop.outputs.Q
        threeMid.inputs.B =  twoMid.outputs.Q

        fourTop.inputs.A =  threeTop.outputs.Q
        fourTop.inputs.B =  twoBottom.outputs.Q

        fourBottom.inputs.A =  fourTop.outputs.Q
        fourBottom.inputs.B =  twoBottom.outputs.Q

        fiveTop.inputs.A =  fourTop.outputs.Q
        fiveTop.inputs.B =  fiveBottom.outputs.Q

        fiveBottom.inputs.A =  fiveTop.outputs.Q
        fiveBottom.inputs.B = fourBottom.outputs.Q

        
        parts = [oneBottom, twoTop, twoMid, twoBottom, threeTop, threeMid, fourTop, fourBottom, fiveTop, fiveBottom] 
        outputs = (Q = fiveTop.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end

struct Bit <: Chip
    inputs
    parts
    outputs
   
    function Bit(data = Pin(), load = Pin(), clock = Pin())
        inputs = MutableNamedTuple(data = data, load = load, clock = clock)

        dffload = DFF(load, clock)
        dffdata = DFF(data, clock)
        dffcurrent = DFF()
        g1 = Not(output(dffload))
        mux = Mux(output(dffdata), output(dffcurrent), output(g1))
       
        rewire!(dffcurrent, data = output(mux), clock = clock)
        parts = [dffload, dffdata, dffcurrent, mux, g1]
        outputs = (Q = mux.outputs.Q, )
        raceClear!(parts)
        return new(inputs, parts, outputs)
    end


end



