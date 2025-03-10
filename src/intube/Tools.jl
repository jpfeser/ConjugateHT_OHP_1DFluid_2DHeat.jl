using CartesianGrids

export getgvec,getheightg,delta, # get actrual heightg of the tube
XMtovec,XMδtovec,vectoXM,vectoXMδ,XMδLtovec,vectoXMδL, # transfer Xp,dXdt,M,δ to the state vector
XptoLvaporplug,XptoLliquidslug,getXpvapor, # transfer Xp to the length of vapors, length of liquids, and Xp for vapor.
ifamongone,ifamong,constructXarrays,
duliquidθtovec,duwallθtovec,liquidθtovec,wallθtovec, # transfer temperature field to state vector for liquid and wall.
Hfilm,getδarea,getδFromδarea,getMvapor,getMfilm,getMliquid,getVolumevapor,
getCa,filmδcorr,getAdeposit,f_churchill,Catoδ,RntoΔT


# """
#     This function is a sub-function of getheight. This function is to get the actural physical heightg for one interface
#         X     ::   the location of one interface
#         L2D   ::   the length of one bend to another bend (the length in 2D)
#         angle ::   the inclination angle
# """

# function getoneheight(X::Float64,L2D::Float64,angle::Float64)

#     oneheight = Integer(mod(div(X,L2D),2.0)) == 0 ? L2D - mod(X,L2D) : mod(X,L2D)

#     return oneheight*sin(angle)
# end

# """
#     This function is to get the actural physical heights for all interfaces
#         Xp    ::   the locations of all interfaces
#         L2D   ::   the length of one bend to another bend (the length in 2D)
#         angle ::   the inclination angle
# """

# function getheight(Xp::Array{Tuple{Float64,Float64},1},L2D::Float64,angle::Float64)

#     heightg=deepcopy(Xp)

#     for i =1:length(Xp)
#         heightg[i]=(getoneheight(Xp[i][1],L2D,angle), getoneheight(Xp[i][end],L2D,angle))
#     end

#     return heightg
# end
function getgvec(g0::T,g_angle::T=3/2*π) where {T<:Real}
    g = g0*[cos(g_angle),sin(g_angle)]
end

function getheightg(g::Vector{T},x::Vector{T},y::Vector{T}) where {T<:Real}
    xy = [x';y']
    vec(sum(-g .* xy,dims=1));
end

delta(n) = n != 0

"""
    This function is to transform Xp, dXdt of the interface, and M of the vapor to form our state vector u
        Xp    ::   the locations of all interfaces
        dXdt  ::   the 1D velocity of all interfaces
        M     ::   the mass of all vapors
"""

function XMtovec(Xp::Array{Tuple{Float64,Float64},1},dXdt::Array{Tuple{Float64,Float64},1},M::Array{Float64,1})
    if (length(Xp) == length(dXdt)) && (length(Xp) + 1 == length(M))

        u=zeros(5*length(Xp)+1)

        for i = 1:length(Xp)

            # input Xp
            u[2*i-1] = Xp[i][1]
            u[2*i] = Xp[i][end]

            # input dXdt
            u[2*length(Xp) + 2*i-1] = dXdt[i][1]
            u[2*length(Xp) + 2*i] = dXdt[i][end]
        end

        for i = 1:length(M)
            # input M
            u[4*length(Xp) + i] = M[i]
        end

        return u
    end

    if (length(Xp) == length(dXdt)) && (length(Xp) == length(M))

        u=zeros(5*length(Xp))

        for i = 1:length(Xp)

            # input Xp
            u[2*i-1] = Xp[i][1]
            u[2*i] = Xp[i][end]

            # input dXdt
            u[2*length(Xp) + 2*i-1] = dXdt[i][1]
            u[2*length(Xp) + 2*i] = dXdt[i][end]
        end

        for i = 1:length(M)
            # input M
            u[4*length(Xp) + i] = M[i]
        end

        return u
    end
            println("the lengthes of X and dXdt and M do not match!")
            return "error"

end

"""
    This function is to transform Xp, dXdt of the interface, and M of the vapor to form our state vector u
        Xp    ::   the locations of all interfaces
        dXdt  ::   the 1D velocity of all interfaces
        M     ::   the mass of all vapors
        δ     ::   the thickness of film in all vapors
"""

function XMδtovec(Xp,dXdt,M,δ)

    return ([XMtovec(Xp,dXdt,M);δ])
end

