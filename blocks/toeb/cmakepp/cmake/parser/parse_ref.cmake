 function(parse_ref rstring)
    ref_get(${rstring})
    ans(str)
    string_take_regex(str ":[a-zA-Z0-9_-]+")
    ans(match)
    if(NOT DEFINED match)
      return()
    endif()
  #  message("match ${match}")
    ref_isvalid("${match}")
    ans(isvalid)

    if(NOT  isvalid)
      return()
    endif()



    map_tryget(${definition} matches)
    ans(matches)
    #json_print(${matches})
    map_isvalid(${matches})
    ans(ismap)

    if(NOT ismap)
      ref_get(${match})
      ans(ref_value)

      if("${matches}" MATCHES "${ref_value}")
        return_ref(match)
      endif()
      return()
    else()
      map_keys(${matches})
      ans(keys)
      foreach(key ${keys})
        map_tryget(${match} "${key}")
        ans(val)

        map_tryget(${matches} "${key}")
        ans(regex)

        if(NOT "${val}" MATCHES "${regex}")
          return()
        endif()
      endforeach()
    endif()
    ref_set(${rstring} "${str}")
    return_ref(match)
  endfunction()