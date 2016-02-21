get_filename_component(boost_install_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)

include(${boost_install_dir}/utils.cmake)
include(${boost_install_dir}/build_jobs.cmake)
include(${boost_install_dir}/dependencies.cmake)
include(${boost_install_dir}/export_variables.cmake)
include(CMakeParseArguments)

set(SCOPE PARENT_SCOPE)

function(__BII_BOOST_PRINT_SETUP)
    message(STATUS "Boost version: ${BII_BOOST_VERSION}")
    message(STATUS "Libraries: ${BII_BOOST_LIBS}")
    message(STATUS "Upstream URL: ${BII_BOOST_DOWNLOAD_URL}")
    message(STATUS "Package: ${BII_BOOST_PACKAGE}")
    message(STATUS "Path to package: ${BII_BOOST_PACKAGE_PATH}")
    message(STATUS "Boost directory: ${BII_BOOST_DIR}")
    message(STATUS "Toolset: ${BII_BOOST_TOOLSET}")
    message(STATUS "Bootstrapper: ${__BII_BOOST_BOOSTRAPER}")

    if(Boost_USE_STATIC_LIBS)
        message(STATUS "Boost linking: STATIC")
    else()
        message(STATUS "Boost linking: DYNAMIC")
    endif()
endfunction()

function(__BII_BOOST_DOWNLOAD)
    if(NOT (EXISTS ${BII_BOOST_PACKAGE_PATH}))
        message(STATUS "Downloading Boost ${BII_BOOST_VERSION} from ${BII_BOOST_DOWNLOAD_URL}...")

        file(DOWNLOAD "${BII_BOOST_DOWNLOAD_URL}" "${BII_BOOST_PACKAGE_PATH}" SHOW_PROGRESS STATUS RESULT)
    else()
        if(BII_BOOST_VERBOSE)
            message(STATUS "Download aborted. ${BII_BOOST_PACKAGE} was downloaded previously")
        endif()
    endif()


    if(NOT (EXISTS ${BII_BOOST_DIR}))
        message(STATUS "Extracting Boost ${BII_BOOST_VERSION}...")

        if(BII_BOOST_VERBOSE)
            message(STATUS ">>>> Source: ${BII_BOOST_PACKAGE}")
            message(STATUS ">>>> From: ${BII_BOOST_PACKAGE_PATH}")
            message(STATUS ">>>> To: ${BII_BOOST_EXTRACT_DIR}")
            message(STATUS ">>>> Install dir: ${BII_BOOST_DIR}")
        endif()

        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf "${BII_BOOST_PACKAGE_PATH}" WORKING_DIRECTORY ${__BII_BOOST_TMPDIR})

        file(RENAME "${BII_BOOST_EXTRACT_DIR}" "${BII_BOOST_INSTALL_DIR}")
    endif()
endfunction()

function(__BII_BOOST_BOOTSTRAP)
    if((NOT (EXISTS ${__BII_BOOST_B2})) OR (${BII_BOOST_BOOTSTRAP_FORCE}))
        message(STATUS "Bootstrapping Boost ${BII_BOOST_VERSION}...")

        execute_process(COMMAND ${__BII_BOOST_BOOTSTRAP_CALL} WORKING_DIRECTORY ${BII_BOOST_DIR}
                        RESULT_VARIABLE Result OUTPUT_VARIABLE Output ERROR_VARIABLE Error)
        if(NOT (Result EQUAL 0))
            message(FATAL_ERROR "Failed running ${__BII_BOOST_BOOTSTRAP_CALL}:\n${Output}\n${Error}\n")
        else()
            if(__BII_BOOST_VERBOSE)
                message("Bootstrap output: ${Output}")
            endif()

            execute_process(
                COMMAND ${__BII_BOOST_B2} tools/bcp
                WORKING_DIRECTORY ${BII_BOOST_DIR}
            )
        endif()
    else()
        if(__BII_BOOST_VERBOSE)
            message(STATUS "Boost bootstrapping aborted! b2 file already exists. Set BII_BOOST_BOOTSTRAP_FORCE to override")
        endif()
    endif()
