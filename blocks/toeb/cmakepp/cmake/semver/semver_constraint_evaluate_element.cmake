
function(semver_constraint_evaluate_element constraint version)
  string(STRIP "${constraint}" constraint)
  set(constraint_operator_regexp "^(\\<|\\>|\\~|=|!)")
  set(constraint_regexp "${constraint_operator_regexp}?(.+)$")
  string(REGEX MATCH "${constraint_regexp}" match "${constraint}")
  if(NOT match )
    return_value(false)
  endif()
  set(operator)
  set(argument)

  string(REGEX MATCH "${constraint_operator_regexp}" has_operator "${constraint}")
  if(has_operator)
    string(REGEX REPLACE "${constraint_regexp}" "\\1" operator "${constraint}")
    string(REGEX REPLACE "${constraint_regexp}" "\\2" argument "${constraint}")      
  else()
    set(operator "=")
    set(argument "${constraint}")
  endif()

  # check for equality
  if(${operator} STREQUAL "=")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" EQUAL "0")
      return(true)
    endif()
    return(false)
  endif()

  # check if version is greater than constraint
  if(${operator} STREQUAL ">")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" LESS 0)
      return(true)
    endif()
    return(false)
  endif()

  # cheick  if version is less than constraint
  if(${operator} STREQUAL "<")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" GREATER 0)
      return(true)
    endif()
    return(false)
  endif()

  if(${operator} STREQUAL "!")
    semver_normalize("${argument}")    
    semver_format("${argument}")
    ans(argument)
    semver_compare( "${version}" "${argument}")
    ans(cmp)
    if("${cmp}" EQUAL "0")
      return(false)
    endif()
    return(true)

  endif()

  #check if version about equal to constraint
  if(${operator} STREQUAL "~")
    string(REGEX REPLACE "(.*)([0-9]+)" "\\2" upper "${argument}")
    math(EXPR upper "${upper} + 1" )
    string(REGEX REPLACE "(.*)([0-9]+)" "\\1${upper}" upper "${argument}")
    string(REGEX REPLACE "(.*)([0-9]+)" "\\1\\2" lower "${argument}")
    
    semver_constraint_evaluate_element( ">${lower}" "${version}")
    ans(lower_ok_gt)
    semver_constraint_evaluate_element( "=${lower}" "${version}")
    ans(lower_ok_eq)
    semver_constraint_evaluate_element( "<${upper}" "${version}")
    ans(upper_ok)

    if((lower_ok_gt OR lower_ok_eq) AND upper_ok)
      return(true)
    endif()
    return(false)
  endif()
  return(false)
endfunction()