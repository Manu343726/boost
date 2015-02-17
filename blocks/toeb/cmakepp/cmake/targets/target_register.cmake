# registers the target globally
# the name of the target is added to targets
#  or target_list()
function(target_register target_name)
  map_new()
  ans(target_map)
  map_set(global target_map ${target_map})
  function(target_register target_name)
    map_new()
    ans(tgt)
    map_set(${tgt} name "${target_name}")
    map_set(${tgt} project_name ${project_name})
    map_append(global targets ${tgt})
    map_append(global target_names ${target_name}) 
    map_get(global target_map)
    ans(target_map)
    map_set(${target_map} ${target_name} ${tgt}) 
    project_object()
    ans(proj)
    if(proj)
      map_append(${proj} targets ${tgt})
    endif()
    return_ref(tgt)
  endfunction()
  target_register(${target_name} ${ARGN})
  return_ans()
endfunction()



