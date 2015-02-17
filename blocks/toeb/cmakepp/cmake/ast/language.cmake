function(language name)
  map_new()
  ans(language_map)
  ref_set(language_map "${language_map}")


function(language name)
  ## get cached language
  ref_get(language_map)
  ans(language_map)

  map_isvalid("${name}")
  ans(ismp)
  if(ismp)
    map_tryget(${name}  initialized)
    ans(initialized)
    if(NOT initialized)
      language_initialize(${name})
    endif()
    map_tryget(${name} name)
    ans(lang_name)
    map_tryget(${language_map} ${lang_name})
    ans(existing_lang)
    if(NOT existing_lang)
      map_set(${language_map} ${lang_name} ${name})
    endif()
    return_ref(name)
  endif()

  map_tryget(${language_map}  "${name}")
  ans(language)


  if(NOT language)
    language_load(${name})
    ans(language)

    if(NOT language)
      return()
    endif()
    map_set(${language_map} "${name}" ${language})
    
    map_get(${language}  name)
    ans(name)
    map_set(${language_map} "${name}" ${language})
    set_ans("")
    eval("function(eval_${name} str)
    language(\"${name}\")
    ans(lang)
    ast(\"\${str}\" \"${name}\" \"\")
    ans(ast)
    map_new()
    ans(context)
      #message(\"evaling '\${ast}' with lang '\${lang}' context is \${context} \")
    ast_eval(\${ast} \${context} \${lang})
    ans(res)
    return_ref(res)
    endfunction()")
  endif()
  return_ref(language)
endfunction()

language("${name}" ${ARGN})
return_ans()

endfunction()