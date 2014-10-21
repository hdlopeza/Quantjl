# This code is the julia port from the R package FinCal.

# Author: Vathy M. Kamulete
# Email: vathymut@gmail.com
# Github: github.com/vathymut

# Input
## r = discount rate, or the interest rate at which the amount will be compounded each period
## n = number of periods
## pv = present value
## pmt = payment per period
## type_pmt = payments occur at the end of each period (type=0); payments occur at the beginning of each period (type=1)
## cf = uneven cash flow
## spot_rates = spot rates

# Usage
## Call the methods directly
### fv_simple( 0.08, 10, -300.0 )
### fv_simple( 0.04, 20, -50000.0 )
### fv_annuity( 0.03, 12,-1000; type_pmt = 1 )
### fv( 0.07, 10, 1000.0, 10; type_pmt = 1 )
### fv_uneven( 0.1, [-1000., -500., 0., 4000., 3500., 2000.] )
### fv_from_spot( [ 0.1, 0.1, 0,1 ]; pv = -1.0 )

#### Estimate future value (fv) of a single sum ####
function fv_simple( r::Float64, n::Int, pv )
  return ( pv*(1+r)^n )*( -1.0 )
end

function fv_simple( ; r = nothing, n = nothing, pv = nothing )
    if r == nothing || n == nothing || pv == nothing
        error("Must provide all arguments")
    end
    fv_simple( r, n, pv )
end

#### Estimate future value of an annuity ####
function fv_annuity( r::Float64, n::Int, pmt; type_pmt::Int = 0 )
  any( [ isequal(type_pmt, val) for val in 0:1 ] ) || error( "Error: type_pmt should be 0 or 1!" )
  fv = ( pmt/r*( ( 1+r )^n - 1 ) )*( 1+r )^type_pmt*( -1.0 )
  return fv
end

function fv_annuity( ; r = nothing, n = nothing, pmt = nothing, type_pmt = nothing )
    if r == nothing || n == nothing || pmt == nothing || type_pmt == nothing
        error( "Must provide all arguments" )
    end
    fv_annuity( r, n, pmt, type_pmt = type_pmt )
end

#### Estimate future value (fv) ####
function fv( r::Float64, n::Int, pv, pmt; type_pmt::Int = 0 )
  return fv_simple( r, n, pv ) + fv_annuity( r, n, pmt; type_pmt = type_pmt )
end

function fv( ; r = nothing, n = nothing, pv = nothing, pmt = nothing, type_pmt = nothing )
    if r == nothing || n == nothing || pv == nothing || pmt == nothing || type_pmt == nothing
      error( "Must provide all arguments" )
    end
    fv( r, n, pv, pmt, type_pmt = type_pmt )
end

#### Computing the future value of an uneven cash flow series ####
function fv_uneven{ T<: Number }( r::Float64, cf::Vector{T} )
  m = length( cf )
  sum = 0.0
  for i=1:m
    n = m - i
    sum += fv_simple( r, n, cf[i] )
  end
  return sum
end

function fv_uneven( ; r = nothing, cf = nothing )
    if r == nothing || cf == nothing
      error( "Must provide all arguments" )
    end
    fv_uneven( r, cf )
end

#### Computing future value from spot rates ####
function fv_from_spot( spot_rates::Vector{Float64}; pv = -1.0 )
  n = length( spot_rates )
  fv_spot = pv
  for i=1:n
    # amout to reinvest each period = -abs( fv_spot )
    fv_spot = fv_simple( spot_rates[ i ], 1, -abs( fv_spot ) )
  end
  return fv_spot
end

function fv_from_spot( ; spot_rates = nothing, pv = nothing )
    if spot_rates == nothing || pv == nothing
      error( "Must provide all arguments" )
    end
    fv_from_spot( spot_rates, pv = pv )
end
