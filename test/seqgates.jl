using Hack
using Test

@testset "Bit" begin
    clock = Clock()
    bit = Bit(Pin(), Pin(), output(clock))
    testBit!(bit, clock)
end


#=
@testset "SRNand" begin
    sr = SRNand()
    testseq!(sr)
end
=#

#=
@testset "SR" begin
    sr = SR()
    testseq!(sr)
end
=#
#=
@testset "SRAO" begin
    testseq!(SRAO())
end
=#

#=

@testset "DFF2" begin
    dff = DFF2()
    testseq!(dff)
end
=#

#=

@testset "DFF" begin
    dff = DFF()
    testseq!(dff)
end
=#


#
