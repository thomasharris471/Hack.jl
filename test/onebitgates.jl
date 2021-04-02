using Hack
using Test

@testset "Nand" begin
    # Write your tests here.
    test!(Nand())
end

@testset "Not" begin
    test!(Not())
end

@testset "And" begin
    test!(And())
end

@testset "Or" begin
    test!(Or())
end

@testset "Xor" begin
    test!(Xor())
end

@testset "Mux" begin
    test!(Mux())
end

@testset "DMux" begin
    test!(DMux())
end
