# Input
## cpr = conditional prepayment rate
## smm = single monthly mortality rate
## passthrough_rate = pass-through rate
## wac = weighted average coupon
## pmt = payment per period
## pmt_type = payments occur at the end of each period (type=0); payments occur at the beginning of each period (type=1)
## cf = (uneven) cash flow
## par = par value of the security

include( "helper.jl" )
include( "timevalue.jl" )

#### Convert conditional prepayment rate to single monthly mortality rate ####
function mbs_cpr2smm{ T <: FloatingPoint }( cpr::T )
  return 1.0 - ( 1 - cpr )^(1/12)
end

function mbs_cpr2smm{ T <: FloatingPoint }( cpr::Vector{T} )
  return 1.0 - ( 1 - cpr ).^(1/12)
end

#### Compute monthly prepayment ####
function mbs_prepayment{ T <: FloatingPoint }( balance, pmt, smm::T )
  return smm*( balance + pmt ) # pmt is negative
end

function mbs_prepayment( ; balance = nothing, pmt = nothing, smm = nothing )
    validate_kwargs( balance, pmt, smm )
    return mbs_prepayment( balance, pmt, smm )
end

#### Get conditional prepayment rate schedule from the psa's (standard) model assumption ####
function mbs_cpr_schedule{ T <: Integer }( ; psa_maxrate = 0.06, psa_speed = 100.0, psa_threshold::T = 30, n::T = 360, seasoning::T = 0  )
  cpr = Array( Float64, n )
  cpr[ psa_threshold:end ] = psa_maxrate
  cpr[ 1:psa_threshold ] = (psa_maxrate/psa_threshold)*[ 1:psa_threshold ]
  cpr[:] = cpr.*( psa_speed/100 )
  return cpr[ seasoning+1:end ]
end

#### Get the scheduled principal payment ####
function mbs_principal_payment( pmt, balance, wac )
  return -pmt - balance*wac
end

function mbs_principal_payment( ; pmt = nothing, balance = nothing, wac = nothing )
  validate_kwargs( pmt, balance, wac )
  return mbs_principal_payment( pmt, balance, wac )
end

#### Get the interest payment ####
function mbs_interest_payment( balance, wac )
  return balance*wac
end

function mbs_interest_payment( ; balance = nothing, wac = nothing )
  validate_kwargs( balance, wac )
  return mbs_interest_payment( balance, wac )
end

#### Get the interest payment paid out to pass-through investors ####
function mbs_passthrough_interest_payment( balance, passthrough_rate )
  return balance*passthrough_rate
end

function mbs_passthrough_interest_payment( ; balance = nothing, passthrough_rate = nothing )
  validate_kwargs( balance, passthrough_rate )
  return mbs_passthrough_interest_payment( balance, passthrough_rate )
end

#### Get the remaining balance ####
function mbs_remaining_balance{ T <: FloatingPoint }( balance, wac, pmt; smm::T = 0.0 )
  pmt <= zero( pmt ) || error( "pmt must be negative: outgoing cashflow" )
  prepayment = mbs_prepayment( balance = balance, pmt = pmt, smm = smm )
  principal_pmnt = mbs_principal_payment( pmt = pmt, balance = balance, wac = wac )
  return balance - principal_pmnt - prepayment #pmt is negative
end

function mbs_remaining_balance( ; balance = nothing, wac = nothing, pmt = nothing, smm = nothing )
  validate_kwargs( balance, wac, pmt, smm )
  return mbs_remaining_balance( balance, wac, pmt; smm = smm )
end

#### Create MbsCashFlow type ####
type MbsCashFlow
  interest_pmnt::Array{FloatingPoint, 1}
  principal_pmnt::Array{FloatingPoint, 1}
  mtg_pmnt::Array{FloatingPoint, 1}
  balance_remaining::Array{FloatingPoint, 1}
  prepayment_amt::Array{FloatingPoint, 1}
  passthrough_interest_pmnt::Array{FloatingPoint, 1}

  function MbsCashFlow( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt, passthrough_interest_pmnt )
    flows_tuple = ( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt, passthrough_interest_pmnt )
    arrays_length = unique( map( length, flows_tuple ) )
    length( arrays_length ) == 1 || error( "Arrays must all have the same lengths." )
    new( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt, passthrough_interest_pmnt )
  end
end

#### Get the mbs cash flows ####
function mbs_cf{ T <: FloatingPoint }( r, n::Integer, face_value::T, wac::T, passthrough_rate::T, smm::Vector{T} )
  # Initialize arrays for interest, principal, prepayment and mortgage (monthly) payment
  mtg_pmnt = Array( typeof( wac ), n )
  interest_pmnt, principal_pmnt = similar( mtg_pmnt ), similar( mtg_pmnt )
  prepayment_amt, balance_remaining = similar( mtg_pmnt ), similar( mtg_pmnt )
  passthrough_interest_pmnt = similar( mtg_pmnt )
  # Initialize remaining balance
  bal_iter = face_value
  for i=1:n
    n_iter::Integer = n-i+1
    smm_iter::FloatingPoint = i < n ? smm[i]:0.0
    # Update current (monthly) payment
    mtg_pmnt[i] = pmt( r = r, n = n_iter, pv = bal_iter, fv = 0, pmt_type = 0 )
    interest_pmnt[i] = mbs_interest_payment( balance = bal_iter, wac = wac )
    passthrough_interest_pmnt[i] = mbs_passthrough_interest_payment( balance = bal_iter, passthrough_rate = passthrough_rate )
    principal_pmnt[i] = mbs_principal_payment( pmt = mtg_pmnt[i], balance = bal_iter, wac = wac )
    prepayment_amt[i] = mbs_prepayment( balance = bal_iter, pmt = mtg_pmnt[i], smm = smm_iter )
    # Update remaining balance
    balance_remaining[i] = bal_iter
    bal_iter = mbs_remaining_balance( balance = bal_iter, wac = r, pmt = mtg_pmnt[i]; smm = smm_iter )
  end
  return MbsCashFlow( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt, passthrough_interest_pmnt )
end

function mbs_cf( ; r = nothing, n = nothing, face_value = nothing, wac = nothing, passthrough_rate = nothing, smm = nothing )
  validate_kwargs( r, n, face_value, wac, passthrough_rate, smm )
  return mbs_cf( r, n, face_value, wac, passthrough_rate, smm )
end

#### Calculate the theoretical price from cashflows and spot rates (off of the zero curve) ####
# Get theoretical price
function mbs_zs2price{ T <: FloatingPoint }( spotrates::Vector{T}, cf::Vector{T}, zspread::T )
  d, dcf = similar( cf ), similar( cf ) # discount factor and discounted cash flows
  T = length( cf )
  for t=1:T
    d[t] = 1/( 1 + spotrates[i] )^t
    dcf[t] = cf[t]*d[t]
  end
  return sum( dcf )
end

#### Compute the Zero-volatility Spread or Z-Spread ####
using Optim: optimize
function mbs_zs{ T <: FloatingPoint }( price::T, spotrates::Vector{T}, cf::Vector{T} )
  fmin( zs::T ) = ( price - mbs_zs2price( spotrates, cf, zs ) )^2
  return optimize( fmin, 1e-10, 1.0 ).minimum
end
