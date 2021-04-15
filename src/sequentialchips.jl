
struct DFF2 <: Chip
    inputs
    parts
    outputs

    function DFF2(data = Pin(), clock = Pin())
        inputs = MutableNamedTuple(data = data, clock = clock)

        top = Nand()
        topMid = Nand()
        bottomMid = Nand3Way()
        bottom = Nand()

        forwardTop = Nand()
        forwardBottom = Nand()

        top.inputs.A = bottom.outputs.Q
        top.inputs.B = topMid.outputs.Q

        topMid.inputs.A = top.outputs.Q
        topMid.inputs.B = clock

        bottomMid.inputs.A = topMid.outputs.Q
        bottomMid.inputs.B = clock
        bottomMid.inputs.C = bottom.outputs.Q

        bottom.inputs.A = bottomMid.outputs.Q
        bottom.inputs.B = data

        forwardTop.inputs.A = topMid.outputs.Q
        forwardTop.inputs.B = forwardBottom.outputs.Q

        forwardBottom.inputs.A = forwardTop.outputs.Q
        forwardBottom.inputs.B = bottomMid.outputs.Q
                
        parts = [top, topMid, bottomMid, bottom, forwardTop, forwardBottom] 
        outputs = (Q = forwardTop.outputs.Q,)
        return new(inputs, parts, outputs)
    end
end


struct DFF <: Chip
    inputs
    parts
    outputs

    function DFF(data = Pin(), clock = Pin())
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