"""
    This function is to transform Xp, dXdt of the interface, and M of the vapor to form our state vector u
        Xp    ::   the locations of all interfaces
        dXdt  ::   the 1D velocity of all interfaces
        M     ::   the mass of all vapors
        δstart::Array{Float64,1}
        δend::Array{Float64,1}
        Lfilm_start::Array{Float64,1}
        Lfilm_end::Array{Float64,1}
        Eratio::Array{Float64,1}
"""

function XMδLtovec(Xp,dXdt,M,δstart,δend,Lfilm_start,Lfilm_end)

    return ([XMtovec(Xp,dXdt,M);δstart;δend;Lfilm_start;Lfilm_end])
end

"""
    This function is to transform Xp, dXdt of the interface, and M of the vapor to form our state vector u
        u    ::   the dynamic portion of state vector
"""

function vectoXM(u::Array{Float64,1})

    if mod(length(u),5) == 1
        maxindex = Integer( (length(u) - 1)/5 )

        Xp = map(tuple, zeros(maxindex), zeros(maxindex))
        dXdt = map(tuple, zeros(maxindex), zeros(maxindex))
        M = zeros(maxindex+1)

        for i = 1:maxindex

            # input Xp
            Xp[i] = (u[2*i-1],u[2*i])

            # input dXdt
            dXdt[i] = (u[2*maxindex + 2*i-1],u[2*maxindex + 2*i])
        end

        for i = 1:(maxindex+1)

            # input M
            M[i] = u[4*maxindex + i]

        end

        return Xp,dXdt,M
    end

    if mod(length(u),5) == 0
        maxindex = div(length(u),5)

        Xp = map(tuple, zeros(maxindex), zeros(maxindex))
        dXdt = map(tuple, zeros(maxindex), zeros(maxindex))
        M = zeros(maxindex)

        for i = 1:maxindex

            # input Xp
            Xp[i] = (u[2*i-1],u[2*i])

            # input dXdt
            dXdt[i] = (u[2*maxindex + 2*i-1],u[2*maxindex + 2*i])
        end

        for i = 1:maxindex

            # input M
            M[i] = u[4*maxindex + i]

        end

        return Xp,dXdt,M
    end

return "error"

end

"""
    This function is to transform Xp, dXdt of the interface, and M of the vapor to form our state vector u
        u    ::   the dynamic portion of state vector
"""

function vectoXMδ(u::Array{Float64,1})
if mod(length(u),6) == 2
    maxindex = Integer( (length(u) - 2)/6 )

    Xp = map(tuple, zeros(maxindex), zeros(maxindex))
    dXdt = map(tuple, zeros(maxindex), zeros(maxindex))
    M = zeros(maxindex+1)
    δ = zeros(maxindex+1)

    for i = 1:maxindex

        # input Xp
        Xp[i] = (u[2*i-1],u[2*i])

        # input dXdt
        dXdt[i] = (u[2*maxindex + 2*i-1],u[2*maxindex + 2*i])
    end

    for i = 1:(maxindex+1)

        # input M
        M[i] = u[4*maxindex + i]
        δ[i] = u[5*maxindex + 1 + i]
    end

    return Xp,dXdt,M,δ
end

if mod(length(u),6) == 0
    maxindex = div(length(u),6)

    Xp = map(tuple, zeros(maxindex), zeros(maxindex))
    dXdt = map(tuple, zeros(maxindex), zeros(maxindex))
    M = zeros(maxindex)
    δ = zeros(maxindex)

    for i = 1:maxindex

        # input Xp
        Xp[i] = (u[2*i-1],u[2*i])

        # input dXdt
        dXdt[i] = (u[2*maxindex + 2*i-1],u[2*maxindex + 2*i])
    end

    for i = 1:maxindex

        # input M
        M[i] = u[4*maxindex + i]
        δ[i] = u[5*maxindex + i]
    end

    return Xp,dXdt,M,δ
end

return "error"

end

"""
    This function is to transform Xp, dXdt of the interface, and M of the vapor to form our state vector u
        u    ::   the dynamic portion of state vector
"""

function vectoXMδL(u::Array{Float64,1})
if mod(length(u),9) == 2
    return "haven't finish new open end code"
end

