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
function pv_perpetuity{ T <: FloatingPoint }( r::T, pmt::T, g::T = 0.0, pmt_type::Integer = 0 )
  validate_pmt_type( pmt_type )
  r >= g || error( "Error: g is not smaller than r!" )
  pv_amt = ( pmt/( r-g ) )*( ( 1+r )^pmt_type )*( -1.0 )
  return pv_amt
end

# Make keywords-only equivalent
@make_kwargs_only pv_perpetuity r pmt g pmt_type

#### Estimate present value (pv) of a single sum ####
function pv_simple{ T <: FloatingPoint }( r::T, n, fv )
    return ( fv/(1+r)^n )*( -1.0 )
end

# Make keywords-only equivalent
@make_kwargs_only pv_simple r n fv

#### Estimate present value (pv) of an annuity ####
function pv_annuity{ T <: FloatingPoint }( r::T, n, pmt, pmt_type::Integer = 0 )
    validate_pmt_type( pmt_type )
    pv = ( pmt/r*( 1-1/( 1+r )^n ) )*(1 + r )^pmt_type*( -1 )
    return pv
end

# Make keywords-only equivalent
@make_kwargs_only pv_annuity r n pmt pmt_type

#### Estimate present value (pv) ####
function pv{ T <: FloatingPoint }( r::T, n::Integer, fv, pmt, pmt_type::Integer = 0 )
    return pv_simple( r, n, fv ) + pv_annuity( r, n, pmt, pmt_type )
end

# Make keywords-only equivalent
@make_kwargs_only pv r n fv pmt pmt_type

#### Computing the present value of an uneven cash flow series ####
function pv_uneven{ T <: FloatingPoint }( r::T, cf::Vector{T} )
  n = length( cf )
  sum = 0.0
  for i=1:n
    sum += pv_simple( r, i, cf[i] )
  end
  return sum
end

function pv_uneven{ T <: FloatingPoint }( r::Vector{T}, cf::Vector{T} )
  length( cf ) == length( r  ) || error( "Cash flows and rates must be the same size." )
  n = length( cf )
  sum = 0.0
  for i=1:n
    sum += pv_simple( r[i], i, cf[i] )
  end
  return sum
end

# Make keywords-only equivalent
@make_kwargs_only pv_uneven r cf

#### Computing the present value from spot rates ####
function pv_from_spot{ T <: FloatingPoint }( spot_rates::Vector{T}, fv::T = 1.0 )
  final_discount = prod( 1.0 + spot_rates )
  return -fv/final_discount
end

# Make keywords-only equivalent
@make_kwargs_only pv_from_spot spot_rates fv

#### Estimate future value (fv) of a single sum ####
function fv_simple{ T <: FloatingPoint }( r::T, n, pv::T )
  return ( pv*(1+r)^n )*( -1.0 )
end

# Make keywords-only equivalent
@make_kwargs_only fv_simple r n pv

#### Estimate future value of an annuity ####
function fv_annuity{ T <: FloatingPoint }( r::T, n, pmt, pmt_type::Integer = 0 )
  validate_pmt_type( pmt_type )
  fv = ( pmt/r*( ( 1+r )^n - 1 ) )*( 1+r )^pmt_type*( -1.0 )
  return fv
end

# Make keywords-only equivalent
@make_kwargs_only fv_annuity r n pmt pmt_type

#### Estimate future value (fv) ####
function fv{ T <: FloatingPoint }( r::T, n, pv, pmt, pmt_type::Integer = 0 )
  return fv_simple( r, n, pv ) + fv_annuity( r, n, pmt; pmt_type = pmt_type )
end

# Make keywords-only equivalent
@make_kwargs_only fv r n pmt pmt_type

#### Computing the future value of an uneven cash flow series ####
function fv_uneven{ T <: FloatingPoint }( r::T, cf::Vector{T} )
  m = length( cf )
  sum = 0.0
  for i=1:m
    n = m - i
    sum += fv_simple( r, n, cf[i] )
  end
  return sum
end

function fv_uneven{ T <: FloatingPoint }( r::Vector{T}, cf::Vector{T} )
  length( cf ) == length( r  ) || error( "Cash flows and discount rates must be the same size." )
  m = length( cf )
  sum = 0.0
  for i=1:m
    n = m - i
    sum += fv_simple( r[i], n, cf[i] )
  end
  return sum
end

# Make keywords-only equivalent
@make_kwargs_only fv_uneven r cf

#### Computing future value from spot rates ####
function fv_from_spot{ T <: FloatingPoint }( spot_rates::Vector{T}, pv = -1.0 )
  final_discount = prod( 1.0 + spot_rates )
  return -pv*final_discount
end

# Make keywords-only equivalent
@make_kwargs_only fv_from_spot spot_rates pv

#### Calculate accrued interest during period (intra) ####
function accrint_intra_period{ T <: FloatingPoint }( r::T; frac::T = 1.0, par::T = 1.0 )
  0 <= frac <= 1.0 || error( "Error: frac must be between 0 and 1!" )
  return par*( 1 + r )^frac - par
end

# Make keywords-only equivalent
@make_kwargs_only accrint_intra_period r, frac, par

#### Estimate period payment ####
function pmt{ T <: FloatingPoint }( r::T, n, pv, fv, pmt_type::Integer = 0 )
  any( [ isequal(pmt_type, val) for val in 0:1 ] ) || error( "Error: pmt_type should be 0 or 1!" )
  return ( pv+fv/( 1+r )^n )*r/( 1-1/( 1+r )^n )*(-1)*( 1+r )^( -1*pmt_type )
end

# Make keywords-only equivalent
@make_kwargs_only pmt r, n, pv, fv, pmt_type

#### Estimate the number of periods ####
function nper{ T <: FloatingPoint }( r::T, pv, fv, pmt = 0, pmt_type::Int = 0 )
  r >= zero( r ) || error( "r must be positive" )
  validate_pmt_type( pmt_type )
  n = log( -1 * (fv*r-pmt* (1+r)^pmt_type)/(pv*r+pmt* (1+r)^pmt_type) )/log( 1 + r )
  return n
end

# Make keywords-only equivalent
@make_kwargs_only nper r, pv, fv, pmt_type

#### Computing the rate of return for each period ####
using Optim: optimize
function discount_rate( n::Integer, price, fv, pmt, pmt_type::Integer = 0 )
  any( [ isequal(pmt_type, val) for val in 0:1 ] ) ||  error( "Error: pmt_type should be 0 or 1!" )
  # fmin minimizes the squared difference between the pv and the price
  fmin( discount_rate ) = ( pv( r = discount_rate, n = n, fv = fv, pmt = pmt, pmt_type = pmt_type ) - price )^2
  return optimize( fmin, 1e-10, 1.0 ).minimum
end

# Make keywords-only equivalent
@make_kwargs_only discount_rate r, price, fv, pmt, pmt_type

#### Find the lower and upper bound of the arbitrage price ####
function price_arbitrage{ T <: FloatingPoint }( rborrow::T, rlend::T, cf::Vector{ T } )
  lb = pv_uneven( r = rborrow, cf = cf ) # Borrow in order to buy security
  rb = pv_uneven( r = rlend, cf = cf ) # Sell security in order to lend
  return lb, rb
end

# Make keywords-only equivalent
@make_kwargs_only price_arbitrage rborrow, rlend, cf

