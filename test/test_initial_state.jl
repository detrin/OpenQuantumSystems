using Test
using OpenQuantumSystems
using Random, SparseArrays, LinearAlgebra
import QuantumOpticsBase

@testset "initial state" begin

    Random.seed!(0)

    D(op1::Array, op2::Array) = abs(norm(op1 - op2))
    D(x1::StateVector, x2::StateVector) = norm(x2 - x1)
    D(op1::AbstractOperator, op2::AbstractOperator) =
        abs(tracedistance_nh(dense(op1), dense(op2)))
    D(op1::AbstractSuperOperator, op2::AbstractSuperOperator) =
        abs(tracedistance_nh(dense(op1), dense(op2)))

    mode1 = Mode(0.2, 1.0)
    Energy = [0.0, 200.0]
    mol1 = Molecule([mode1], 2, Energy)
    mol2 = Molecule([mode1], 2, Energy)
    agg = Aggregate([mol1, mol2])
    aggInds = getIndices(agg; groundState = false)
    vibindices = getVibIndices(agg, aggInds)
    aggIndsLen = length(aggInds)
    basis = GenericBasis([aggIndsLen])
    FCFact = getFranckCondonFactors(agg, aggInds; groundState = false)
    Ham = getAggHamiltonian(agg, aggInds, FCFact; groundState = false)

    T = 300.
    mu_array = [[1, 2]]
    W0_ref = [
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.25023985364402346 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.24999994249781032 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.24999994249781032 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.24976026136035576
    ]
    W0 = thermal_state(T, mu_array, Ham, aggInds)
    @test 1e-15 > D(W0_ref, W0.data)
    # println(W0.data)

    T = 1e-10
    W0_ref = [
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    ]
    W0 = thermal_state(T, mu_array, Ham, aggInds)
    @test 1e-15 > D(W0_ref, W0.data)
    # println(W0.data)

    T = 300.
    mu_array = [[1, 2], [2, 1]]
    W0_ref = [
        0.12511992682201173 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.12499997124890516 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.12499997124890516 0.0 0.0 0.0 0.0 0.0;
        0.0 0.0 0.0 0.12488013068017788 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.12511992682201173 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.12499997124890516 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.12499997124890516 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.12488013068017788
    ]
    W0 = thermal_state(T, mu_array, Ham, aggInds)
    @test 1e-15 > D(W0_ref, W0.data)
    # println(W0.data)
    
    aggInds = getIndices(agg; groundState = true)
    FCFact = getFranckCondonFactors(agg, aggInds; groundState = true)
    Ham = getAggHamiltonian(agg, aggInds, FCFact; groundState = true)
    T = 300.
    mu_array = [[1, 1]]
    W0_ref = [
        0.25023985364402346 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.24999994249781035 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.24999994249781035 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.24976026136035578 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 
        0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
    ]
    W0 = thermal_state(T, mu_array, Ham, aggInds)
    @test 1e-15 > D(W0_ref, W0.data)
    # println(W0.data)


end # testset