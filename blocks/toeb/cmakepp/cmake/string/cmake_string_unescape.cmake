
  function(cmake_string_unescape str)
    string(REPLACE "\\\"" "\"" str "${str}")
    string(REPLACE "\\\\" "\\" str "${str}")
    string(REPLACE "\\(" "(" str "${str}")
    string(REPLACE "\\)" ")" str "${str}")
    string(REPLACE "\\$" "$" str "${str}")
    string(REPLACE "\\#" "#" str "${str}")
    string(REPLACE "\\^" "^" str "${str}")
    string(REPLACE "\\t" "\t" str "${str}")
    string(REPLACE "\\;" ";"  str "${str}")
    string(REPLACE "\\n" "\n" str "${str}")
    string(REPLACE "\\r" "\r" str "${str}")
    string(REPLACE "\\0" "" str "${str}") ## not supported  in cmake strings
    string(REPLACE "\\ " " " str "${str}")
    return_ref(str)
  endfunction()