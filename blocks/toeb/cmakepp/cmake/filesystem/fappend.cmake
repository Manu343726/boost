function(fappend path)
  path("${path}")
  ans(path)
  file(APPEND "${path}" ${ARGN})
  return()
endfunction()