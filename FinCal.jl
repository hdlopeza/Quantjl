module FinCal

# This code is the julia port from the R package FinCal.

# Author: Vathy M. Kamulete
# Email: vathymut@gmail.com
# Github: github.com/vathymut

export

  # methods
  ear,
  ear_continuous,
  ear2bey,
  ear2hpr,
  fv_simple,
  fv_annuity,
  fv,
  fv_uneven,
  pv_from_spot,
  pv_simple,
  pv_annuity,
  pv,
  pv_uneven,
  pv_perpetuity,
  fv_from_spot,
  r_continuous,
  r_norminal,
  r_norminal,
  r_perpetuity,
  r_simple,
  n_periods

# generic functions
include("ear.jl")
include("fv.jl")
include("pv.jl")
include("rates.jl")

end
