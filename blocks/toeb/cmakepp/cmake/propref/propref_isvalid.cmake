 function(propref_isvalid propref)
    string_split_at_last(ref prop "${propref}" ".")
    ref_isvalid("${ref}")
    ans(isref)
    if(NOT isref)
      return(false)
    endif()
    obj_has("${ref}" "${prop}")
    ans(has_prop)
    if(NOT has_prop)
      return(false)

    endif()
    return(true)
  endfunction()