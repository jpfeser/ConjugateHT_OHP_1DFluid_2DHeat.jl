using CoolProp
using Interpolations

export createCoolPropinterpolation,SaturationFluidProperty
#export DENSITY_MIN, DENSITY_MAX, PRESSURE_MIN, PRESSURE_MAX

#DENSITY_MIN = 0.0
#DENSITY_MAX = 0.0
#PRESSURE_MIN = 0.0
#PRESSURE_MAX = Inf

# fluid_type = "Butane"

function createCoolPropinterpolation(fluid_type::String,numofpoints=10000)
    
    Tcrit = CoolProp.PropsSI("Tcrit",fluid_type);
    Tmin = CoolProp.PropsSI("Tmin",fluid_type);
    println("Min acceptable Temperature for $fluid_type (K) = $Tmin")
    println("Critical Temperature for $fluid_type (K) = $Tcrit")

    Trange = LinRange(Tmin, Tcrit, numofpoints)
    Prange = CoolProp.PropsSI.("P","T",Trange,"Q",1.0,fluid_type);
    Drange = CoolProp.PropsSI.("D","T",Trange,"Q",1.0,fluid_type);

    Drmin, Drmax = extrema(Drange)
    Pmin, Pmax = extrema(Prange)
    println("P(Tmin) for $fluid_type (Pa) = $Pmin @ T = $Tmin (K)")
    println("P(Tcrit) for $fluid_type (Pa) = $Pmax @ T = $Tcrit (K)")

    Hᵥrange = CoolProp.PropsSI.("H","T",Trange,"Q",1.0,fluid_type);
    Hₗrange = CoolProp.PropsSI.("H","T",Trange,"Q",0.0,fluid_type);
    Hfgrange = Hᵥrange .- Hₗrange

    # --- Clamping can reduce numerical instabilities ---
    #.     (But also can hide issues.  Do we need this?)
    PtoT_raw = LinearInterpolation(Prange, Trange)
    PtoT = x -> PtoT_raw.(clamp.(x, Pmin, Pmax))

    DtoP_raw = LinearInterpolation(Drange, Prange);
    DtoP = x -> DtoP_raw.(clamp.(x, Drmin, Drmax))

    TtoP_raw = LinearInterpolation(Trange, Prange);
    TtoP = x -> TtoP_raw.(clamp.(x,Tmin,Tcrit));


    PtoD_raw = LinearInterpolation(Prange, Drange);
    PtoD = x -> PtoD_raw.(clamp.(x,Pmin,Pmax));

    PtoHfg_raw = LinearInterpolation(Prange, Hfgrange);
    PtoHfg = x -> PtoHfg_raw.(clamp.(x,Pmin,Pmax));

    PtoT,TtoP,PtoD,DtoP,PtoHfg
end


struct SaturationFluidProperty
    fluid_type::String
    Tref::Float64

    Cpₗ::Float64
    ρₗ::Float64
    μₗ::Float64
    hₗ::Float64
    kₗ::Float64
    Prₗ::Float64

    Cpᵥ::Float64
    ρᵥ::Float64
    μᵥ::Float64
    hᵥ::Float64
    kᵥ::Float64
    Prᵥ::Float64

    σ::Float64
    P::Float64
    R::Float64
    M::Float64
    Rkg::Float64

    αₗ::Float64
    νₗ::Float64
    νᵥ::Float64
    hₗᵥ::Float64
end

function SaturationFluidProperty(fluid_type,Tᵥ,Cpₗ,ρₗ,μₗ,hₗ,kₗ,Prₗ,Cpᵥ,ρᵥ,μᵥ,hᵥ,kᵥ,Prᵥ,σ,P,R,M)

    Rkg = R/M
    αₗ = kₗ/ρₗ/Cpₗ
    νₗ = μₗ/ρₗ
    νᵥ = μᵥ/ρᵥ;
    hₗᵥ = hᵥ-hₗ;

    SaturationFluidProperty(fluid_type,Tᵥ,Cpₗ,ρₗ,μₗ,hₗ,kₗ,Prₗ,Cpᵥ,ρᵥ,μᵥ,hᵥ,kᵥ,Prᵥ,σ,P,R,M,Rkg,αₗ,νₗ,νᵥ,hₗᵥ)
end

function SaturationFluidProperty(fluid_type::String,Tᵥ)
    Cpₗ = CoolProp.PropsSI("CPMASS","T",Tᵥ,"Q",0.0,fluid_type)
    ρₗ  = CoolProp.PropsSI("D","T",Tᵥ,"Q",0.0,fluid_type)
    hₗ = CoolProp.PropsSI("H","T",Tᵥ,"Q",0.0,fluid_type)

    Cpᵥ = CoolProp.PropsSI("CPMASS","T",Tᵥ,"Q",1.0,fluid_type)
    ρᵥ  = CoolProp.PropsSI("D","T",Tᵥ,"Q",1.0,fluid_type)
    hᵥ = CoolProp.PropsSI("H","T",Tᵥ,"Q",1.0,fluid_type)

    σ = CoolProp.PropsSI("I","T",Tᵥ,"Q",0.0,fluid_type)
    P = CoolProp.PropsSI("P","T",Tᵥ,"Q",0.0,fluid_type)
    R = CoolProp.PropsSI("GAS_CONSTANT","T",Tᵥ,"Q",1.0,fluid_type)
    M = CoolProp.PropsSI("M","T",Tᵥ,"Q",1.0,fluid_type)

    if fluid_type == "acetone"
        #println("Using acetone settings")
        mu0 = 0.014733408; # in mPa-s, for Arhenius model mu0*exp(Bv/T) fit from data in KayeLaby over 0-100C)
        Bv = 906.7791101; 
        μₗ = mu0*1e-3*exp(Bv/Tᵥ);
        kₗ = 0.175; # W/m-K, from Kaye Laby (ranges from 0.198@193K to 0.146@333K)
        μᵥ = 7e-6;
        kᵥ = 6e-3 + (20-6)*1e-3/(400-200)*(Tᵥ-200); #inaccurate above 400K, probably not used in code though
    else
#        println("Using default settings")
        μₗ  = CoolProp.PropsSI("V","T",Tᵥ,"Q",0.0,fluid_type)
        kₗ = CoolProp.PropsSI("CONDUCTIVITY","T",Tᵥ,"Q",0.0,fluid_type)
        μᵥ  = CoolProp.PropsSI("V","T",Tᵥ,"Q",1.0,fluid_type);
        kᵥ = CoolProp.PropsSI("CONDUCTIVITY","T",Tᵥ,"Q",1.0,fluid_type)
    end

    Prₗ = kₗ/Cpₗ/μₗ
    Prᵥ = kᵥ/Cpᵥ/μᵥ

    SaturationFluidProperty(fluid_type,Tᵥ,Cpₗ,ρₗ,μₗ,hₗ,kₗ,Prₗ,Cpᵥ,ρᵥ,μᵥ,hᵥ,kᵥ,Prᵥ,σ,P,R,M)
end

function Base.show(io::IO, p::SaturationFluidProperty)
    fluidtype = p.fluid_type
    Tref = p.Tref
    # typestring = typeof(p)
    println(io, "Saturation properties for $fluidtype at constant temperature $Tref [K]")
end