if mod(length(u),9) == 0
    maxindex = div(length(u),9)

    Xp = map(tuple, zeros(maxindex), zeros(maxindex))
    dXdt = map(tuple, zeros(maxindex), zeros(maxindex))
    M = zeros(maxindex)
    δstart = zeros(maxindex)
    δend = zeros(maxindex)
    Lfilm_start = zeros(maxindex)
    Lfilm_end = zeros(maxindex)

    for i = 1:maxindex

        # input Xp
        Xp[i] = (u[2*i-1],u[2*i])

        # input dXdt
        dXdt[i] = (u[2*maxindex + 2*i-1],u[2*maxindex + 2*i])
    end

    for i = 1:maxindex

        # input M
        M[i] = u[4*maxindex + i]
        δstart[i] = u[5*maxindex + i]
        δend[i] =  u[6*maxindex + i]
        Lfilm_start[i] = u[7*maxindex + i]
        Lfilm_end[i] = u[8*maxindex + i]
    end

    return Xp,dXdt,M,δstart,δend,Lfilm_start,Lfilm_end
end

return "new function error"

end

"""
    This function is to transform Xp of every interface, and L of the tube to form an array of vapor length
        Xp    ::   the locations of all interfaces
        L     ::   the length of the 1D tube
"""

function XptoLvaporplug(Xp::Vector{Tuple{Float64, Float64}},L::Float64,closedornot::Bool)

if closedornot == false
    maxindex = length(Xp) + 1
    Lvaporplug = zeros(maxindex)

    Lvaporplug[1] = Xp[1][1]-0.0
    Lvaporplug[end] = L-Xp[end][end]

    if maxindex > 2
        for i = 2:maxindex-1

            Lvaporplug[i] = Xp[i][1] - Xp[i-1][end]

        end
    end

    return Lvaporplug
end

if closedornot == true
    maxindex = length(Xp)
    Lvaporplug = zeros(maxindex)

    Lvaporplug[1] = mod((Xp[1][1]-Xp[end][end]),L)
    # Lvaporplug[end] = L-Xp[end][end]

    if maxindex > 1
        for i = 2:maxindex

            Lvaporplug[i] = mod((Xp[i][1] - Xp[i-1][end]),L)

        end
    end

    return Lvaporplug
end

end

"""
    This function is to transform Xp of every interface to form an array of liquid length
        Xp    ::   the locations of all interfaces
"""

function XptoLliquidslug(Xp::Vector{Tuple{Float64, Float64}},L::Float64)

    Lliquidslug = zeros(length(Xp))


        for i = 1: length(Xp)

        Lliquidslug[i] = mod((Xp[i][end] - Xp[i][1]),L)

        end

    return Lliquidslug

end

"""
    The Xp was coupled by every liquid slug. For instance, if there is one liquid slug. Xp is a one-element tuple (Xp[1][1], Xp[1][2]).
    But sometimes we need Xp to be coupled by every vapor plug. For one liquid slug, we have two vapor plugs.
    So by adding 0 and L at the beginning and the end,
    we construct a two-element tuple ((0.0,Xp[1][1]) and ((Xp[1][2],L). Generally, for every N-element Xp, we construct an N+1 element Xpvapor
        Xp    ::   the locations of all interfaces, each element means a liquid slug.
        L     ::   the length of the 1D tube
"""

function getXpvapor(Xp,L,closedornot)

    Xpvapor=deepcopy(Xp)

    if closedornot == false
        Xpvapor[1]=(0.0,Xp[1][1])

        for i = 2:(length(Xp))
            Xpvapor[i]=(Xp[i-1][end],Xp[i][1])
        end

        push!(Xpvapor,(Xp[end][end],L))
    end

    if closedornot == true

        Xpvapor[1]=(Xp[end][end],Xp[1][1])

        for i = 2:(length(Xp))
            Xpvapor[i]=(Xp[i-1][end],Xp[i][1])
        end
    end

    return Xpvapor
end

# function getdXdtvapor(Xp,L,closedornot)
#
#     Xpvapor=deepcopy(Xp)
#
#     if closedornot == false
#         Xpvapor[1]=(0.0,Xp[1][1])
#
#         for i = 2:(length(Xp))
#             Xpvapor[i]=(Xp[i-1][end],Xp[i][1])
#         end
#
#         push!(Xpvapor,(Xp[end][end],L))
#     end
#
#     if closedornot == true
#         Xpvapor[1]=(Xp[end][end],Xp[1][1])
#
#         for i = 2:(length(Xp))
#             Xpvapor[i]=(Xp[i-1][end],Xp[i][1])
#         end
#     end
#
#     return dXdt
# end

