function(list_values ref)
	list_isvalid( ${ref})
  ans(islist)
	if(NOT islist)
		return_value()
	endif()
	ref_get(${ref} )
  ans(values)
  return_ref(values)
endfunction()