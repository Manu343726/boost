function(scope_resolve key)
  map_has("${local}" "${key}")
  ans(has_local)
  if(has_local)
    map_tryget("${local}" "${key}")
    return_ans()
  endif()

  obj_get("${this}" "${key}")
  return_ans()
endfunction()   