#
# """
#     This is a general sub-function of ifamong to determine if the value is in the range
#
#     value ::  a value
#     range ::  a tuple
# """
#
# function ifamongone(value::Float64, range::Tuple{Float64,Float64})
#     return (value >= range[1]) && (value <= range[end]) ? true : false
# end

"""
    This is a function for a closedloop to determine if the value in in the range that crosses the end point

    value ::  a value
    range ::  an array
"""

function ifamongone(value::Float64, range::Tuple{Float64,Float64}, L::Float64)
    return ((value >= range[1]) && (value <= range[end])) || ((value <= range[end]) && (range[1] >= range[end])) || ((value >= range[1]) && (range[1] >= range[end])) ? true : false
end

# """
#     This is a function to see if the value in in the range
#
#     value ::  a value
#     range ::  an array
# """
#
# function ifamongone(value::Float64, range::Array{Float64,1})
#     return (value >= range[1]) && (value <= range[end]) ? true : false
# end
#

"""
    This is a general function to determine if the value is in any of an array of range

    value ::  a value
    range ::  an array of tuple
"""

function ifamong(value, X, L)

    return Bool(sum(ifamongone.(value,X,L)) >= 1 ? true : false)
end

"""
    initialize X and θ field for every liquid slugs. return Array{Array{Float64, 1}, 1} and Array{Array{Float64, 1}, 1}

    X0       :: Array{Tuple{Float64,Float64},1}
    N        :: Int, the number of cells in the wall (ΔX for liquid equals ΔX for the wall)
    θinitial :: value
    L        :: tube length
"""

function constructXarrays(X0::Vector{Tuple{Float64, Float64}},N,θinitial,L)
    Xarrays=Array{Array{Float64, 1}, 1}(undef, length(X0))

    Lliquid = XptoLliquidslug(X0,L)

    Nliquid =  ceil.(Int, N.*Lliquid./L)

    for i = 1:length(Xarrays)
        if X0[i][1] < X0[i][2]
            Xarrays[i] = range(X0[i][1], X0[i][2], length=Nliquid[i])
        else
            Xarrays[i] = range(X0[i][1], X0[i][2]+L, length=Nliquid[i]) .- L
            Xarrays[i] = mod.(Xarrays[i], L)
        end
    end

    θarrays = deepcopy(Xarrays)
    for i = 1:length(θarrays)
        θarrays[i][:] .= θinitial
    end

    return(Xarrays,θarrays)
end

function constructoneXarray(X0::Tuple{Float64,Float64},Nliquid,L)
    Xarray=Array{Float64, 1}

    # Lliquid = XptoLliquidslug([X0],L)

    # Nliquid =  floor.(Int, N.*Lliquid./L)

    # for i = 1:length(Xarray)
        if X0[1] < X0[2]
            Xarray = Array(range(X0[1], X0[2], length=Nliquid))
        else
            Xarray = Array(mod.(range(X0[1], X0[2]+L, length=Nliquid),L))
            # Xarray = mod.(Xarray, L)
        end

        Xarray[1] = X0[1]
        Xarray[end] = X0[2]

    return Xarray
end


"""
    initialize X and θ field for wall, return Array{Float64, 1} and Array{Float64, 1}

    X0       :: Array{Tuple{Float64,Float64},1}
    N        :: Int, the number of cells in the wall (ΔX for liquid equals ΔX for the wall)
    θinitial :: value
    L        :: tube length
"""

function constructXarrays(L::Float64,N,θinitial)
    Xwallarray = Array{Float64, 1}(undef, N)
    Xwallarray = range(0, L, length=N)

    θwallarray = deepcopy(Xwallarray)
    θwallarray = range(θinitial, θinitial, length=N)

    return(Xwallarray,θwallarray)
end

function constructXarrays(line::ScalarData{N,Float64,Array{Float64,1}},L,θinitial) where {N}
    Xwallarray = Array{Float64, 1}(undef, N)
    Xwallarray .= line

    θwallarray = deepcopy(Xwallarray)
    θwallarray = Xwallarray .* 0 .+ θinitial

    return(Xwallarray,θwallarray)
end



"""
    A bunch of functions to transfer θ to state vector rate du
"""

function duliquidθtovec(duθarrays)
    return vcat(map(duwallθtovec, duθarrays)...)
end

function duwallθtovec(duθwall)
    return [0.0; duθwall]
end

"""
    A bunch of functions to transfer θ to state vector u
"""

function liquidθtovec(θarrays)
    return vcat(map(wallθtovec, θarrays)...)
end

