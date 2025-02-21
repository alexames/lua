function(add_lua_test test_name lua_file)
    if (LUA_BUILD_TESTS)
        add_custom_target(test_${test_name}
            COMMAND
                "$<TARGET_FILE:${LUA_INTERPRETER_TARGET}>" 
                "${LUA_SOURCE_DIR}/testes/${lua_file}"
            WORKING_DIRECTORY
                "${LUA_SOURCE_DIR}/testes"
            SOURCES
                "${LUA_SOURCE_DIR}/testes/${lua_file}"
            DEPENDS
                "${LUA_SOURCE_DIR}/testes/${lua_file}"
            USES_TERMINAL
        )
        add_dependencies(test_${test_name}
            ${LUA_INTERPRETER_TARGET}
        )
    endif()
endfunction()

