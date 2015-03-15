# The goal is NOT to achieve 100% test coverage.
# Think of it as sanity checks.

include( "Quantjl.jl" )
using Base.Test

# NB: comparing FloatingPoint
@test_approx_eq_eps fv_simple( r = 0.06, n = 10, pv = -500. ) ( 895.4 ) 1e-1
@test_approx_eq_eps pv_simple( r = 0.03, n = 5, fv = 1e+06 ) ( -862609 ) 1e-0
@test_approx_eq_eps fv_annuity( r = 0.06, n = 25, pmt = -15000, pmt_type = 0 ) ( 822968 ) 1e-0
@test_approx_eq_eps fv_annuity( r = 0.05, n = 3, pmt = -10000, pmt_type = 1 ) ( 33101 ) 1e-0
@test_approx_eq_eps pv_annuity( r = 0.06, n = 25, pmt = -20000, pmt_type = 0) ( 255667 ) 1e-0
@test_approx_eq_eps pv_annuity( r = 0.1, n = 10, pmt = -1000, pmt_type = 1) ( 6759 ) 1e-0
@test_approx_eq_eps pv_perpetuity( r = 0.1, pmt = 2.5, g = 0.0, pmt_type = 0) (-25) 1e-0
@test_approx_eq_eps pv( r = 0.06, n = 10, fv = 1000., pmt = 70., pmt_type = 0) ( -1074 ) 1e-0
cf = Float64[-10000, -5000, 2000, 4000, 6000, 8000 ]
@test_approx_eq_eps fv_uneven( r = 0.06, cf = cf ) ( -1542 ) 1e-0
@test_approx_eq_eps pv_uneven( r = 0.1, cf = cf ) ( 747.1 ) 1e-1
spot_rates = [ 0.1, 0.1, 0.1 ]
@test_approx_eq_eps fv_from_spot( spot_rates = spot_rates, pv = -1.0 ) fv_simple( r = 0.1, n = 3, pv = -1.0 ) 1e-8
@test_approx_eq_eps pv_from_spot( spot_rates = spot_rates, fv = 1.0 ) pv_simple( r = 0.1, n = 3, fv = 1.0 ) 1e-8
@test_approx_eq_eps nominal2ear( r = 0.0425, m = 2) ( 0.04295 ) 1e-5
@test_approx_eq_eps nominal2ear( r = 0.0425, m = 4) ( 0.04318 ) 1e-5
@test_approx_eq_eps nominal2ear( r = 0.0425, m = 12) ( 0.04334 ) 1e-5
@test_approx_eq_eps nominal2ear( r = 0.0425, m = 365) ( 0.04341 ) 1e-5
@test_approx_eq_eps ear2continuous( r = 0.0425) ( 0.04342 ) 1e-5
@test_approx_eq_eps r_perpetuity( pmt = 2.5, pv = -75 ) ( 0.03333 ) 1e-5
@test_approx_eq_eps nper( r = 0.09, pv = 0, fv = 10000, pmt = -1000, pmt_type = 0) ( 7.448 ) 1e-3
@test_approx_eq_eps pmt( r = 0.06, n = 5, pv = 5e+05, fv = 0, pmt_type = 0 ) ( -118698 ) 1e-0
cf = Float64[ 2000, 4000, 6000, 8000 ]
@test_approx_eq_eps price_arbitrage( rborrow = 0.1, rlend = 0.05, cf = cf )[1] ( -15095.963390 ) 1e-5
@test_approx_eq_eps price_arbitrage( rborrow = 0.1, rlend = 0.05, cf = cf )[2] ( -17297.525208 ) 1e-5
@test_approx_eq_eps discount_rate( n = 5, price = 0, fv = 600., pmt = -100., pmt_type = 0) ( 0.0913 ) 1e-4
@test_approx_eq_eps ear2bey(ear = 0.06) ( 0.05913 ) 1e-5
@test_approx_eq_eps bey2ear( bey = 0.036 ) ( 0.03632 ) 1e-5
r = bey2ear( bey = 0.036 )
@test_approx_eq_eps ytm( face_value = 1000., price = -950., n = 2, coupon_rate = 0.12 ) ( 0.08836 ) 1e-5
@test_approx_eq_eps ytm( face_value = 1000., price = -1040., n = 2, coupon_rate = 0.12 ) ( 0.03883 ) 1e-5
r = 0.01939/2
@test_approx_eq_eps dirty_price( r = r, coupon_rate = 0.02, n = 20, face_value = 1000.0, frac = 0.105 ) ( -1006.54 ) 1e-2
@test_approx_eq_eps price_from_ytm( ytm = 0.04, coupon_rate = 0.12, n = 20 ) ( -1271.81 ) 1e-2
@test_approx_eq_eps irr( cf = [ -6, 2.6, 2.4, 3.8 ] ) ( 0.2033 ) 1e-4
@test cf_from_bond( face_value = 100, coupon_rate = 0.1*2, n = 3 ) == Float64[ 10, 10, 110 ]
cf0 = Float64[ 10, 10, 110 ]
b0 = pv_uneven( r = 0.09, cf = cf0 )
@test_approx_eq_eps bond_duration( r = 0.09, cf = cf0 ) ( 2.739 ) (1e-4)
@test_approx_eq_eps irr( cf = [ -6, 2.6, 2.4, 3.8 ] ) ( 0.2033 ) 1e-4

