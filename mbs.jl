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
function mbs_cpr2smm( cpr::Float64 )
  return 1.0 - ( 1 - cpr )^(1/12)
end

function mbs_cpr2smm( cpr::Vector{Float64} )
  return 1.0 - ( 1 - cpr ).^(1/12)
end

#### Compute monthly prepayment ####
function mbs_prepayment( balance, pmt, smm::Float64 )
  return smm*( balance + pmt ) # pmt is negative
end

function mbs_prepayment( ; balance = nothing, pmt = nothing, smm = nothing )
    validate_kwargs( balance, pmt, smm )
    return mbs_prepayment( balance, pmt, smm )
end

#### Get conditional prepayment rate schedule from the psa's (standard) model assumption ####
function mbs_cpr_schedule( ; psa_maxrate = 0.06, psa_speed = 100.0, psa_threshold::Int = 30, n::Int = 360, seasoning::Int = 0  )
  cpr = Array( Float64, n )
  cpr[ psa_threshold:end ] = psa_maxrate
  cpr[ 1:psa_threshold ] = (psa_maxrate/psa_threshold)*[ 1:psa_threshold ]
  cpr[:] = cpr.*( psa_speed/100 )
  return cpr[ seasoning+1:end ]
end

#### Get the scheduled principal payment ####
function mbs_principal_payment( pmt, balance, passthrough_rate )
  return -pmt - balance*passthrough_rate
end

function mbs_principal_payment( ; pmt = nothing, balance = nothing, passthrough_rate = nothing )
  validate_kwargs( pmt, balance, passthrough_rate )
  return mbs_principal_payment( pmt, balance, passthrough_rate )
end

#### Get the interest payment ####
function mbs_interest_payment( balance, passthrough_rate )
  return balance*passthrough_rate
end

function mbs_interest_payment( ; balance = nothing, passthrough_rate = nothing )
  validate_kwargs( balance, passthrough_rate )
  return mbs_interest_payment( balance, passthrough_rate )
end

#### Get the remaining balance ####
function mbs_remaining_balance( balance, wac, pmt; smm::Float64 = 0.0 )
  pmt <= zero( pmt ) || error( "pmt must be negative: outgoing cashflow" )
  prepayment = mbs_prepayment( balance, pmt, smm::Float64 )
  mbs_principal_payment( pmt, balance, passthrough_rate )
  return ( 1 + wac/12 )*balance + pmt - prepayment #pmt is negative
end

function mbs_remaining_balance( ; balance = nothing, wac = nothing, pmt = nothing, smm = nothing )
  validate_kwargs( balance, wac, pmt, smm )
  return mbs_remaining_balance( balance, wac, pmt; smm = smm )
end

#### Create MbsCashFlow type ####
type MbsCashFlow
  interest_pmnt::Array{Float64, 1}
  principal_pmnt::Array{Float64, 1}
  mtg_pmnt::Array{Float64, 1}
  balance_remaining::Array{Float64, 1}
  prepayment_amt::Array{Float64, 1}

  function MbsCashFlow( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt )
    flows_tuple = ( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt )
    arrays_length = unique( map( length, flows_tuple ) )
    length( arrays_length ) == 1 || error( "Arrays must all have the same lengths." )
    new( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt )
  end
end

#### Get the mbs cash flows ####
function mbs_cf( r, n::Int, face_value, passthrough_rate, smm )
  # Initialize arrays for interest, principal, prepayment and mortgage (monthly) payment
  interest_pmnt, principal_pmnt = Array( Float64, n ), Array( Float64, n )
  prepayment_amt, mtg_pmnt = Array( Float64, n ), Array( Float64, n )
  balance_remaining = Array( Float64, n )
  # Initialize remaining balance
  bal_iter = face_value
  for i=1:n
    n_iter::Int = n-i+1
    smm_iter::Float64 = i < n ? smm[i]:0.0
    # Update current (monthly) payment
    @show mtg_pmnt[i] = pmt( r = r, n = n_iter, pv = bal_iter, fv = 0, pmt_type = 0 )
    @show interest_pmnt[i] = mbs_interest_payment( balance = bal_iter, passthrough_rate = passthrough_rate )
    @show principal_pmnt[i] = mbs_principal_payment( pmt = mtg_pmnt[i], balance = bal_iter, passthrough_rate = passthrough_rate )
    @show prepayment_amt[i] = mbs_prepayment( balance = face_value, pmt = mtg_pmnt[i], smm = smm_iter )
    # Update remaining balance
    @show balance_remaining[i] = bal_iter
    @show bal_iter = mbs_remaining_balance( balance = bal_iter, wac = r, pmt = mtg_pmnt[i]; smm = smm_iter )
  end
  return MbsCashFlow( interest_pmnt, principal_pmnt, mtg_pmnt, balance_remaining, prepayment_amt )
end

function mbs_cf( ; r = nothing, n = nothing, face_value = nothing, passthrough_rate = nothing, smm = nothing )
  validate_kwargs( r, n, face_value, passthrough_rate, smm )
  return mbs_cf( r, n, face_value, passthrough_rate, smm )
end

