
function(export_variables)
    cmake_parse_arguments(export
        ""
        "FILE"
        "VARIABLES"
        "${ARGN}"
    )

    foreach(var ${export_VARIABLES})
        set(text "${text}
\"${var}\":\"${${var}}\"")
    endforeach()

    file(WRITE "${export_FILE}" "${text}")
endfunction()

function(import_variables)
    cmake_parse_arguments(import
        ""
        "FILE"
        ""
        "${ARGN}"
    )

    file(STRINGS "${import_FILE}" lines)

    foreach(line ${lines})
        if(line MATCHES "\"(.+)\":\"(.+)\"")
            set(${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" PARENT_SCOPE)
        endif()
    endforeach()
endfunction()
