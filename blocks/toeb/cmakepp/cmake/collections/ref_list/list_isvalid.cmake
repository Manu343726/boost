# returns true if res is a vlaid reference and its type is 'list'
function(list_isvalid  ref )
	ref_isvalid("${ref}" )
	ans(isref)
	if(NOT isref)
		return(false)
	endif()
	ref_gettype("${ref}")
  ans(type)
	if(NOT "${type}" STREQUAL "list")
		return(false)
	endif()
	return(true)
endfunction()