endfunction()

function(__BII_BOOST_BUILD)
    if(BII_BOOST_LIBS)
        message(STATUS "Building Boost ${BII_BOOST_VERSION} components with toolset ${BII_BOOST_TOOLSET}...")

        BII_BOOST_BUILD_LIBS_PARALLEL("${BII_BOOST_LIBS}" "${__BII_BOOST_B2_CALL}" "${BII_BOOST_VERBOSE}" "${BII_BOOST_DIR}")
    endif()
endfunction()

function(__BII_BOOST_INSTALL)
    message(STATUS "Setting up biicode Boost configuration...")

#########################################################################################################
#                                    SETUP                                                              #
#########################################################################################################

    #Version
    set(__BII_BOOST_VERSION_DEFAULT 1.60.0)

    if(DEFINED BII_BOOST_GLOBAL_OVERRIDE_VERSION)
        set(BII_BOOST_VERSION ${BII_BOOST_GLOBAL_OVERRIDE_VERSION} ${SCOPE})
    endif()

    if(NOT GLOBAL_3RDPARTY_DIR)
        if(WIN32)
            set(GLOBAL_3RDPARTY_DIR C:/CMakeGlobal3rdParty)
        else()
            set(GLOBAL_3RDPARTY_DIR $ENV{HOME}/CMakeGlobal3rdParty)
        endif()
    endif()

    if(NOT (EXISTS GLOBAL_3RDPARTY_DIR))
        file(MAKE_DIRECTORY "${GLOBAL_3RDPARTY_DIR}")
    endif()

    if(NOT (BII_BOOST_VERSION))
        if(BII_BOOST_VERBOSE)
            message(STATUS "BII_BOOST_VERSION not specified. Using Boost ${__BII_BOOST_VERSION_DEFAULT}")
        endif()

        set(BII_BOOST_VERSION ${__BII_BOOST_VERSION_DEFAULT} ${SCOPE})
    endif()

    string(REGEX REPLACE  "[.]" "_" __BII_BOOST_VERSION_LABEL ${BII_BOOST_VERSION})

    #Directories
    set(BII_BOOST_INSTALL_DIR ${GLOBAL_3RDPARTY_DIR}/boost/${BII_BOOST_VERSION}        ${SCOPE})
    set(BII_BOOST_DIR         ${BII_BOOST_INSTALL_DIR}                                 ${SCOPE})
    set(__BII_BOOST_TMPDIR    ${GLOBAL_3RDPARTY_DIR}/tmp/boost/${BII_BOOST_VERSION}    ${SCOPE})
    set(BII_BOOST_EXTRACT_DIR ${__BII_BOOST_TMPDIR}/boost_${__BII_BOOST_VERSION_LABEL} ${SCOPE})

    if(NOT (EXISTS __BII_BOOST_TMPDIR))
        file(MAKE_DIRECTORY "${__BII_BOOST_TMPDIR}")
    endif()

    if(NOT (EXISTS ${GLOBAL_3RDPARTY_DIR}/boost/))
        file(MAKE_DIRECTORY "${GLOBAL_3RDPARTY_DIR}/boost/")
    endif()


    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(__BII_BOOST_PACKAGE_TYPE zip)
    else()
        set(__BII_BOOST_PACKAGE_TYPE tar.gz)
    endif()

    #Download
    set(BII_BOOST_PACKAGE boost_${__BII_BOOST_VERSION_LABEL}.${__BII_BOOST_PACKAGE_TYPE}                                     ${SCOPE})
    set(BII_BOOST_PACKAGE_PATH ${__BII_BOOST_TMPDIR}/${BII_BOOST_PACKAGE}                                                    ${SCOPE})
    set(BII_BOOST_DOWNLOAD_URL "http://sourceforge.net/projects/boost/files/boost/${BII_BOOST_VERSION}/${BII_BOOST_PACKAGE}" ${SCOPE})

    #Bootstrap
    if((CMAKE_SYSTEM_NAME MATCHES "Windows") AND (NOT CMAKE_CROSSCOMPILING))
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.bat    ${SCOPE})
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2.exe           ${SCOPE})
        set(__BII_BOOST_BCP        ${BII_BOOST_DIR}/dist/bin/bcp.exe ${SCOPE})
    else()
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh ${SCOPE})
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2           ${SCOPE})
        set(__BII_BOOST_BCP        ${BII_BOOST_DIR}/dist/bin/bcp ${SCOPE})
    endif()

    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(__DYNLIB_EXTENSION     .dll   ${SCOPE})
    elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(__DYNLIB_EXTENSION     .dylib ${SCOPE})
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(__DYNLIB_EXTENSION     .so    ${SCOPE})
    else()
        message(FATAL_ERROR "Unknown platform. Stopping Boost installation")
    endif()

    set(__BII_BOOST_BOOTSTRAP_CALL ${__BII_BOOST_BOOSTRAPER} --prefix=${BII_BOOST_DIR} ${SCOPE})

    #Build
    if(NOT (BII_BOOST_TOOLSET))
        if(BII_BOOST_VERBOSE)
            message(STATUS "BII_BOOST_TOOLSET not specified. Using ${CMAKE_CXX_COMPILER_ID} compiler")
        endif()

        BII_BOOST_COMPUTE_TOOLSET(__BII_BOOST_DEFAULT_TOOLSET)

        set(BII_BOOST_TOOLSET ${__BII_BOOST_DEFAULT_TOOLSET} ${SCOPE})
    endif()

    if(NOT (BII_BOOST_VARIANT))
        if(NOT CMAKE_BUILD_TYPE)
            set(CMAKE_BUILD_TYPE Release)
        endif()

        if(BII_BOOST_VERBOSE)
            message(STATUS "BII_BOOST_VARIANT not specified. Using ${CMAKE_BUILD_TYPE} variant")
        endif()

        string(TOLOWER ${CMAKE_BUILD_TYPE} BII_BOOST_VARIANT)
    endif()

    if(NOT (BII_BOOST_BUILD_J))
        if(BII_BOOST_VERBOSE)
            message(STATUS "BII_BOOST_BUILD_J not specified. Parallel build disabled")
        endif()

        set(BII_BOOST_BUILD_J 1 CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build threads count")
    endif()

    set(__BII_BOOST_B2_CALL ${__BII_BOOST_B2} --includedir=${BII_BOOST_DIR}
                                              --toolset=${BII_BOOST_TOOLSET}
                                              -j${BII_BOOST_BUILD_J}
                                              --layout=versioned
                                              --build-type=complete
                            ${SCOPE})

    if((CMAKE_CXX_COMPILER_ID MATCHES "Clang") AND BII_BOOST_LIBCXX)
        if(BII_BOOST_VERBOSE)
            message(STATUS ">>>> Using LLVM libc++")
        endif()

        set(__BII_BOOST_B2_CALL ${__BII_BOOST_B2_CALL} cxxflags="-stdlib=libc++" linkflags="-stdlib=libc++" ${SCOPE})
    endif()

    set(BII_BOOST_B2 ${})

    #Boost

    #FindBoost directories
    set(BOOST_ROOT       "${BII_BOOST_DIR}"         ${SCOPE})
    set(BOOST_INCLUDEDIR "${BOOST_ROOT}"            ${SCOPE})
    set(BOOST_LIBRARYDIR "${BOOST_ROOT}/stage/lib/" ${SCOPE})


    # CMake 3.1 on windows does not search for Boost 1.57.0 by default, this is a workaround
    set(Boost_ADDITIONAL_VERSIONS ${BII_BOOST_VERSION} ${SCOPE})
    # Disable searching on system Boost
    set(Boost_NO_SYSTEM_PATHS TRUE ${SCOPE})

    #Disable auto-linking with MSVC
    if(MSVC)
        add_definitions(-DBOOST_ALL_NO_LIB)
    endif()

    if(BII_BOOST_VERBOSE)
        __BII_BOOST_PRINT_SETUP()
    endif()

#########################################################################################################
#                                       DOWNLOAD                                                        #
#########################################################################################################

    __BII_BOOST_DOWNLOAD()

#########################################################################################################
#                                       BOOTSTRAP                                                       #
#########################################################################################################

    __BII_BOOST_BOOTSTRAP()

    if(BII_FIND_BOOST_AUTOCOMPUTE_DEPS)
        message(STATUS "Computing dependencies...")

        set(components ${BII_BOOST_LIBS})
        set(BII_NOOST_LIBS)

        foreach(component ${components})
            message(STATUS "Computing dependencies of ${component}")

            solve_binary_dependencies(${component} deps)

            foreach(dep ${deps})
                message(STATUS "${component} depends on ${dep}")
            endforeach()

            list(APPEND new_components ${deps} ${component})
        endforeach()

        set(BII_BOOST_LIBS ${new_components})
        list(REMOVE_DUPLICATES BII_BOOST_LIBS)

        string(REGEX REPLACE ";" " " newcomps "${BII_BOOST_LIBS}")
        message(STATUS "Final set of Boost components: ${newcomps}")
    endif()

#########################################################################################################
#                                         BUILD                                                         #
#########################################################################################################

    __BII_BOOST_BUILD()

#########################################################################################################
#                                     FINAL SETTINGS                                                    #
#########################################################################################################

    if(BII_BOOST_LIBS)
        # FindBoost auto-compute does not care about Clang?
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            BII_BOOST_SET_CLANG_COMPILER("${BII_BOOST_DIR}" "${BII_BOOST_VERBOSE}" Boost_COMPILER)
        endif()
    endif()

    #Forward Boost variables out

    find_package(Boost ${BII_BOOST_VERSION})
    if(Boost_FOUND)
        include_directories(${BII_BOOST_DIR})

        add_definitions( "-DHAS_BOOST" )

        if(BII_BOOST_VERBOSE)
            message(STATUS "BOOST_ROOT       ${BOOST_ROOT}")
            message(STATUS "BOOST_INCLUDEDIR ${BOOST_INCLUDEDIR}")
            message(STATUS "BOOST_LIBRARYDIR ${BOOST_LIBRARYDIR}")
        endif()
    else()
        message(FATAL_ERROR "Boost not found after biicode setup!")
    endif()

    set(BII_BOOST_BCP "${__BII_BOOST_BCP}" PARENT_SCOPE)
    set(BII_BOOST_LIBS "${BII_BOOST_LIBS}" PARENT_SCOPE)

    set(BOOST_ROOT       "${BOOST_ROOT}"       PARENT_SCOPE)
    set(BOOST_INCLUDEDIR "${BOOST_INCLUDEDIR}" PARENT_SCOPE)
    set(BOOST_LIBRARYDIR "${BOOST_LIBRARYDIR}" PARENT_SCOPE)

    set(Boost_FOUND        ${Boost_FOUND}        PARENT_SCOPE)
    set(Boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS} PARENT_SCOPE)
    set(Boost_COMPILER     ${Boost_COMPILER}     PARENT_SCOPE)

    if(NOT BII_BOOST_CLI)
        getListOfVarsStartingWith(__BII BII_PRIVATE_VARS)
        export_variables(
        VARIABLES
            ${BII_PRIVATE_VARS}
        FILE
            ${CMAKE_BINARY_DIR}/boost_private_vars.cmake
        )
    endif()
