# write the specified object reference to the specified file
## todo rename to fwrite_json(path data)
  function(json_write file obj)
    path("${file}")
    ans(file)
    json_indented(${obj})
    ans(data)
    file(WRITE "${file}" "${data}")
    return()
  endfunction()