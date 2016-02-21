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

function(boost_target component)
    if(TARGET Boost_${component}_TARGET)
        return()
    else()
        message(STATUS "Generating Boost ${component} target...")
    endif()

    solve_binary_dependencies(${component} deps)
    set(target Boost_${component}_TARGET)

    foreach(dep ${deps})
        boost_target(${dep})
        list(APPEND deps_targets boost_${dep}_TARGET)
    endforeach()

    set(Boost_FIND_QUIETLY ON)
    find_package(Boost)

    if(WIN32)
        if(Boost_USE_STATIC_LIBS)
            set(lib_suffix .s)
        else()
            set(lib_suffix .dll)
        endif()
    else()
        set(lib_prefix lib)

        if(Boost_USE_STATIC_LIBS)
            set(lib_suffix .a)
        else()
            set(lib_suffix .so)
        endif()
    endif()

    set(release_lib "${lib_prefix}${Boost_LIB_PREFIX}${Boost_NAMESPACE}_${component}${_boost_COMPILER}${_boost_MULTITHREADED}${_boost_RELEASE_ABI_TAG}-${Boost_LIB_VERSION}${lib_suffix}")
    set(debug_lib   "${lib_prefix}${Boost_LIB_PREFIX}${Boost_NAMESPACE}_${component}${_boost_COMPILER}${_boost_MULTITHREADED}${_boost_DEBUG_ABI_TAG}-${Boost_LIB_VERSION}${lib_suffix}")
    set(release_lib "${BOOST_ROOT}/stage/lib/${release_lib}")
    set(debug_lib   "${BOOST_ROOT}/stage/lib/${debug_lib}")

    add_library(${target}_imported IMPORTED STATIC GLOBAL)
    set_target_properties(${target}_imported PROPERTIES
        IMPORTED_LOCATION_DEBUG "${debug_lib}"
        IMPORTED_LOCATION_RELEASE "${release_lib}"
        INTERFACE_INCLUDE_DIRECTORIES ${Boost_INCLUDE_DIRS}
    )

    if(BII_BOOST_VERBOSE)
        message(STATUS "Debug lib: ${debug_lib}")
        message(STATUS "Release lib: ${release_lib}")
    endif()

    add_library(${target} INTERFACE)

    target_link_libraries(${target} INTERFACE
        ${target}_imported
    )

    if((NOT (EXISTS "${debug_lib}")) OR (NOT (EXISTS "${release_lib}")))
        add_custom_target(boost_${component}_build_job)
        add_dependencies(${target} boost_${component}_build_job)

        set(jobs_binary_dir "${CMAKE_BINARY_DIR}/boost_build_jobs")

        if(NOT (EXISTS jobs_binary_dir))
            file(MAKE_DIRECTORY "${jobs_binary_dir}")
        endif()

        add_custom_command(
            TARGET boost_${component}_build_job POST_BUILD
            COMMAND ${CMAKE_COMMAND} \"${boost_install_dir}/cli\"
                -DCMAKEPP_FILE=\"${CMAKEPP_FILE}\"
                -DBII_BOOST_CLI_COMPONENT=\"${component}\"
                -DBII_BOOST_CLI_LIB_DEBUG=\"${debug_lib}\"
                -DBII_BOOST_CLI_LIB_RELEASE=\"${release_lib}\"
                -Wno-dev
            WORKING_DIRECTORY "${jobs_binary_dir}"
            COMMENT "Building Boost ${component}..."
        )
    endif()

    foreach(dep ${deps})
        target_link_libraries(${target} INTERFACE
            Boost_${dep}_TARGET
        )
    endforeach()

endfunction()

function(create_boost_targets)
    foreach(component ${BOOST_BINARY_COMPONENTS})
        boost_target(${component})
    endforeach()

    add_library(Boost_headeronly_TARGET INTERFACE)
    set_target_properties(Boost_headeronly_TARGET
        PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${Boost_INCLUDE_DIRS}
    )
endfunction()
