# Input
## rb = borrowing rate
## rl = lending rate
## n = number of periods
## pv = present value
## fv = future value
## pmt = payment per period
## pmt_type = payments at the end of each period (type=0); payments at the beginning of each period (type=1)
## cf = (uneven) cash flow
## r = norminal rate
## par = par value of the security

# Usage
## Call the methods directly
### pmt( 0.08,10,-1000,10 )
### discount_rate( 1, -95, 100, 0; pmt_type = 0 )
### n_periods( -1, 1.2, 0.2 )
### price_arbitrage( 0.03, 0.02, [ 10, 10, 10 ] )
### intra_accrint( 0.05; frac = 1.0, par = 1.0 )

include("helper.jl")
include("pv.jl")

#### Calculate accrued interest during period (intra) ####
function intra_accrint( r::Float64; frac::Float64 = 1.0, par::Float64 = 1.0 )
  0 <= frac <= 1.0 || error( "Error: frac must be between 0 and 1!" )
  return par*( 1 + r )^frac - par
end

function intra_accrint( ; r = nothing, frac = nothing, par = nothing )
    validate_kwargs( r, frac, par )
    return intra_accrint( r; frac = frac, par = par )
end

#### Estimate period payment ####
function pmt( r::Float64, n, pv, fv; pmt_type::Int = 0 )
  any( [ isequal(pmt_type, val) for val in 0:1 ] ) || error( "Error: pmt_type should be 0 or 1!" )
  return ( pv+fv/( 1+r )^n )*r/( 1-1/( 1+r )^n )*(-1)*( 1+r )^( -1*pmt_type )
end

function pmt( ; r = nothing, n = nothing, pv = nothing, fv = nothing, pmt_type = nothing )
    validate_kwargs( r, n, pv, fv, pmt_type )
    return pmt( r, n, pv, fv, pmt_type = pmt_type )
end

#### Estimate the number of periods ####
function n_periods( r::Float64, pv, fv; pmt = 0, pmt_type::Int = 0 )
  r >= zero( r ) || error( "r must be positive" )
  validate_pmt_type( pmt_type )
  n = log( -1 * (fv*r-pmt* (1+r)^pmt_type)/(pv*r+pmt* (1+r)^pmt_type) )/log( 1 + r )
  return n
end

function n_periods( ; r = nothing, pv = nothing, fv = nothing, pmt = nothing, pmt_type = nothing )
    validate_kwargs( r, pv, fv, pmt, pmt_type )
    return n_periods( r, pv, fv, pmt = pmt, pmt_type = pmt_type )
end

#### Computing the rate of return for each period ####
using Optim: optimize
function discount_rate( n, price, fv, pmt; pmt_type::Int = 0 )
  any( [ isequal(pmt_type, val) for val in 0:1 ] ) ||  error( "Error: pmt_type should be 0 or 1!" )
  # fmin minimizes the squared difference between the pv and the price
  fmin( discount_rate ) = ( pv( r = discount_rate, fv = fv, n = n, pmt = pmt; pmt_type = pmt_type ) - price )^2
  return optimize( fmin, 1e-10, 1.0 ).minimum
end

function discount_rate( ; n = nothing, price = nothing, fv = nothing, pmt = nothing, pmt_type = nothing )
    validate_kwargs( n, price, fv, pmt, pmt_type )
    return discount_rate( n, price, fv, pmt, pmt_type = pmt_type )
end

#### Find the lower and upper bound of the arbitrage price ####
function price_arbitrage{ T <: Number }( rb, rl, cf::Vector{ T } )
  # Find lower bound
  lb = pv_uneven( r = rb, cf = cf ) # Borrow in order to buy security
  rb = pv_uneven( r = rl, cf = cf ) # Sell security in order to lend
  return lb, rb
end

function price_arbitrage( ; rb = nothing, rl = nothing, cf = nothing )
    validate_kwargs( rb, rl, cf )
    return price_arbitrage( rb, rl, cf )
end

