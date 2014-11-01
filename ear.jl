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

#### Convert stated annual rate to the effective annual rate ####
function ear( r::Float64, m::Int )
  return ( 1 + r/m )^m - 1.0
end

function ear( ; r = nothing, m = nothing )
    if r == nothing || m == nothing
        error("Must provide all arguments")
    end
    ear( r, m )
end

#### Convert stated annual rate to the effective annual rate ####
function compound_ear( ear::Float64, m::Int )
  return ( 1 + ear )^( 1/m ) - 1.0
end

function compound_ear( ; ear = nothing, m = nothing )
    if ear == nothing || m == nothing
        error("Must provide all arguments")
    end
    compound_ear( ear, m )
end

#### Convert stated annual rate to the effective annual rate with continuous compounding ####
function ear_continuous( r::Float64 )
  return exp( r ) - 1.0
end

function ear_continuous( ; r = nothing )
    if r == nothing
        error( "Must provide all arguments" )
    end
    ear_continuous( r )
end

#### Computing HPR, the holding period return ####
function ear2hpr( ear::Float64, t::Int )
  return ( 1.0 + ear )^( t/365 - 1.0 )
end

function ear2hpr( ; ear = nothing, t = nothing )
    if ear == nothing
        error("Must provide all arguments")
    end
    ear2hpr( ear, t )
end

