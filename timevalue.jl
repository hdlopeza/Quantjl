# Input
## r = discount rate, or the interest rate at which the amount will be compounded each period
## n = number of periods
## fv = future value
## pv = present value
## pmt = payment per period
## pmt_type = payments occur at the end of each period (type=0); payments occur at the beginning of each period (type=1)
## cf = uneven cash flow
## g = growth rate of perpetuity
## spot_rates = spot rates
## rborrow = borrowing rate
## rlend = lending rate
## par = par value of the security

include( "helper.jl" )

#### Estimate present value of a perpetuity ####
function pv_perpetuity( r::Float64, pmt; g::Float64 = 0.0, pmt_type::Int = 0 )
  validate_pmt_type( pmt_type )
  r >= g || error( "Error: g is not smaller than r!" )
  pv = ( pmt/( r-g ) )*( ( 1+r )^pmt_type )*( -1.0 )
  return pv
end

function pv_perpetuity( ; r = nothing, pmt = nothing, g = nothing, pmt_type = nothing )
    validate_kwargs( r, pmt, g, pmt_type )
    return pv_perpetuity( r, pmt, g = g, pmt_type = pmt_type )
end

#### Estimate present value (pv) of a single sum ####
function pv_simple( r::Float64, n, fv )
    return ( fv/(1+r)^n )*( -1.0 )
end

function pv_simple( ; r = nothing, n = nothing, fv = nothing )
    validate_kwargs( r, n, fv )
    return pv_simple( r, n, fv )
end

#### Estimate present value (pv) of an annuity ####
function pv_annuity( r::Float64, n, pmt; pmt_type::Int = 0 )
    validate_pmt_type( pmt_type )
    pv = ( pmt/r*( 1-1/( 1+r )^n ) )*(1 + r )^pmt_type*( -1 )
    return pv
end

function pv_annuity( ; r = nothing, n = nothing, pmt = nothing, pmt_type = nothing )
    validate_kwargs( r, n, pmt, pmt_type )
    return pv_annuity( r, n, pmt, pmt_type = pmt_type )
end

#### Estimate present value (pv) ####
function pv( r::Float64, n, fv, pmt; pmt_type::Int = 0 )
    return pv_simple( r, n, fv ) + pv_annuity( r, n, pmt; pmt_type = pmt_type )
end

function pv( ; r = nothing, n = nothing, fv = nothing, pmt = nothing, pmt_type = nothing )
    validate_kwargs( r, n, fv, pmt, pmt_type )
    return pv( r, n, fv, pmt, pmt_type = pmt_type )
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
  length( cf ) == length( r  ) || error( "Cash flows and rates must be the same size." )
  n = length( cf )
  sum = 0.0
  for i=1:n
    sum += pv_simple( r[i], i, cf[i] )
  end
  return sum
end

function pv_uneven( ; r = nothing, cf = nothing )
    validate_kwargs( r, cf )
    return pv_uneven( r, cf )
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
    validate_kwargs( spot_rates, fv )
    return pv_from_spot( spot_rates, fv = fv )
end


#### Estimate future value (fv) of a single sum ####
function fv_simple( r::Float64, n, pv )
  return ( pv*(1+r)^n )*( -1.0 )
end

function fv_simple( ; r = nothing, n = nothing, pv = nothing )
    validate_kwargs( r, n, pv )
    fv_simple( r, n, pv )
end

#### Estimate future value of an annuity ####
function fv_annuity( r::Float64, n, pmt; pmt_type::Int = 0 )
  validate_pmt_type( pmt_type )
  fv = ( pmt/r*( ( 1+r )^n - 1 ) )*( 1+r )^pmt_type*( -1.0 )
  return fv
end

function fv_annuity( ; r = nothing, n = nothing, pmt = nothing, pmt_type = nothing )
    validate_kwargs( r, n, pmt, pmt_type )
    fv_annuity( r, n, pmt, pmt_type = pmt_type )
end

#### Estimate future value (fv) ####
function fv( r::Float64, n, pv, pmt; pmt_type::Int = 0 )
  return fv_simple( r, n, pv ) + fv_annuity( r, n, pmt; pmt_type = pmt_type )
end

function fv( ; r = nothing, n = nothing, pv = nothing, pmt = nothing, pmt_type = nothing )
    validate_kwargs( r, n, pv, pmt, pmt_type )
    return fv( r, n, pv, pmt, pmt_type = pmt_type )
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

function fv_uneven{ T<: Number }( r::Vector{Float64}, cf::Vector{T} )
  length( cf ) == length( r  ) || error( "Cash flows and discount rates must be the same size." )
  m = length( cf )
  sum = 0.0
  for i=1:m
    n = m - i
    sum += fv_simple( r[i], n, cf[i] )
  end
  return sum
end

function fv_uneven( ; r = nothing, cf = nothing )
    validate_kwargs( r, cf )
    return fv_uneven( r, cf )
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
    validate_kwargs( spot_rates, pv )
    return fv_from_spot( spot_rates, pv = pv )
end

#### Calculate accrued interest during period (intra) ####
function accrued_interest_intra_period( r::Float64; frac::Float64 = 1.0, par::Float64 = 1.0 )
  0 <= frac <= 1.0 || error( "Error: frac must be between 0 and 1!" )
  return par*( 1 + r )^frac - par
end

function accrued_interest_intra_period( ; r = nothing, frac = nothing, par = nothing )
    validate_kwargs( r, frac, par )
    return accrued_interest_intra_period( r; frac = frac, par = par )
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
function price_arbitrage{ T <: Number }( rborrow, rlend, cf::Vector{ T } )
  lb = pv_uneven( r = rborrow, cf = cf ) # Borrow in order to buy security
  rb = pv_uneven( r = rlend, cf = cf ) # Sell security in order to lend
  return lb, rb
end

function price_arbitrage( ; rborrow = nothing, rlend = nothing, cf = nothing )
    validate_kwargs( rborrow, rlend, cf )
    return price_arbitrage( rborrow, rlend, cf )
end
