function(map_extract navigation_expressions)
  cmake_parse_arguments("" "REQUIRE" "" "" ${ARGN})
  set(args ${_UNPARSED_ARGUMENTS})
  foreach(navigation_expression ${navigation_expressions})
    map_navigate(res "${navigation_expression}")
    list_pop_front( args)
    ans(current)
    if(_REQUIRE AND NOT res)
      message(FATAL_ERROR "map_extract failed: requires ${navigation_expression}")
    endif()

    if(current)
      set(${current} ${res} PARENT_SCOPE)
    else()
      if(NOT _REQUIRE)
       break()
      endif()
    endif()
  endforeach()
  foreach(arg ${args})
    set(${arg} PARENT_SCOPE)  
  endforeach()
  
endfunction()