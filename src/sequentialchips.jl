struct DFF <: Chip
    inputs
    parts
    outputs

    function Adder(in = Pin(), out = Pin())
        inputs = (a = a, b = b)
        sumChip = Xor(a, b)
        carryChip = And(a, b)
        parts = [sumChip, carryChip] 
        outputs = (sum = sumChip.outputs.Q, carry = carryChip.outputs.Q)
        return new(inputs, parts, outputs)
    end
end