function wallθtovec(θwall)
    return [-1e10; θwall]
end

function Hfilm(δfilm,sys)
    δmin = sys.vapor.δmin;
    δthreshold = 5e-6
    δmax = 1e-4
    kₗ   = sys.vapor.k
    Hᵥ  = sys.vapor.Hᵥ

    if (δfilm > δthreshold) && (δfilm < δmax)
        return kₗ/δfilm
    elseif (δfilm > δmax) && (δfilm < 2δmax)
        return  kₗ/δmax - (δfilm-δmax)*(kₗ/δmax^2) + 1e-6
    elseif δfilm > δmin
        return  Hᵥ + (δfilm-δmin)*(kₗ/δthreshold - Hᵥ)/(δthreshold-δmin) + 1e-6
    else
        # return Hᵥ  + 1e-6
        return 0.0
    end
end

function getδarea(Ac,d,δ)
    δarea = Ac .* (1 .- ((d .- 2*δ ) ./ d) .^ 2);

    δarea
end

function getδFromδarea(Ac,d,δarea)
    δ = sqrt(δarea/Ac) * d/2

    δ
end


function getMvapor(sys)

    @unpack PtoD = sys.tube
    ρᵥ = PtoD.(sys.vapor.P)
    Ac = sys.tube.Ac
    δstart = sys.vapor.δstart
    δend = sys.vapor.δend
    Lfilm_start = sys.vapor.Lfilm_start
    Lfilm_end = sys.vapor.Lfilm_end

    Xp = sys.liquid.Xp
    L = sys.tube.L
    d = sys.tube.d
    closedornot = sys.tube.closedornot

    Lvaporplug = XptoLvaporplug(Xp,L,closedornot)
    Astart = getδarea(Ac,d,δstart)
    Aend = getδarea(Ac,d,δend)
    

    Mvapor = ρᵥ .* ((Ac .- Astart) .* Lfilm_start + (Ac .- Aend) .* Lfilm_end + Ac .* (Lvaporplug - Lfilm_start - Lfilm_end))

    Mvapor
end

function getVolumevapor(Ac,Astart,Aend,Lvaporplug,Lfilm_start,Lfilm_end)
    Volumevapor = Ac .* Lvaporplug - Astart .* Lfilm_start - Aend .* Lfilm_end

    Volumevapor
end

function getVolumevapor(sys)

    Ac = sys.tube.Ac
    δstart = sys.vapor.δstart
    δend = sys.vapor.δend
    Lfilm_start = sys.vapor.Lfilm_start
    Lfilm_end = sys.vapor.Lfilm_end

    Xp = sys.liquid.Xp
    L = sys.tube.L
    d = sys.tube.d
    closedornot = sys.tube.closedornot

    Lvaporplug = XptoLvaporplug(Xp,L,closedornot)
    Astart = getδarea(Ac,d,δstart)
    Aend = getδarea(Ac,d,δend)
    

    Volumevapor = Ac .* Lvaporplug - Astart .* Lfilm_start - Aend .* Lfilm_end

    Volumevapor
end

function getMfilm(sys)

    Ac = sys.tube.Ac
    δstart = sys.vapor.δstart
    δend = sys.vapor.δend
    Lfilm_start = sys.vapor.Lfilm_start
    Lfilm_end = sys.vapor.Lfilm_end


    ρₗ = sys.liquid.ρ
    d = sys.tube.d

    Astart = getδarea(Ac,d,δstart)
    Aend = getδarea(Ac,d,δend)

    Mfilm_start = Astart .* Lfilm_start .* ρₗ
    Mfilm_end = Aend .* Lfilm_end .* ρₗ

    return Mfilm_start, Mfilm_end
end

function getMliquid(sys)

    Ac = sys.tube.Ac
    ρₗ = sys.liquid.ρ
    Xp = sys.liquid.Xp
    L = sys.tube.L

    Lliquidslug = XptoLliquidslug(Xp,L)
    Mliquid = ρₗ .* Ac .* Lliquidslug

    Mliquid
end

function getCa(μ,σ,velocity)
    Ca = abs.(μ.*velocity./σ)
end

function filmδcorr(Ca,d)
    filmδ = d .* 0.67.*Ca.^(2/3)./(1 .+ 3.35.*Ca.^(2/3))
end

# function getAdeposit(sys)
#     dXdt= sys.liquid.dXdt
#     Ac= sys.tube.Ac
#     d = sys.tube.d
#     δ = sys.vapor.δ
#     μₗ = sys.liquid.μₗ
#     σ = sys.liquid.σ

