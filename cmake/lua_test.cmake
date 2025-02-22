function(add_lua_test_library name source dep)
    # list(APPEND TEST_CFLAGS "-Wall" "-std=c99" "-O2" "-fPIC")
    add_library("${name}" SHARED ${source})
    target_include_directories("${name}" PRIVATE "${LUA_SOURCE_DIR}")
    target_compile_options("${name}" PRIVATE ${TEST_CFLAGS})
    set_target_properties("${name}" 
        PROPERTIES 
        PREFIX ""
        FOLDER "${LUA_PROJECT_NAME}/test/libs"
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/libs"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/libs"
    )
    target_link_libraries("${name}" PRIVATE "${dep}" "${LUA_LIBRARY_TARGET}")
endfunction()

