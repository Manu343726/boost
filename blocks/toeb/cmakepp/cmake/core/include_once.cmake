function(include_once file)
  get_filename_component(file "${file}" REALPATH)
  string(MD5 md5 "${file}")
  get_property(wasIncluded GLOBAL PROPERTY "include_guards.${md5}")
  if(wasIncluded)
  	return()
  endif()
  set_property(GLOBAL PROPERTY "include_guards.${md5}" true)
  include("${file}")
endfunction()