# MBS tests
r = 0.08125/12
pt_rate = 0.075/12
n = 360 - 3
face_value = 400.0
pmt0 = pmt( r = r, n = n, pv = face_value, fv = 0, pmt_type = 0 )
@test_approx_eq_eps ( pmt0 ) ( -2.976 ) ( 1e-3 )
cpr0 = mbs_cpr_psa( psa_maxrate = 0.06, psa_speed = 100.0, psa_threshold = 30, n = 360, seasoning = 3 )
@test_approx_eq_eps ( cpr0[1] ) ( 0.008 ) ( 1e-3 )
@test_approx_eq_eps ( cpr0[14] ) ( 0.034 ) ( 1e-3 )
@test_approx_eq_eps ( cpr0[end] ) ( 0.06 ) ( 1e-3 )
smm0 = mbs_cpr2smm( cpr0 )
@test_approx_eq_eps ( smm0[1] ) ( 0.0007 ) ( 1e-3 )
@test_approx_eq_eps ( smm0[14] ) ( 0.0029 ) ( 1e-3 )
@test_approx_eq_eps ( smm0[end] ) ( 0.0051 ) ( 1e-3 )
intp0 = mbs_interest_payment( balance = face_value , wac = r )
@test_approx_eq_eps ( intp0 ) ( 2.71 ) ( 1e-2 )
pp0 = mbs_principal_payment( pmt = pmt0, balance = face_value, wac = r )
@test_approx_eq_eps ( pp0 ) ( 0.267 ) ( 1e-3 )
pr0 = mbs_prepayment( balance = face_value, pmt = pmt0, smm = smm0[1] )
@test_approx_eq_eps ( pr0 ) ( 0.267 ) ( 1e-2 ) # Excel roundoff error? should be accurate to 1e-3
b1 = mbs_remaining_balance( balance = face_value, wac = r, pmt = pmt0; smm = smm0[1] )
@test_approx_eq_eps ( b1 ) ( 399.46 ) ( 1e-2 )
mbscf = mbs_cf( r = r, n = n, face_value = face_value, wac = r, passthrough_rate = pt_rate, smm = smm0 )
@test_approx_eq_eps ( mbscf.balance_remaining[1] ) ( 400.0 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.balance_remaining[2] ) ( 399.46 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.balance_remaining[end] ) ( 0.50 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.prepayment_amt[1] ) ( 0.267 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.prepayment_amt[2] ) ( 0.334 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.prepayment_amt[end-1] ) ( 0.003 ) ( 1e-3 )
@test_approx_eq_eps ( mbscf.prepayment_amt[end] ) ( 0.00 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.principal_pmnt[1] ) ( 0.268 ) ( 1e-3 )
@test_approx_eq_eps ( mbscf.principal_pmnt[2] ) ( 0.269 ) ( 1e-3 )
@test_approx_eq_eps ( mbscf.principal_pmnt[end-1] ) ( 0.50 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.principal_pmnt[end] ) ( 0.50 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.mtg_pmnt[1] ) ( -2.976 ) ( 1e-3 )
@test_approx_eq_eps ( mbscf.mtg_pmnt[2] ) ( -2.974 ) ( 1e-3 )
@test_approx_eq_eps ( mbscf.mtg_pmnt[end-1] ) ( -0.507 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.mtg_pmnt[end] ) ( -0.505 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.interest_pmnt[1] ) ( 2.71 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.interest_pmnt[2] ) ( 2.70 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.interest_pmnt[end-1] ) ( 0.01 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.interest_pmnt[end] ) ( 0.00 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.passthrough_interest_pmnt[1] ) ( 2.50 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.passthrough_interest_pmnt[2] ) ( 2.50 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.passthrough_interest_pmnt[end-1] ) ( 0.01 ) ( 1e-2 )
@test_approx_eq_eps ( mbscf.passthrough_interest_pmnt[end] ) ( 0.00 ) ( 1e-2 )

# R tests from FinCal
# npv( r = 0.08, cf = c(-6, 2.6, 2.4, 3.8) ) ( 1.482 )
# hpr(ev = 4, bv = 3, cfr = 0.5) ( 0.5 )
# twrr( ev = c(12, 26), bv = c(10, 24), cfr = c(1, 2) ) ( 0.2315 )
# bdy(d = 150, f = 10000, t = 120) ( 0.045 )
# hpr2ear(hpr = 0.0285, t = 120) ( 0.08923 )
# bdy2mmy(bdy = 0.045, t = 120) ( 0.04569 )
# hpr(ev = 10000, bv = 9800) ( 0.02041 )
# mmy2hpr(mmy = 0.04898, t = 150) ( 0.02041 )
# hpr2ear(hpr = mmy2hpr(mmy = 0.04898, t = 150), t = 150) ( 0.05039 )
# ear2hpr(ear = hpr2ear(hpr = mmy2hpr(mmy = 0.04898, t = 150), t = 150), t = 150) ( 0.02041 )
# hpr2bey(hpr = 0.04, t = 3) ( 0.1632 )
# rs = c(0.09, 0.06, 0.01)
# ws = c(0.4, 0.5, 0.1)
# wpr(r = rs, w = ws) ( 0.067 )
# geometric.mean(r = c(-0.05, 0.11, 0.09)) ( 0.04751 )
# harmonic.mean(p = c(4.5, 5.2, 4.8)) ( 4.816 )
