#decodes parentheses in a string
function(string_parentheses_encode str)
  string(REPLACE "†" "\(" str "${str}")
  string(REPLACE "‡" "\)" str "${str}")
  return_ref(str)
endfunction()
