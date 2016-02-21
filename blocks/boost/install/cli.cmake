get_filename_component(boost_install_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)

function(add_scope)
    include(${boost_install_dir}/install.cmake)
endfunction()

add_scope()