#     numofliquidslug = length(dXdt)

#     δarea = Ac .* (1 .- ((d .- 2*δ ) ./ d) .^ 2);

# # need to initialize it later on
#     Adeposit = deepcopy(dXdt)

#     Ca = getCa.(μₗ,σ,dXdt)
#     δarea_corr = getδarea.(Ac,d,filmδcorr.(Ca,d))


#     for i = 1:length(Adeposit)
#         loop_index = (i != numofliquidslug) ? i+1 : 1
#         Adeposit_left = dXdt[i][1] > 0 ? δarea_corr[i][1] : δarea[i]
#         Adeposit_right = dXdt[i][end] < 0 ? δarea_corr[i][end] : δarea[loop_index]
#         Adeposit[i]  =   (Adeposit_left, Adeposit_right)
#     end

#     Adeposit
# end

# function getAdeposit(sys,δdeposit)
#     dXdt= sys.liquid.dXdt
#     Ac= sys.tube.Ac
#     d = sys.tube.d
#     δ = sys.vapor.δ
#     μₗ = sys.liquid.μₗ
#     σ = sys.liquid.σ

#     numofliquidslug = length(dXdt)

#     δdepositArea = getδarea(Ac,d,δdeposit)

#     δarea = Ac .* (1 .- ((d .- 2*δ ) ./ d) .^ 2);

# # need to initialize it later on
#     Adeposit = deepcopy(dXdt)


#     for i = 1:length(Adeposit)
#         loop_index = (i != numofliquidslug) ? i+1 : 1
#         Adeposit_left = dXdt[i][1] > 0 ? δdepositArea : δarea[i]
#         Adeposit_right = dXdt[i][end] < 0 ? δdepositArea : δarea[loop_index]
#         Adeposit[i]  =   (Adeposit_left, Adeposit_right)
#     end

#     Adeposit
# end

function getAdeposit(sys,δdeposit)
    dXdt= sys.liquid.dXdt
    Ac= sys.tube.Ac
    d = sys.tube.d
    δstart = sys.vapor.δstart
    δend = sys.vapor.δend

    Nliquid = length(dXdt)

    loop_plus_index = [2:Nliquid;1]

    # numofliquidslug = length(dXdt)

    δdepositArea = getδarea(Ac,d,δdeposit)



    δarea_start = Ac .* (1 .- ((d .- 2*δstart) ./ d) .^ 2);
    δarea_end = Ac .* (1 .- ((d .- 2*δend) ./ d) .^ 2);
    # δarea = Ac .* (1 .- ((d .- 2*δ ) ./ d) .^ 2);

# need to initialize it later on
    Adeposit = deepcopy(dXdt)


    for i = 1:length(Adeposit)
        # loop_index = (i != numofliquidslug) ? i+1 : 1
        Adeposit_left = dXdt[i][1] > 0 ? δdepositArea : δarea_end[i]
        Adeposit_right = dXdt[i][end] < 0 ? δdepositArea : δarea_start[loop_plus_index[i]]

        # println(δarea_start)
        Adeposit[i]  =   (Adeposit_left, Adeposit_right)
    end

    Adeposit
end

function f_churchill(Re,ϵ=0.001)
    Θ1 = (-2.457*log((7/Re)^(0.9)  +  0.27 * ϵ))^16
    Θ2 = (37530/Re)^16
    f=8*((8/Re)^12+(1/(Θ1+Θ2)^1.5))^(1/12)
    
    f
end

function Catoδ(d,Ca;adjust_factor=1,δmin=2e-6,δmax=1e-4)

    δ = Ca .^ (2/3) ./ (1 .+ Ca .^ (2/3)) .* d ./ 2 .* adjust_factor
    if (δ < δmin)
        return δmin
    elseif (δ > δmax)
        return δmax
    else 
        return δ
    end
end

function RntoΔT(Rn,Tref,fluid_type,d,TtoP)
    p_fluid = SaturationFluidProperty(fluid_type,Tref);

    Rkg = p_fluid.R/p_fluid.M
    Rin = d/2
    P = TtoP(Tref)

    y = Rkg .* Tref ./ (p_fluid.hᵥ-p_fluid.hₗ) .* log.(1 .+ 2 .* p_fluid.σ ./ P .* (1 ./ Rn .- 1/(2Rin)))
    ΔTref = Tref .* (1 ./ (1 .- y) .- 1)
end