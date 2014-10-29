# This code is the julia port from the R package FinCal.

# Author: Vathy M. Kamulete
# Email: vathymut@gmail.com
# Github: github.com/vathymut

# Input
## r = discount rate, or the interest rate at which the amount will be compounded each period
## n = number of periods
## fv = future value
## pmt = payment per period
## pmt_type = payments occur at the end of each period (type=0); payments occur at the beginning of each period (type=1)
## cf = uneven cash flow
## g = growth rate of perpetuity
## spot_rates = spot rates

# Usage
## Call the methods directly
### pv_simple( 0.03, 3, 1000.0 )
### pv_simple( 0.07, 10, 100.0 )
### pv_annuity( 0.03, 12, 1000.0; pmt_type = 0 )
### pv_annuity( 0.03, 12, 1000.0; pmt_type = 1 )
### pv_annuity( 0.0425, 3, 30000.0; pmt_type = 0 )
### pv( 0.05, 20, 1000.0, 10.0; pmt_type = 1 )
### pv_uneven( 0.1, [-1000., -500., 0., 4000., 3500., 2000.] )
### pv_perpetuity( 0.1, 1000; g=0.02)
### pv_perpetuity( 0.1, 1000; pmt_type = 1 )
### pv_perpetuity( 0.1, 1000 )
### pv_from_spot( [ 0.1, 0.1, 0,1 ]; fv = -1.0 )

#### Estimate present value of a perpetuity ####
function pv_perpetuity( r::Float64, pmt; g::Float64 = 0.0, pmt_type::Int = 0 )
  any( [ isequal(pmt_type, val) for val in 0:1 ] ) || error( "Error: pmt_type should be 0 or 1!" )
  r >= g || error( "Error: g is not smaller than r!" )
  pv = ( pmt/( r-g ) )*( ( 1+r )^pmt_type )*( -1.0 )
  return pv
end

function pv_perpetuity( ; r = nothing, pmt = nothing, g = nothing, pmt_type = nothing )
    if r == nothing || pmt == nothing || g == nothing || pmt_type == nothing
        error("Must provide all arguments")
    end
    pv_perpetuity( r, pmt, g = g, pmt_type = pmt_type )
end

#### Estimate present value (pv) of a single sum ####
function pv_simple( r::Float64, n::Int, fv )
    return ( fv/(1+r)^n )*( -1.0 )
end

function pv_simple( ; r = nothing, n = nothing, fv = nothing )
    if r == nothing || n == nothing || fv == nothing
        error("Must provide all arguments")
    end
    pv_simple( r, n, fv )
end

#### Estimate present value (pv) of an annuity ####
function pv_annuity( r::Float64, n::Int, pmt; pmt_type::Int = 0 )
    any( [ isequal(pmt_type, val) for val in 0:1 ] ) || error( "Error: pmt_type should be 0 or 1!" )
    pv = ( pmt/r*( 1-1/( 1+r )^n ) )*(1 + r )^pmt_type*( -1 )
    return pv
end

function pv_annuity( ; r = nothing, n = nothing, pmt = nothing, pmt_type = nothing )
    if r == nothing || n == nothing || pmt == nothing || pmt_type == nothing
        error( "Must provide all arguments" )
    end
    pv_annuity( r, n, pmt, pmt_type = pmt_type )
end

#### Estimate present value (pv) ####
function pv( r::Float64, n::Int, fv, pmt; pmt_type::Int = 0 )
    return pv_simple( r, n, fv ) + pv_annuity( r, n, pmt; pmt_type = pmt_type )
end

function pv( ; r = nothing, n = nothing, fv = nothing, pmt = nothing, pmt_type = nothing )
    if r == nothing || n == nothing || fv == nothing || pmt == nothing || pmt_type == nothing
        error( "Must provide all arguments" )
    end
    pv( r, n, fv, pmt, pmt_type = pmt_type )
end

#### Computing the present value of an uneven cash flow series ####
function pv_uneven{ T <: Number }( r::Float64, cf::Vector{T} )
  n = length( cf )
  sum = 0.0
  for i=1:n
    sum += pv_simple( r, i, cf[i] )
  end
  return sum
end

function pv_uneven{ T <: Number }( r::Vector{Float64}, cf::Vector{T} )
  length( cf ) == length( r  ) || error( "Cash flows and discount rates must be the same size." )
  n = length( cf )
  sum = 0.0
  for i=1:n
    sum += pv_simple( r[i], i, cf[i] )
  end
  return sum
end

function pv_uneven( ; r = nothing, cf = nothing )
    if r == nothing || cf == nothing
      error( "Must provide all arguments" )
    end
    pv_uneven( r, cf )
end

#### Computing the present value from spot rates ####
function pv_from_spot( spot_rates::Vector{Float64}; fv = 1.0 )
  n = length( spot_rates )
  pv_spot = fv
  for i=n:-1:1
    # amount to rediscount each period = abs( pv_spot )
    pv_spot = pv_simple( spot_rates[ i ], 1, abs( pv_spot ) )
  end
  return pv_spot
end

function pv_from_spot( ; spot_rates = nothing, fv = nothing )
    if spot_rates == nothing || pv == nothing
      error( "Must provide all arguments" )
    end
    pv_from_spot( spot_rates, fv = fv )
end
