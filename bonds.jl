# This code is the julia port from the R package FinCal.

# Author: Vathy M. Kamulete
# Email: vathymut@gmail.com
# Github: github.com/vathymut

# Input
## r = stated annual rate
## bey = bond equivalent yield
## ear = effective annual rate

# Usage
## Call the methods directly
### ear2bey( 0.12 )
### bey2ear( 0.04 )

include("pricing.jl")

#### bond-equivalent yield (BEY), 2 x the semiannual discount rate ####
function ear2bey( ear::Float64 )
  return ( ( 1.0 + ear )^0.5 - 1.0 )*2.0
end

function ear2bey( ; ear = nothing )
    if ear == nothing
        error("Must provide all arguments")
    end
    ear2bey( ear )
end

#### yield to maturity, from the bond-equivalent yield (BEY)
function bey2ear( bey::Float64 )
  return ( 1.0 + bey/2 )^2 - 1.0
end

function bey2ear( ; bey = nothing )
    if bey == nothing
        error("Must provide all arguments")
    end
    bey2ear( bey )
end

#### Compute yield to maturity ####
function ytm( face_value, price, coupon_rate::Float64, n::Int )
  coupon = face_value*coupon_rate/2
  return discount_rate( n = n, price = price, fv = face_value, pmt = coupon; pmt_type = 0 )
end

function ytm( ; face_value = nothing, price = nothing, n = nothing, coupon_rate = nothing )
    if face_value == nothing || n == nothing || coupon_rate == nothing
        error("Must provide all arguments")
    end
    ytm( face_value, price, coupon_rate, n )
end
