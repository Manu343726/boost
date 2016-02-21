cmake_minimum_required(VERSION 2.8)

if((EXISTS "${BII_BOOST_CLI_LIB_DEBUG}") AND (EXISTS "${BII_BOOST_CLI_LIB_RELEASE}"))
    set(BII_BOOST_CLI_COMPONENT)
    return()
endif()


project("Boost ${BII_BOOST_CLI_COMPONENT}")

get_filename_component(dir "${CMAKE_CURRENT_LIST_FILE}" PATH)
include(${dir}/../install.cmake)
include(${dir}/../export_variables.cmake)

function(run)
    message(STATUS "[MODULAR BOOST] Setting up ${BII_BOOST_CLI_COMPONENT}")

    import_variables(${CMAKE_BINARY_DIR}/boost_api_vars.cmake)
    import_variables(${CMAKE_BINARY_DIR}/boost_private_vars.cmake)

    set(BII_BOOST_CLI TRUE)
    set(BII_BOOST_LIBS ${BII_BOOST_CLI_COMPONENT})

    BII_FIND_BOOST(COMPONENTS ${BII_BOOST_CLI_COMPONENT})
endfunction()

run()
