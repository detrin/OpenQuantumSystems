using Test
using OpenQuantumSystems

@testset "schroedinger" begin

    N = 3
    Ncutoff = 2
    tspan = [0.:0.1:1.;]

    Ω = [0 2 3;
        2 0 1;
        3 1 0]

    ω = [1., 1.2, 1.5]

    basis_fock = FockBasis(Ncutoff)
    basis = tensor([basis_fock for i=1:N]...)

    a = destroy(basis_fock)
    at = create(basis_fock)
    I = identityoperator(basis_fock)


    psi0 = tensor([coherentstate(basis_fock, i%Ncutoff) for i=1:N]...)


    # Interaction picture
    Hrot = SparseOpType[]
    for i=1:N, j=1:N
        if i==j
            continue
        end
        h = embed(basis, [i,j], [a, Ω[i,j]*at])
        push!(Hrot, h)
    end
    Hrot = sum(Hrot)

    # Schroedinger picture
    function f(t, psi)
        H = SparseOpType[embed(basis, i, ω[i]*at*a) for i=1:N]
        for i=1:N, j=1:N
            if i==j
                continue
            end
            h = embed(basis, [i,j], [a, exp(1im*(ω[i]-ω[j])*t)*Ω[i,j]*at])
            push!(H, h)
        end
        sum(H)
    end

    tout, psi_rot_t = schroedinger(psi0, Hrot, tspan)
    tout, psi_t = schroedinger_dynamic(psi0, f, tspan)

    n_op = dense(at*a)
    for (i, t) in enumerate(tout)
        R = prod([embed(basis, i, exp(1im*ω[i]*t*n_op)) for i=1:N])
        psi_rot = psi_rot_t[i]
        psi = psi_t[i]
        # @test abs(dagger(psi_rot)*R*psi) < 1e-5
        rho = dm(psi)
        rho_rot = dm(psi_rot)
        @test tracedistance(rho_rot, dense(R)*rho*dagger(dense(R))) < 1e-5
    end

    function fout(t, psi)
    deepcopy(psi)
    end
    t_fout, psi_fout = schroedinger(psi0, Hrot, tspan; fout=fout)
    @test t_fout == tout && psi_fout == psi_rot_t

    # test integration of propagator using 2 level system
    basis = SpinBasis(1//2)
    su = spinup(basis)
    u0 = identityoperator(basis)
    sx = sigmax(basis)
    sz = sigmaz(basis)

    # for the time dependent equation
    f(t, psi) = sx * π
    tspan = [0:1.0;]
    t, u = schroedinger(u0, π * sx, tspan)

    # I think the tolerance on the differential equation is 1e-6, we expect the operator to be essentially the identity
    @test abs(expect(sz, u[end] * su)) - abs(expect(sz, u0 * su)) < 1e-6

    t, u = schroedinger_dynamic(u0, f, tspan)
    @test abs(expect(sz, u[end] * su)) - abs(expect(sz, u0 * su)) < 1e-6



end # testset