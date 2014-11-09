# Input
## r = stated annual rate
## bey = bond equivalent yield
## ear = effective annual rate
## face_value = face value of bond
## price = present value of cash flow (market price of bond)

# Usage
## Call the methods directly
### ear2bey( 0.12 )
### bey2ear( 0.04 )
### ytm( 100.0, -95.0, 0.05, 1 )
### dirty_price( 0.05, 10, 20; face_value = 100.0, frac = 0.0 )
### clean_price( 0.05, 10, 20; face_value = 100.0, frac = 0.0 )

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

#### Calculate the dirty price ####
function dirty_price( r::Float64, coupon_rate::Float64, n; face_value::Float64 = 100.0, frac::Float64 = 0.0 )
  zero(frac) <= frac <= one(frac) || error( "frac must be between 0 and 1." )
  dp = 0.0
  coupon = face_value*coupon_rate/2
  for i = 1:n
    cf_period = i < n? coupon: coupon + face_value
    n_adj = i - frac
    dp += pv_simple( r = r, n = n_adj, fv = cf_period  )
  end
  return dp
end

function dirty_price( ; r = nothing, n = nothing, coupon_rate = nothing, face_value = nothing, frac = nothing )
    validate_kwargs( r, coupon_rate, n, face_value, frac )
    dirty_price( r, coupon_rate, n; face_value = face_value, frac = frac )
end

#### Calculate the clean price ####
function clean_price( r::Float64, coupon_rate::Float64, n; face_value::Float64 = 100.0, frac::Float64 = 0.0 )
  zero(frac) <= frac <= one(frac) || error( "frac must be between 0 and 1." )
  @show dp = dirty_price( r, coupon_rate, n; face_value = face_value, frac = frac )
  coupon = face_value*coupon_rate/2
  @show accrued_int = coupon*frac
  return dp + accrued_int
end

function clean_price( ; r = nothing, n = nothing, coupon_rate = nothing, face_value = nothing, frac = nothing )
    validate_kwargs( r, coupon_rate, n, face_value, frac )
    clean_price( r, coupon_rate, n; face_value = face_value, frac = frac )
end

