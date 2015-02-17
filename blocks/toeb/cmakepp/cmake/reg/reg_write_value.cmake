
  ## sets the specified windows registry value 
  ## value may contain semicolons
  function(reg_write_value key value_name value)
    string_semicolon_encode("${value}")
    ans(value)
    string(REPLACE / \\ key "${key}")
    set(type REG_SZ)
    reg(add "${key}" /v "${value_name}" /t "${type}" /f /d "${value}" --return-code)
    ans(error)
    if(error)
      return(false)
    endif()
    return(true)
  endfunction()



