
function(fetch_lua out_var project_name repo ref)
    set(fetch_name "${project_name}-${ref}")

    # Target names cannot contain '/' characters, which sometimes appear in branch names.
    string(REPLACE "/" "-" fetch_name "${fetch_name}")

    # Fetch the content from the Lua repository.
    include(FetchContent)
    FetchContent_Declare(
        "${fetch_name}"
        GIT_REPOSITORY "${repo}"
        GIT_TAG "${ref}"
    )
    FetchContent_MakeAvailable("${fetch_name}")

    set(${out_var} "${${fetch_name}_SOURCE_DIR}" PARENT_SCOPE)
endfunction()
