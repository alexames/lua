
function(derive_lua_version out_var source_dir)
    file(READ "${source_dir}/lua.h" LUA_H)

    set(LUA_VERSION_REGEX
        "#define[ \t]+LUA_VERSION[ \t]+\"Lua ([0-9]).([0-9])\"")
    set(LUA_VERSION_MAJOR_REGEX
        "#define[ \t]+(LUA_VERSION_MAJOR|LUA_VERSION_MAJOR_N)?[ \t]+\"?([0-9])\"?")
    set(LUA_VERSION_MINOR_REGEX
        "#define[ \t]+(LUA_VERSION_MINOR|LUA_VERSION_MINOR_N)?[ \t]+\"?([0-9])\"?")

    string(REGEX MATCH "${LUA_VERSION_REGEX}" result "${LUA_H}")

    if(result)
        set(LUA_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(LUA_VERSION_MINOR "${CMAKE_MATCH_2}")
    else()
        string(REGEX MATCH "${LUA_VERSION_MAJOR_REGEX}" _ "${LUA_H}")
        set(LUA_VERSION_MAJOR "${CMAKE_MATCH_2}")

        string(REGEX MATCH "${LUA_VERSION_MINOR_REGEX}" _ "${LUA_H}")
        set(LUA_VERSION_MINOR "${CMAKE_MATCH_2}")
    endif()

    set(${out_var} "${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}" PARENT_SCOPE)
endfunction()
