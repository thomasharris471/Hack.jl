using Hack
using Test
using Base


function add(x::Bool, y::Bool)
    sum = xor(x,y)
    carry = x && y 
    return (sum, carry)
end

function add(x::Bool, y::Bool, c::Bool)
    sum1, carry1 = add(x,y)
    sum2, carry2 = add(sum1, c)
    return (sum2, (carry1 || carry2))
end

function binadd(xs::Vector{Bool}, ys::Vector{Bool})
    zs = []
    carrys = []
    push!(zs, add(xs[1], ys[1])[1])
    push!(carrys, add(xs[1], ys[1])[2])
    for i = 2:Base.length(xs)
        term = add(xs[i], ys[i], carrys[i-1])
        push!(zs, term[1])
        push!(carrys, term[2])
    end
    return zs
end

function binadd(xs, ys)
    xHolder::Vector{Bool} = Bool.(xs) 
    yHolder::Vector{Bool} = Bool.(ys)
    return binadd(xHolder, yHolder)
end

function negate(xs)
    ys = fill(false, Base.length(xs))
    for i in 1:Base.length(xs)
        ys[i]= !Bool(xs[i])
    end
    ys = add1(ys)
    return ys
end


function add1(xs)
    ys = fill(false, Base.length(xs))
    ys[1] = true
    return binadd(xs, ys)
end



function ALUlogic(xs, ys, zx, nx, zy, ny, f, no)
    xHolder = xs
    yHolder = ys
    if zx
        xHolder = fill(0, Base.length(xs))
    end
    if nx
        xHolder = negate(xHolder)
    end

    if zy
        yHolder = fill(0, Base.length(ys))
    end
    if ny
        yHolder = negate(yHolder)
    end

      out = []

    if f
        out = binadd(xHolder, yHolder)
    else
        out = [(Bool(xHolder[i]) && Bool(yHolder[i])) for i in 1:Base.length(xHolder)]
    end

    if no
        out = negate(out)
    end
    ng = out[end]
    
    zr = 1
    for i = 1:Base.length(out)
        if out[i]
            zr = 0
        end
    end
    
    return (out, zr, ng)

end


@testset "ALU" begin
    chip = ALU()
    inputData =  [testData(input) for input in chip.inputs]
    orderedIns = []
    orderedOuts = []
    for testvalues in Iterators.product(inputData...)
        map(set!, chip.inputs, testvalues)
        eval!(chip)
        
        val = []
        for input in chip.inputs
            push!(val, value(input))
        end
        logicout = ALUlogic(val[1], val[2], val[3], val[4], val[5], val[6], val[7], val[8])
        chipout = (value(chip.outputs.out), value(chip.outputs.zr), value(chip.outputs.ng))
        @test logicout[1] == chipout[1]
        @test Bool(logicout[2]) == chipout[2]
        @test Bool(logicout[3]) == chipout[3]
       # println(val)
    end
end


