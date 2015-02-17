# returns true iff obj is ${typename}
function(obj_istype this typename)
	obj_gethierarchy(${this} )
  ans(hierarchy)
	list(FIND hierarchy ${typename} index)
	if(${index} LESS 0)
		return(false)
	endif()
		return(true)
	endif()
endfunction()