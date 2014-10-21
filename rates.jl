# This code is the julia port from the R package FinCal.

# Author: Vathy M. Kamulete
# Email: vathymut@gmail.com
# Github: github.com/vathymut

# Input
## r = norminal rate
## m = number of compounding periods per year
## n = number of periods
## t = number of days remaining until maturity
## rc = continuous compounded rate
## pv = present value
## pmt = payment per period

# Usage
## Call the methods directly
### r_continuous( 0.03, 4 )
### r_norminal( 0.03, 1 )
### r_norminal( 0.03, 4 )
### r_perpetuity( 4.5, -75 )
### r_simple( -1, 1.2, 1 )
### n_periods( -1, 1.2, 0.2 )
### pmt( 0.08,10,-1000,10 )

include("pv.jl")
include("fv.jl")

#### Computing r, discount rate from pv, fv and n, number of periods ####
function r_simple( pv, fv, n::Int; )
  return ( -fv/pv )^( 1/n ) - 1.0
end

function r_simple( ; pv = nothing, fv = nothing, n = nothing )
    if pv == nothing || fv == nothing || n == nothing
        error("Must provide all arguments")
    end
    r_simple( pv, fv, n )
end

#### Estimate the number of periods ####
function n_periods( r::Float64, pv, fv; pmt = 0, type_pmt::Int = 0 )
  r >= zero( r ) || error( "r must be positive" )
  any( [ isequal(type_pmt, val) for val in 0:1 ] ) || error( "Error: type_pmt should be 0 or 1!" )
  n = log( -1 * (fv*r-pmt* (1+r)^type_pmt)/(pv*r+pmt* (1+r)^type_pmt) )/log( 1 + r )
  return n
end

function n_periods( ; r = nothing, pv = nothing, fv = nothing, pmt = nothing, type_pmt = nothing )
    if r == nothing || pv == nothing || fv == nothing || pmt == nothing || type_pmt == nothing
        error("Must provide all arguments")
    end
    n_periods( r, pv, fv, pmt = pmt, type_pmt = type_pmt )
end

#### Convert a given norminal rate to a continuous compounded rate ####
function r_continuous( r::Float64, m::Int )
  return m*log( 1 + r/m )
end

function r_continuous( ; r = nothing, m = nothing )
    if r == nothing || m == nothing
        error("Must provide all arguments")
    end
    r_continuous( r, m )
end

#### Convert a given continuous compounded rate to a norminal rate ####
function r_norminal( rc::Float64, m::Int )
  return m*( exp( rc/m ) - 1.0 )
end

function r_norminal( ; rc = nothing, m = nothing )
    if rc == nothing || m == nothing
        error("Must provide all arguments")
    end
    r_norminal( rc, m )
end

#### Computing the rate of return for a perpetuity ####
function r_perpetuity( pmt::Float64, pv )
  return -1.0*pmt/pv
end

function r_perpetuity( ; pmt = nothing, pv = nothing )
    if pmt == nothing || pv == nothing
        error("Must provide all arguments")
    end
    r_perpetuity( pmt, pv )
end

#' Estimate period payment
#'
#' @param r discount rate, or the interest rate at which the amount will be compounded each period
#' @param n number of periods
#' @param pv present value
#' @param fv future value
#' @param type payments occur at the end of each period (type=0); payments occur at the beginning of each period (type=1)
#' @seealso \code{\link{pv}}
#' @seealso \code{\link{fv}}
#' @seealso \code{\link{n.period}}
#' @export
#' @examples
#' pmt(0.08,10,-1000,10)
#'
#' pmt(r=0.08,n=10,pv=-1000,fv=0)
#'
#' pmt(0.08,10,-1000,10,1)
pmt <- function(r,n,pv,fv,type=0){
if(type != 0 && type !=1){
print("Error: type should be 0 or 1!")
}else{
pmt <- (pv+fv/(1+r)^n)*r/(1-1/(1+r)^n) * (-1) * (1+r)^(-1 * type)
return(pmt)
}
}
