# converts a decimal number to a hexadecimal string
# e.g. dec2hex(195936478) => "BADC0DE"

  function(dec2hex n)
    set(rest ${n})
    set(converted)

    if("${n}" EQUAL 0)
      return(0)
    endif()
    
    while(${rest} GREATER 0)
      math(EXPR c "${rest} % 16")
      math(EXPR rest "(${rest} - ${c})>> 4")

      if("${c}" LESS 10)
        list(APPEND converted "${c}")
      else()
        if(${c} EQUAL 10)
          list(APPEND converted A)
        elseif(${c} EQUAL 11)
          list(APPEND converted B)
        elseif(${c} EQUAL 12)
          list(APPEND converted C)
        elseif(${c} EQUAL 13)
          list(APPEND converted D)
        elseif(${c} EQUAL 14)
          list(APPEND converted E)
        elseif(${c} EQUAL 15)
          list(APPEND converted F)
        endif()
      endif()
    endwhile()
    list(LENGTH converted len)
    if(${len} LESS 2)
      return(${converted})
    endif()
    list(REVERSE converted)
    string_combine("" ${converted})
    return_ans()
  endfunction() 