endfunction()

function(BII_SETUP_BOOST)
    set(options REQUIRED STATIC DYNAMIC AUTOCOMPUTE_DEPS)
    set(oneValueArgs TOOLSET VERSION TARGET)
    set(multiValueArgs COMPONENTS)
    cmake_parse_arguments(BII_FIND_BOOST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(BII_FIND_BOOST_VERSION)
        set(BII_BOOST_VERSION ${BII_FIND_BOOST_VERSION})
    endif()

    if(BII_FIND_BOOST_TOOLSET)
        set(BII_BOOST_TOOLSET ${BII_FIND_BOOST_TOOLSET})
    endif()

    if(BII_FIND_BOOST_TARGET)
        set(BII_BOOST_FOR_TARGET ${BII_FIND_BOOST_TARGET})
        set(BII_BOOST_FOR_TARGET ${BII_BOOST_FOR_TARGET} PARENT_SCOPE)

        message("Configuring Boost for target '${BII_BOOST_FOR_TARGET}'")
    endif()

    set(BII_BOOST_LIBS ${BII_FIND_BOOST_COMPONENTS})

    if(BII_FIND_BOOST_REQUIRED)
        set(REQUIRED_FLAG "REQUIRED")
    else()
        set(REQUIRED_FLAG)
    endif()

    if(NOT (DEFINED BII_BOOST_GLOBAL_USE_STATIC_LIBS))
        if(BII_FIND_BOOST_STATIC AND BII_FIND_BOOST_DYNAMIC)
            message(FATAL_ERROR "You can't use both static and dynamic linking with Boost at the same time! Please select only one")
        elseif((NOT (DEFINED Boost_USE_STATIC_LIBS)) AND ((NOT BII_FIND_BOOST_STATIC) AND (NOT BII_FIND_BOOST_DYNAMIC)))
            message(STATUS "No linking type specified. Assuming static linking")
            set(BII_FIND_BOOST_STATIC TRUE)
        endif()

        if(NOT (DEFINED Boost_USE_STATIC_LIBS))
            #Use bii_find_boost() named parameters only if Boost_USE_STATIC_LIBS was not set previously
            if(BII_FIND_BOOST_STATIC)
                set(Boost_USE_STATIC_LIBS ON ${SCOPE})
            endif()

            if(BII_FIND_BOOST_DYNAMIC)
                set(Boost_USE_STATIC_LIBS OFF ${SCOPE})
            endif()
        endif()
    else()
        set(Boost_USE_STATIC_LIBS ${BII_BOOST_GLOBAL_USE_STATIC_LIBS} ${SCOPE})
    endif()

    __BII_BOOST_INSTALL()

    set(BII_BOOST_BCP "${BII_BOOST_BCP}" PARENT_SCOPE)
    set(BII_BOOST_LIBS "${BII_BOOST_LIBS}" PARENT_SCOPE)

    set(BII_FIND_BOOST_COMPONENTS ${BII_FIND_BOOST_COMPONENTS} PARENT_SCOPE)
    set(REQUIRED_FLAG             ${REQUIRED_FLAG}             PARENT_SCOPE)
    set(Boost_USE_STATIC_LIBS     ${Boost_USE_STATIC_LIBS}     PARENT_SCOPE)

    #FindBoost directories
    set(BOOST_ROOT       "${BOOST_ROOT}"       PARENT_SCOPE)
    set(BOOST_INCLUDEDIR "${BOOST_INCLUDEDIR}" PARENT_SCOPE)
    set(BOOST_LIBRARYDIR "${BOOST_LIBRARYDIR}" PARENT_SCOPE)

    set(Boost_FOUND        ${Boost_FOUND}        PARENT_SCOPE)
    set(Boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS} PARENT_SCOPE)
    set(Boost_COMPILER     ${Boost_COMPILER}     PARENT_SCOPE)

    if(NOT BII_BOOST_CLI)
        create_boost_targets()

        getListOfVarsStartingWith(BII BII_API_VARS)
        export_variables(
        VARIABLES
            ${BII_API_VARS}
        FILE
            ${CMAKE_BINARY_DIR}/boost_api_vars.cmake
        )
    else()

    endif()
