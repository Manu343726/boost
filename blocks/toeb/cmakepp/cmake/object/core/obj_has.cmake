
  function(obj_has obj key)
    map_get_special("${obj}" has)
    ans(has)
    if(NOT has)
      obj_default_has_member("${obj}" "${key}")
      return_ans()
    endif()
    set_ans("")
    eval("${has}(\"\${obj}\" \"\${key}\")")
    return_ans()
  endfunction()
