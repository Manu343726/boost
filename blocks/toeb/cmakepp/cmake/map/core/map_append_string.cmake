
function(map_append_string map key str)
   get_property(isset GLOBAL PROPERTY "${map}.${key}" SET)
  if(NOT isset)
    map_set(${map} ${key} "${str}")
    return()
  endif()
  get_property(property_val GLOBAL PROPERTY "${map}.${key}" )
  set_property(GLOBAL PROPERTY "${map}.${key}" "${property_val}${str}")

endfunction() 