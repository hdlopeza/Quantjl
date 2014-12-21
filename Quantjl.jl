# module Quantjl

# export ear, compound_ear, ear_continuous, ear2hpr,
#   r_continuous, r_norminal, r_perpetuity, r_simple,
#   fv_simple, fv_annuity, fv, fv_uneven, fv_from_spot,
#   pv_simple, pv_annuity, pv, pv_uneven, pv_from_spot, pv_perpetuity,
#   pmt, discount_rate, n_periods, price_arbitrage, accrued_interest_intra_period,
#   ear2bey, bey2ear, ytm, dirty_price, clean_price, cf_from_bond,
#   modified_duration, macaulay_duration, bond_duration, pctchange_from_duration,
#   SpotRate, spot_rate, spot_price, DiscountFactor, discount_factor, ForwardRate,
#   forward_rate, forward_price, forward_value

include("rates.jl")
include("timevalue.jl")
include("bonds.jl")
include("termstrc.jl")
include("mbs.jl")

#### TO DO: ADD TESTS FROM BondPricingWeek*.jl to test.jl for bonds


# end
