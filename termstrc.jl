# Input
## face_value = face value of bond
## price = present value of cash flow (market price of bond)
## t = time subscript for nth payment (t=1 is the first payment)

# Usage
## Call the methods directly
### SpotRate( 0.05, 5 )
### spot_rate( 1000, -995, 0.02 )
### DiscountFactor( 0.95, 1 )
### discount_factor( 0.1, 5 )
### ForwardRate( 0.05, 1, 2 )
### forward_rate( SpotRate( 0.05, 5 ), SpotRate( 0.045, 6 ) )

#### Create Spot Rate type ####
type SpotRate
  rate::Real
  t::Int

  function SpotRate( rate::Real, t::Int )
    zero(rate) <= rate <= one(rate) || error( "spot_rate must be between 0 and 1." )
    zero(t) <= t || error( "time subscript must be greater or equal 0" )
    new( rate, t )
  end
end

#### Calculate the spot rate ####
include("pricing.jl")
function spot_rate( face_value, price, t )
  r = discount_rate( n = t, price = price, face_value = face_value, pmt = 0; pmt_type = 0 )
  return SpotRate( r, t )
end

function spot_rate( ; face_value = nothing, price = nothing, t = nothing )
    if face_value == nothing || price == nothing || t == nothing
        error("Must provide all arguments")
    end
    spot_rate( face_value, price, t )
end

#### Create Discount Factor type ####
type DiscountFactor
  discount::Real
  t::Int

  function DiscountFactor( discount::Real, t::Int )
    zero(discount) <= discount <= one(discount) || error( "discount factor must be between 0 and 1." )
    zero(t) <= t || error( "time subscript must be greater or equal 0" )
    new( discount, t )
  end
end

#### Calcuate the discount factor ####
function discount_factor( s::SpotRate )
  d = 1/( 1 + s.rate )^s.t
  return DiscountFactor( d, s.t )
end

function discount_factor( ; s = nothing )
    if s == nothing
        error("Must provide all arguments")
    end
    discount_factor( s )
end

#### Create Forward Rate type ####
type ForwardRate
  rate::Real
  t1
  t2

  function ForwardRate{ T<:Real }( rate::Real, t1::T, t2::T )
    zero(rate) <= rate <= one(rate) || error( "forward rate must be between 0 and 1." )
    t1 < t2 || error( "starting period must be stricly lower than ending period" )
    one( t1 ) <= t1 || error( "starting period must be greater or equal than one" )
    new( rate, t1, t2 )
  end
end

#### Calcuate the forward rate ####
function forward_rate( s1::SpotRate, s2::SpotRate )
  t1, t2 = s1.t, s2.t
  n = ( 1 + s2.rate )^t2
  d = ( 1 + s1.rate )^t1
  f = ( n/d )^( 1/(t2 - t1) ) - 1
  return ForwardRate( f, t1, t2 )
end

function forward_rate( ; s1 = nothing, s2 = nothing )
    if s1 == nothing || s2 == nothing
        error("Must provide all arguments")
    end
    forward_rate( s1, s2 )
end

#### Calcuate the forward price ####
function forward_price( spot_price, discount )
  zero(discount) <= discount <= one(discount) || error( "discount factor must be between 0 and 1." )
  return spot_price/discount
end

function forward_price( ; spot_price = nothing, discount = nothing )
    if spot_price == nothing || discount == nothing
        error("Must provide all arguments")
    end
    forward_price( spot_price, discount )
end

#### Calcuate the spot price ####
function spot_price( forward_price, discount )
  zero(discount) <= discount <= one(discount) || error( "discount factor must be between 0 and 1." )
  return discount*forward_price
end

function spot_price( ; forward_price = nothing, discount = nothing )
    if spot_price == nothing || discount == nothing
        error("Must provide all arguments")
    end
    spot_price( spot_price, forward_price )
end

#### Calcuate the forward value ####
function forward_value( F0, F1, discount )
  zero(discount) <= discount <= one(discount) || error( "discount factor must be between 0 and 1." )
  return (F1-F0)*discount
end

function forward_value( ; F0 = nothing, discount = nothing )
    if F0 == nothing || F1 == nothing || discount == nothing
        error("Must provide all arguments")
    end
    forward_value( F0, F1, discount )
end
