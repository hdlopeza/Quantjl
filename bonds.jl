# Input
## r = stated annual rate
## bey = bond equivalent yield
## ear = effective annual rate
## face_value = face value of bond
## price = present value of cash flow (market price of bond)
## ytm = yield to maturity

# Usage
## Call the methods directly
### ear2bey( 0.12 )
### bey2ear( 0.04 )
### ytm( 100.0, -95.0, 0.05, 1 )
### dirty_price( 0.05, 10, 20; face_value = 100.0, frac = 0.0 )
### clean_price( 0.05, 10, 20; face_value = 100.0, frac = 0.0 )
### price_from_ytm( 0.04, 0.04, 20; face_value = 1000, pmt_type = 0 )

include("pricing.jl")
include("pv.jl")
include("helper.jl")

#### bond-equivalent yield (BEY), 2 x the semiannual discount rate ####
function ear2bey( ear::Float64 )
  return ( ( 1.0 + ear )^0.5 - 1.0 )*2.0
end

function ear2bey( ; ear = nothing )
    validate_kwargs( ear )
    return ear2bey( ear )
end

#### yield to maturity, from the bond-equivalent yield (BEY)
function bey2ear( bey::Float64 )
  return ( 1.0 + bey/2 )^2 - 1.0
end

function bey2ear( ; bey = nothing )
    validate_kwargs( bey )
    return bey2ear( bey )
end

#### Compute yield to maturity ####
function ytm( face_value, price, coupon_rate::Float64, n )
  coupon = face_value*coupon_rate/2
  return discount_rate( n = n, price = price, fv = face_value, pmt = coupon; pmt_type = 0 )
end

function ytm( ; face_value = nothing, price = nothing, n = nothing, coupon_rate = nothing )
    validate_kwargs( face_value, price, coupon_rate, n )
    return ytm( face_value, price, coupon_rate, n )
end

#### Calculate the price from the yield to maturity ####
function price_from_ytm( ytm::Float64, coupon_rate::Float64, n; face_value = 1000, pmt_type = 0 )
  coupon_pmt = face_value*coupon_rate/2
  return pv( r = ytm, n = n, fv = 1000, pmt = coupon_pmt, pmt_type = 0 )
end

function price_from_ytm( ; ytm = nothing, coupon_rate = nothing, n = nothing, face_value = 1000, pmt_type = 0 )
    validate_kwargs( ytm, coupon_rate, n, face_value, pmt_type )
    return price_from_ytm( ytm, coupon_rate, n; face_value = face_value, pmt_type = pmt_type )
end

#### Calculate the dirty price ####
function dirty_price( r::Float64, coupon_rate::Float64, n; face_value = 100.0, frac = 0.0 )
  validate_frac( frac )
  dp = 0.0
  coupon = face_value*coupon_rate/2
  for i = 1:n
    cf_period = i < n? coupon: coupon + face_value
    n_adj = i - frac
    dp += pv_simple( r = r, n = n_adj, fv = cf_period  )
  end
  return dp
end

function dirty_price( ; r = nothing, n = nothing, coupon_rate = nothing, face_value = 100.0, frac = 0.0 )
    validate_kwargs( r, coupon_rate, n, face_value, frac )
    dirty_price( r, coupon_rate, n; face_value = face_value, frac = frac )
end

#### Calculate the clean price ####
function clean_price( r::Float64, coupon_rate::Float64, n; face_value = 100.0, frac = 0.0 )
  validate_frac( frac )
  dp = dirty_price( r, coupon_rate, n; face_value = face_value, frac = frac )
  coupon = face_value*coupon_rate/2
  accrued_int = coupon*frac
  return dp + accrued_int
end

function clean_price( ; r = nothing, n = nothing, coupon_rate = nothing, face_value = 100.0, frac = 0.0 )
    validate_kwargs( r, coupon_rate, n, face_value, frac )
    clean_price( r, coupon_rate, n; face_value = face_value, frac = frac )
end

#### Calculate the linear approx. of the change in price from change in ytm ####
function pch_from_ytm( duration::Float64, r0::Float64, r1::Float64 )
  m_r0 = 1 + r0
  m_r1 = 1 + r1
  return -duration*( m_r1-m_r0 )/m_r0
end

function pch_from_ytm( ; duration = nothing, r0 = nothing, r1 = nothing )
    validate_kwargs( duration, r0, r1 )
    return pch_from_ytm( duration, r0, r1 )
end

#### Calculate the linear approx. of the change in price from change in ytm ####
function duration_from_pch( pch::Float64, r0::Float64, r1::Float64 )
  m_r0 = 1 + r0
  m_r1 = 1 + r1
  return -pch/( ( m_r1-m_r0 )/m_r0 )
end

function duration_from_pch( ; pch = nothing, r0 = nothing, r1 = nothing )
    validate_kwargs( pch, r0, r1 )
    return duration_from_pch( pch, r0, r1 )
end

