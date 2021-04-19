struct CPU <: Chip
    inputs
    parts
    outputs
   
    function CPU(inM = [Pin() for i in 1:16],  instruction = [Pin() for i in 1:16], reset = Pin(), clock = Pin())

        inputs = MutableNamedTuple(inM = inM, instruction = instruction, reset = reset,  clock = clock)


        #pin code names
        i = instruction[1]
        a = instruction[4]
        cs = instruction[5:10]
        ds = instruction[11:13]
        js = instruction[14:16]

        incPin = Pin()
        set!(incPin, true)


        alu = ALU()
#pin names 
        zr = alu.outputs.zr 
        ng = alu.outputs.ng

        #logic gates
        controlForARegister = Or(ds[1], i)
        positive = Nor(zr, ng)
        j3Jump = And(js[3], output(positive))
        j2Jump = And(js[2], zr)
        j1Jump = And(js[1], ng)
        orJ3J2 = Or(output(j3Jump), output(j2Jump))
        jumpLogic = Or(output(j1Jump), output(orJ3J2))


        leftMux = Mux16(instruction, alu.outputs.out, i)
        addressRegister = Register(output(leftMux), output(controlForARegister), clock)
        middleMux = Mux16(output(addressRegister), inM, a)
        dataRegister = Register(output(alu), ds[2], clock)
        programCounter = PC(output(addressRegister), incPin, output(jumpLogic), reset, clock)
        rewire!(alu, x = output(dataRegister), y = output(middleMux), zx = cs[1], nx = cs[2], zy = cs[3], ny = cs[4], f = cs[5], no = cs[6])
 

        parts = [alu, controlForARegister, positive, j3Jump, j2Jump, j1Jump, orJ3J2, jumpLogic, leftMux, addressRegister, middleMux, dataRegister, programCounter]

        outputs = (outM = alu.outputs.out, writeM = ds[3], addressM = inM, PC = output(programCounter))
       # raceClear!(parts)
        return new(inputs, parts, outputs)
    end




end

struct Memory <: Chip
    inputs
    parts
    outputs
   
    function Memory(data = [Pin() for i in 1:16], address = [Pin() for i in 1:15], load = Pin(), clock = Pin())

        inputs = MutableNamedTuple(data = data, address = address, load = load, clock = clock)

        dmux = DMux(load, address[1])

        registers = [RAM16K(data, address[2:15], dmux.outputs[j], clock) for j in 1:2]
        mux = Mux16(output.(registers)..., address[1])
        
        parts::Vector{Chip} = [mux, dmux]
        append!(parts, registers)

        outputs = (Q = output(mux), )
       # raceClear!(parts)
        return new(inputs, parts, outputs)
    end


end



struct ROM32K
    inputs
    parts
    outputs

    function ROM32K(address = [Pin() for i in 1:15])
        inputs = MutableNamedTuples(address = address)
        r1 = RAM16K([Pin() for i in 1:16], address[2:15], Pin(), Pin())
        r2 = RAM16K([Pin() for i in 1:16], address[2:15], Pin(), Pin())
        mux = Mux16(output(r1), output(r2), address[1])
        parts = [r1, r2, mux]
        outputs = (Q = output(mux))
        return new(inputs, parts, outputs)
    end
end

function loadedRom(textFile)
    return ROM32K()
end


struct ROM32K
    inputs
    parts
    outputs

    function ROM32K(address = [Pin() for i in 1:15])
        inputs = MutableNamedTuples(address = address)
        r1 = RAM16K([Pin() for i in 1:16], address[2:15], Pin(), Pin())
        r2 = RAM16K([Pin() for i in 1:16], address[2:15], Pin(), Pin())
        mux = Mux16(output(r1), output(r2), address[1])
        parts = [r1, r2, mux]
        outputs = (Q = output(mux))
        return new(inputs, parts, outputs)
    end
end

function loadedRom(textFile)
    return ROM32K()
end



















