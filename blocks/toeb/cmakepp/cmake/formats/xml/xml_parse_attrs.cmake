
  function(xml_parse_attrs xml tag attr)
    xml_parse_tags("${xml}" "${tag}")
    ans(nodes)
    set(res)
    foreach(node ${nodes})
      map_tryget(${node} attrs)
      ans(attrs)
      map_tryget("${attrs}" "${attr}")
      ans(it)
      list(APPEND res "${it}")
    endforeach()
    return_ref(res)
  endfunction()