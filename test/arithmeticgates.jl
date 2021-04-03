using Hack
using Test

@testset "ALU" begin
    test!(ALU())
end



@testset "Negate" begin
    test!(Negate())
end


@testset "Zero" begin
    test!(Zero())
end



@testset "Inc16" begin
    test!(Inc16())
end



@testset "Add16" begin
    test!(Add16())
end



@testset "FullAdder" begin
    test!(FullAdder())
end


@testset "Adder" begin
    test!(Adder())
end


