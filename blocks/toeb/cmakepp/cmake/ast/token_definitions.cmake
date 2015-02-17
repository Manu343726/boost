# returns the token definitions of a language 
function(token_definitions language)
  map_get(${language}  definitions)
  ans(definitions)
  map_keys(${definitions} )
  ans(keys)
  set(token_definitions)
  foreach(key ${keys})
    map_get(${definitions}  ${key})
    ans(definition)
    map_tryget(${definition}  parser)
    ans(parser)
    if("${parser}" STREQUAL "token")
      map_set(${definition} name "${key}")
      map_tryget(${definition}  regex)
      ans(regex)
      if(regex)
        map_set(${token_definition} regex "${regex}")
      else()
        map_tryget(${definition}  match)
        ans(match)
        string_regex_escape("${match}")
        ans(match)
        map_set(${definition} regex "${match}")
      endif()
      list(APPEND token_definitions ${definition})
    endif()
  endforeach()
  return_ref(token_definitions)
endfunction()