get_filename_component(boost_install_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)

include(${boost_install_dir}/utils.cmake)

set(BOOST_BINARY_COMPONENTS
	chrono
    context
    coroutine
    date_time
    filesystem
    graph_parallel
    iostreams
    locale
    mpi
    program_options
    python
    regex
    serialization
    signals
    system
    thread
    timer
    wave
)

set(chrono_DEPENDENCIES          system                      )
set(context_DEPENDENCIES         system chrono thread        )
set(coroutine_DEPENDENCIES       system chrono thread context)
set(date_time_DEPENDENCIES                                   )
set(filesystem_DEPENDENCIES      system                      )
set(graph_parallel_DEPENDENCIES                              )
set(iostreams_DEPENDENCIES                                   )
set(locale_DEPENDENCIES          system                      )
set(mpi_DEPENDENCIES                                         )
set(program_options_DEPENDENCIES                             )
set(python_DEPENDENCIES                                      )
set(regex_DEPENDENCIES                                       )
set(serialization_DEPENDENCIES                               )
set(signals_DEPENDENCIES                                     )
set(system_DEPENDENCIES                                      )
set(thread_DEPENDENCIES          system chrono               )
set(timer_DEPENDENCIES           chrono                      )
set(wave_DEPENDENCIES            system thread               )


function(is_binary_dependency dependency result)
    list(FIND BOOST_BINARY_COMPONENTS ${dependency} index)

    if(index GREATER -1)
        set(${result} TRUE PARENT_SCOPE)
    else()
        set(${result} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(find_dependencies component deps)
    if(WIN32)
        windows_path("${BOOST_ROOT}" root)

        execute_process(
            COMMAND ${boost_install_dir}/bcp.bat "${root}" ${component}
            WORKING_DIRECTORY \"${BII_BOOST_DIR}\"
            OUTPUT_VARIABLE stdout ERROR_VARIABLE stderr
            RESULT_VARIABLE result
        )
    else()
        execute_process(
            COMMAND cmd ${BII_BOOST_B2} --boost="${BOOST_ROOT}" --list ${component}
            WORKING_DIRECTORY \"${BII_BOOST_DIR}\"
            OUTPUT_VARIABLE stdout ERROR_VARIABLE stderr
            RESULT_VARIABLE result
        )
    endif()

    if(result EQUAL 0)
        string(REGEX REPLACE "\n" ";" stdout "${stdout}")

        if(WIN32)
            set(regex "^boost\\\\(.+)\\\\.*")
            set(regex2 "\\\\.*")
        else()
            set(regex "^boost/(.+)/.*")
            set(regex2 "/.*")
        endif()

        set(finaldeps)

        foreach(line ${stdout})
            if(line MATCHES "${regex}")
                set(dep "${CMAKE_MATCH_1}")
                string(REGEX REPLACE "${regex2}" "" dep "${dep}")
                list(FIND finaldeps "${dep}" index)

                if(NOT (dep MATCHES "${component}"))
                    if(index EQUAL -1)
                        message(STATUS "${component} depends on ${dep}")
                        list(APPEND finaldeps "${dep}")
                    endif()
                endif()
            endif()
        endforeach()
    else()
        message(FATAL_ERROR "Failed calling bcp for component ${component}\n${stdout}\n${stderr}")
    endif()

    set(${deps} "${finaldeps}" PARENT_SCOPE)
endfunction()

function(solve_binary_dependencies component deps_out)
	is_binary_dependency(${component} is)

    if(is)
    	set(dependencies ${${component}_DEPENDENCIES})

        foreach(dep ${${component}_DEPENDENCIES})
        	solve_binary_dependencies(${dep} deps)

        	list(APPEND dependencies ${deps})
        endforeach()

        if(dependencies)
        	list(REMOVE_DUPLICATES dependencies)
    	endif()

        set(${deps_out} "${dependencies}" PARENT_SCOPE)
    else()
    	message(FATAL_ERROR "Boost ${component} is not a binary component")
    endif()
endfunction()