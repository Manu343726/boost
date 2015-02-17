# removes the specified paths if -r is passed it will also remove subdirectories
# rm([-r] [<path> ...])
# files names are qualified using pwd() see path()
function(rm)
  set(args ${ARGN})
  list_extract_flag(args -r)
  ans(recurse)
  paths("${args}")
  ans(paths)
  set(cmd)
  if(recurse)
    set(cmd REMOVE_RECURSE)
  else()
    set(cmd REMOVE)
  endif()

  file(${cmd} "${paths}")
  return()
endfunction()

