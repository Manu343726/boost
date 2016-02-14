
get_filename_component(dir "${TARGET_DIR}" DIRECTORY)

string(REGEX REPLACE "," ";" DEBUG_LIBS "${DEBUG_LIBS}")
string(REGEX REPLACE "," ";" OPTIMIZED_LIBS "${OPTIMIZED_LIBS}")
string(REGEX REPLACE "," ";" GENERAL_LIBS "${GENERAL_LIBS}")

if(NOT (EXISTS dir))
    file(MAKE_DIRECTORY "${dir}")
endif()

set(RELEASE_LIBS ${OPTIMIZED_LIBS})

if(SYSTEM_NAME MATCHES "Windows")
    set(__DYNLIB_EXTENSION     .dll   ${SCOPE})
elseif(SYSTEM_NAME MATCHES "Darwin")
    set(__DYNLIB_EXTENSION     .dylib ${SCOPE})
elseif(SYSTEM_NAME MATCHES "Linux")
    set(__DYNLIB_EXTENSION     .so    ${SCOPE})
else()
    message(FATAL_ERROR "Unknown platform: '${SYSTEM_NAME}'")
endif()

foreach(lib ${${BUILD_CONFIG}_LIBS})
    get_filename_component(path "${lib}" DIRECTORY)
    get_filename_component(name "${lib}" NAME_WE)
    get_filename_component(ext  "${lib}" EXT)

    if(ext MATCHES ".lib")
        set(ext .dll)
    endif()
    set(dest "${dir}/${name}${ext}")
    message(STATUS "Copying ${name}${ext} to ${dest}...")

    file(COPY "${path}/${name}${ext}" DESTINATION "${dir}")
    file(COPY "${path}/${name}${ext}" DESTINATION "${BINARY_DIR}")
endforeach()