# This code is in the julia port from the R package FinCal.
# Planning to next port functions from the F# module Quantifa.

# Author: Vathy M. Kamulete
# Email: vathymut@gmail.com
# Github: github.com/vathymut

# Input
## r = norminal rate
## m = number of compounding periods per year
## n = number of (payment) periods
## t = number of days remaining until maturity
## rc = continuous compounded rate
## pv = present value
## pmt = payment per period
## face_value = face value of bond
## coupon_rate = coupon rate

# Usage
## Call the methods directly
### r_continuous( 0.03, 4 )
### r_norminal( 0.03, 1 )
### r_norminal( 0.03, 4 )
### r_perpetuity( 4.5, -75 )
### r_simple( -1, 1.2, 1 )

#### Computing r, discount rate from pv, fv and n, number of periods ####
function r_simple( pv, fv, n::Int )
  return ( -fv/pv )^( 1/n ) - 1.0
end

function r_simple( ; pv = nothing, fv = nothing, n = nothing )
    if pv == nothing || fv == nothing || n == nothing
        error("Must provide all arguments")
    end
    r_simple( pv, fv, n )
end

#### Convert a given norminal rate to a continuous compounded rate ####
function r_continuous( r::Float64, m::Int )
  return m*log( 1 + r/m )
end

function r_continuous( ; r = nothing, m = nothing )
    if r == nothing || m == nothing
        error("Must provide all arguments")
    end
    r_continuous( r, m )
end

#### Convert a given continuous compounded rate to a norminal rate ####
function r_norminal( rc::Float64, m::Int )
  return m*( exp( rc/m ) - 1.0 )
end

function r_norminal( ; rc = nothing, m = nothing )
    if rc == nothing || m == nothing
        error("Must provide all arguments")
    end
    r_norminal( rc, m )
end

#### Computing the rate of return for a perpetuity ####
function r_perpetuity( pmt::Float64, pv )
  return -1.0*pmt/pv
end

function r_perpetuity( ; pmt = nothing, pv = nothing )
    if pmt == nothing || pv == nothing
        error("Must provide all arguments")
    end
    r_perpetuity( pmt, pv )
end