endfunction()

function(windows_path PATH RESULT_PATH)
    if(WIN32)
        if(MINGW)
            execute_process(
                    COMMAND ${CMAKE_COMMAND} -E echo ${PATH}
                    COMMAND xargs cmd //c echo # WTF cannot believe this worked the very first time
                    OUTPUT_VARIABLE path
            )

            string(REGEX REPLACE "\"" "" path "${path}")
        elseif(CYGWIN)
            execute_process(
                    COMMAND ${CMAKE_COMMAND} -E echo ${PATH}
                    COMMAND xargs cygpath.exe --windows
                    OUTPUT_VARIABLE path
            )
        else()
            set(path "${PATH}")
        endif()

        string(REGEX REPLACE "/" "\\\\" path "${path}")
        set(${RESULT_PATH} "${path}" PARENT_SCOPE)
        message("WINDOWS PATH: ${path}")
    else()
        message(FATAL_ERROR "No Windows platform!")
    endif()
endfunction()

function(BII_FIND_BOOST)
    BII_SETUP_BOOST(${ARGN})

    if(BII_BOOST_VERBOSE)
        message(STATUS "BOOST_ROOT       ${BOOST_ROOT}")
        message(STATUS "BOOST_INCLUDEDIR ${BOOST_INCLUDEDIR}")
        message(STATUS "BOOST_LIBRARYDIR ${BOOST_LIBRARYDIR}")
    endif()

    find_package(Boost COMPONENTS ${BII_BOOST_LIBS} ${REQUIRED_FLAG})

    set(Boost_LIBRARIES    ${Boost_LIBRARIES}    PARENT_SCOPE)
    set(Boost_FOUND        ${Boost_FOUND}        PARENT_SCOPE)
    set(Boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS} PARENT_SCOPE)
    set(Boost_COMPILER     ${Boost_COMPILER}     PARENT_SCOPE)

    set(BII_BOOST_BCP "${BII_BOOST_BCP}" PARENT_SCOPE)

    if(BII_BOOST_FOR_TARGET)
        message(STATUS "Setting up Boost dependencies for target '${BII_BOOST_FOR_TARGET}'")

        if((NOT (Boost_USE_STATIC_LIBS)) AND (WIN32 OR (CMAKE_SYSTEM_NAME MATCHES "Darwin")))
            parse_library_list("${Boost_LIBRARIES}")

            string(REGEX REPLACE ";" "," DEBUG_LIBS "${DEBUG_LIBS}")
            string(REGEX REPLACE ";" "," OPTIMIZED_LIBS "${OPTIMIZED_LIBS}")
            string(REGEX REPLACE ";" "," GENERAL_LIBS "${GENERAL_LIBS}")

            add_custom_command(
                TARGET ${BII_BOOST_FOR_TARGET} PRE_LINK
                COMMAND ${CMAKE_COMMAND}
                    -DDEBUG_LIBS=\"${DEBUG_LIBS}\"
                    -DOPTIMIZED_LIBS=\"${OPTIMIZED_LIBS}\"
                    -DGENERAL_LIBS=\"${GENERAL_LIBS}\"
                    -DTARGET_DIR=\"$<TARGET_FILE:${BII_BOOST_FOR_TARGET}>\"
                    -DBUILD_CONFIG=\"$<UPPER_CASE:$<CONFIG>>\"
                    -DSYSTEM_NAME=\"${CMAKE_SYSTEM_NAME}\"
                    -DBINARY_DIR=\"${CMAKE_BINARY_DIR}\"
                -P \"${boost_install_dir}/copy_dynlibs.cmake\"
            )
        endif()
    endif()
endfunction()
