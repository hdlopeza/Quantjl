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
## cf = uneven cash flow

# Usage
## Call the methods directly
### r_continuous( 0.03, 4 )
### r_norminal( 0.03, 1 )
### r_norminal( 0.03, 4 )
### r_perpetuity( 4.5, -75 )
### r_simple( -1, 1.2, 1 )
### irr( [ -5, 1.6, 2.4, 2.8 ] )

#### Computing r, discount rate from pv, fv and n, number of periods ####
function r_simple( pv, fv, n )
  return ( -fv/pv )^( 1/n ) - 1.0
end

function r_simple( ; pv = nothing, fv = nothing, n = nothing )
    validate_kwargs( pv, fv, n )
    r_simple( pv, fv, n )
end

#### Convert a given norminal rate to a continuous compounded rate ####
function r_continuous( r::Float64, m::Int )
  return m*log( 1 + r/m )
end

function r_continuous( ; r = nothing, m = nothing )
    validate_kwargs( r, m )
    r_continuous( r, m )
end

#### Convert a given continuous compounded rate to a norminal rate ####
function r_norminal( rc::Float64, m::Int )
  return m*( exp( rc/m ) - 1.0 )
end

function r_norminal( ; rc = nothing, m = nothing )
    validate_kwargs( rc, m )
    r_norminal( rc, m )
end

#### Computing the rate of return for a perpetuity ####
function r_perpetuity( pmt::Float64, pv )
  return -1.0*pmt/pv
end

function r_perpetuity( ; pmt = nothing, pv = nothing )
    validate_kwargs( pmt, pv )
    r_perpetuity( pmt, pv )
end

#### Computing the IRR, the internal rate of return ####
using Optim: optimize
function irr{ T <: Number }( cf::Vector{T} )
  fmin( irr::Float64 ) = ( -1*pv_uneven( r = irr, cf = cf[2:end] ) + cf[1] )^2
  return optimize( fmin, 1e-10, 1.0 ).minimum
end

function irr( ; cf = nothing )
    validate_kwargs( cf )
    irr( cf )
end
