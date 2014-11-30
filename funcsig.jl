# This script is a collection of function signatures
# for the routines defined in this module.
# Think of it as something-like a header file in C/C++

# Usage
### pv_simple( 0.03, 3, 1000.0 )
### pv_simple( 0.07, 10, 100.0 )
### pv_annuity( 0.03, 12, 1000.0; pmt_type = 0 )
### pv_annuity( 0.03, 12, 1000.0; pmt_type = 1 )
### pv_annuity( 0.0425, 3, 30000.0; pmt_type = 0 )
### pv( 0.05, 20, 1000.0, 10.0; pmt_type = 1 )
### pv_uneven( 0.1, [-1000., -500., 0., 4000., 3500., 2000.] )
### pv_perpetuity( 0.1, 1000; g=0.02)
### pv_perpetuity( 0.1, 1000; pmt_type = 1 )
### pv_perpetuity( 0.1, 1000 )
### pv_from_spot( [ 0.1, 0.1, 0,1 ]; fv = -1.0 )
### fv_simple( 0.08, 10, -300.0 )
### fv_simple( 0.04, 20, -50000.0 )
### fv_annuity( 0.03, 12,-1000; pmt_type = 1 )
### fv( 0.07, 10, 1000.0, 10; pmt_type = 1 )
### fv_uneven( 0.1, [-1000., -500., 0., 4000., 3500., 2000.] )
### fv_from_spot( [ 0.1, 0.1, 0,1 ]; pv = -1.0 )
### pmt( 0.08,10,-1000,10 )
### discount_rate( 1, -95, 100, 0; pmt_type = 0 )
### n_periods( -1, 1.2, 0.2 )
### price_arbitrage( 0.03, 0.02, [ 10, 10, 10 ] )
### intra_accrint( 0.05; frac = 1.0, par = 1.0 )
