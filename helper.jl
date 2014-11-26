
# Check that no argument is nothing
# validate_kwargs( r, pmt, g, pmt_type )
function validate_kwargs( a... )
  msg_error = "Must provide all arguments; one default argument is set to nothing."
  !any( [ isequal( var, nothing ) for var in a ] ) || error( msg_error )
end

# Check that payment type is as expected
# validate_pmt_type( pmt_type )
function validate_pmt_type( pmt_type )
  msg_error = "Error: pmt_type should be 0 or 1!"
  any( [ isequal( pmt_type, val ) for val in 0:1 ] ) || error( msg_error )
end

# Check that fraction of elapsed time is as expected
# validate_frac( pmt_type )
function validate_frac( frac )
  msg_error = "Error: frac must be between 0 and 1."
  zero( frac ) <= frac <= one( frac ) || error( msg_error )
end
