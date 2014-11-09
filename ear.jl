# Input
## r = stated annual rate
## m = number of compounding periods per year
## ear = effective annual rate
## t = number of days remaining until maturity

# Usage
## Call the methods directly
### ear( 0.12, 12 )
### ear( 0.04,365 )
### ear_continuous( 0.03 )
### ear_continuous( 0.1 )
### ear2hpr( 0.05039, 150 )

include("helper.jl")

#### Convert stated annual rate with m compounding periods to the effective annual rate ####
function ear( r::Float64, m::Int )
  return ( 1 + r/m )^m - 1.0
end

function ear( ; r = nothing, m = nothing )
    validate_kwargs( r, m )
    return ear( r, m )
end

#### Convert the effective annual rate to the stated annual rate with m compounding ####
function compound_ear( ear::Float64, m::Int )
  return ( 1 + ear )^( 1/m ) - 1.0
end

function compound_ear( ; ear = nothing, m = nothing )
    validate_kwargs( ear, m )
    return compound_ear( ear, m )
end

#### Convert stated annual rate to the effective annual rate with continuous compounding ####
function ear_continuous( r::Float64 )
  return exp( r ) - 1.0
end

function ear_continuous( ; r = nothing )
    validate_kwargs( r )
    return ear_continuous( r )
end

#### Computing HPR, the holding period return ####
function ear2hpr( ear::Float64, t::Int )
  return ( 1.0 + ear )^( t/365 - 1.0 )
end

function ear2hpr( ; ear = nothing, t = nothing )
    validate_kwargs( ear, t )
    return ear2hpr( ear, t )
end

