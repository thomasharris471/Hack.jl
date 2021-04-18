mutable struct Pin
    value
    function Pin()
        return new(false)
    end
end

function increment!(pin::Pin)
    pin.value = !pin.value
end


function value(pin::Pin)
    return pin.value
end

function value(pins::Vector{Pin})
    return value.(pins)
end

function set!(pin::Pin, value::Bool)
    pin.value = value
    return nothing
end

function set!(pin::Pin, value::Integer)
    set!(pin, Bool(value))
    return nothing
end

function set!(pins::Vector{Pin}, value::Vector{Bool})
    for (i, pin) in enumerate(pins)
        set!(pin, value[i])
    end
    return nothing
end

function set!(pins::Vector{Pin}, value::Integer)
    set!(pins, intToBinary(value, Base.length(pins)))
    return nothing
end

function testData(pin::Pin)
    return 0:1
end

function testData(pins::Vector{Pin})
    return 0:2^(Base.length(pins))-1
end


