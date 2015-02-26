
# Check that no argument is nothing
function validate_kwargs( a... )
  msg_error = "Must provide all arguments; one default argument is nothing."
  check_nothing = [ isequal( var, nothing ) for var in a ]
  !any( check_nothing ) || error( msg_error )
end

# Check that payment type is as expected
function validate_pmt_type( pmt_type )
  msg_error = "Error: pmt_type should be 0 or 1!"
  any( [ isequal( pmt_type, val ) for val in 0:1 ] ) || error( msg_error )
end

# Check that fraction of elapsed time is as expected
function validate_frac( frac )
  msg_error = "Error: fraction must be between 0 and 1."
  zero( frac ) <= frac <= one( frac ) || error( msg_error )
end
