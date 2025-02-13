# A universal CMakeLists file for Lua 5.0 to 5.5.
#
# This CMakeLists is set up so that it can build any of the commonly used
# versions of Lua. It requires that LUA_SOURCE_DIR and LUA_VERSION be defined
# prior to calling add_subdirectory on it. It will then select the appropriate
# set of files to build and generate the library.

cmake_minimum_required(VERSION 3.11)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

set(LUA_PROJECT_NAME "lua" CACHE STRING "The name of the project itself.")

set(LUA_REPOSITORY "${CMAKE_CURRENT_LIST_DIR}" CACHE STRING "The Git repo containing the Lua source code.")
set(LUA_REF "master" CACHE STRING "The branch in the Git repo to use when building.")

# Source repository set up.
include(fetch_lua)
fetch_lua(LUA_SOURCE_DIR ${LUA_PROJECT_NAME} ${LUA_REPOSITORY} ${LUA_REF})

################################################################################
# Configuration settings.

set(LUA_LANGUAGE_CPP FALSE CACHE BOOL "Compile the library in C++")
set(LUA_CONF_32BITS FALSE CACHE BOOL
    "Enables Lua with 32-bit integers and 32-bit floats.")
set(LUA_CONF_USE_C89 FALSE CACHE BOOL
    "Controls the use of non-ISO-C89 features. Define it if you want Lua to avoid the use of a few C99 features or Windows-specific features on Windows.")
set(LUA_CONF_COERSION_TO_STRING TRUE CACHE BOOL
    "Control how Lua performs some coercions. If ON, turns on automatic coercion from strings to numbers.")
set(LUA_CONF_COERSION_TO_NUMBER TRUE CACHE BOOL
    "Control how Lua performs some coercions. If ON, turns on automatic coercion from numbers to strings.")
set(LUA_CONF_USE_APICHECK FALSE CACHE BOOL
    "Turns on several consistency checks on the C API. Define it as a help when debugging C code.")

set(LUA_BUILD_TESTS TRUE CACHE BOOL "Generate targets to run each test.")

################################################################################
# Lua Extensions

set(LUA_EXTENSION_COMPOUND_OPERATOR FALSE CACHE BOOL "")
set(LUA_EXTENSION_NAMED_TABLE_FUNCTIONS FALSE CACHE BOOL "")
set(LUA_EXTENSION_DECORATORS FALSE CACHE BOOL "")
set(LUA_EXTENSION_LAMBDA FALSE CACHE BOOL "")

################################################################################
# Files

include(derive_lua_version)
derive_lua_version(LUA_VERSION ${LUA_SOURCE_DIR})

set(LUA_LIBRARY_NAME "${LUA_PROJECT_NAME}${LUA_VERSION}" CACHE STRING
    "The name of the Lua library to be built.")
set(LUA_INTERPRETER_NAME "${LUA_PROJECT_NAME}${LUA_VERSION}" CACHE STRING
    "The name of the Lua interpreter to be built.")

project(${LUA_PROJECT_NAME}
    VERSION ${LUA_VERSION}
    LANGUAGES CXX C
)

set(LUA_PUBLIC_HEADERS
    "${LUA_SOURCE_DIR}/lauxlib.h"
    "${LUA_SOURCE_DIR}/lua.h"
    "${LUA_SOURCE_DIR}/lualib.h"
)

set(LUA_MODULE_SOURCES
    "${LUA_SOURCE_DIR}/lbaselib.c"
    "${LUA_SOURCE_DIR}/ldblib.c"
    "${LUA_SOURCE_DIR}/liolib.c"
    "${LUA_SOURCE_DIR}/lmathlib.c"
    "${LUA_SOURCE_DIR}/loadlib.c"
    "${LUA_SOURCE_DIR}/lstrlib.c"
    "${LUA_SOURCE_DIR}/ltablib.c"
)

set(LUA_LIBRARY_SOURCES
    "${LUA_SOURCE_DIR}/lapi.c"
    "${LUA_SOURCE_DIR}/lauxlib.c"
    "${LUA_SOURCE_DIR}/lcode.c"
    "${LUA_SOURCE_DIR}/ldebug.c"
    "${LUA_SOURCE_DIR}/ldo.c"
    "${LUA_SOURCE_DIR}/ldump.c"
    "${LUA_SOURCE_DIR}/lfunc.c"
    "${LUA_SOURCE_DIR}/lgc.c"
    "${LUA_SOURCE_DIR}/llex.c"
    "${LUA_SOURCE_DIR}/lmem.c"
    "${LUA_SOURCE_DIR}/lobject.c"
    "${LUA_SOURCE_DIR}/lopcodes.c"
    "${LUA_SOURCE_DIR}/lparser.c"
    "${LUA_SOURCE_DIR}/lstate.c"
    "${LUA_SOURCE_DIR}/lstring.c"
    "${LUA_SOURCE_DIR}/ltable.c"
    "${LUA_SOURCE_DIR}/ltm.c"
    "${LUA_SOURCE_DIR}/lundump.c"
    "${LUA_SOURCE_DIR}/lvm.c"
    "${LUA_SOURCE_DIR}/lzio.c"
)

set(LUA_LIBRARY_HEADERS
    "${LUA_SOURCE_DIR}/lapi.h"
    "${LUA_SOURCE_DIR}/lcode.h"
    "${LUA_SOURCE_DIR}/ldebug.h"
    "${LUA_SOURCE_DIR}/ldo.h"
    "${LUA_SOURCE_DIR}/lfunc.h"
    "${LUA_SOURCE_DIR}/lgc.h"
    "${LUA_SOURCE_DIR}/llex.h"
    "${LUA_SOURCE_DIR}/llimits.h"
    "${LUA_SOURCE_DIR}/lmem.h"
    "${LUA_SOURCE_DIR}/lobject.h"
    "${LUA_SOURCE_DIR}/lopcodes.h"
    "${LUA_SOURCE_DIR}/lparser.h"
    "${LUA_SOURCE_DIR}/lstate.h"
    "${LUA_SOURCE_DIR}/lstring.h"
    "${LUA_SOURCE_DIR}/ltable.h"
    "${LUA_SOURCE_DIR}/ltm.h"
    "${LUA_SOURCE_DIR}/lundump.h"
    "${LUA_SOURCE_DIR}/lvm.h"
    "${LUA_SOURCE_DIR}/lzio.h"
)

set(LUA_INTERNAL_TEST_SOURCES
    "${LUA_SOURCE_DIR}/ltests.c"
    "${LUA_SOURCE_DIR}/ltests.h"
)

set(LUA_INTERPRETER_SOURCES
    "${LUA_SOURCE_DIR}/lua.c"
)

if (LUA_VERSION VERSION_GREATER_EQUAL 5.1)
    list(APPEND LUA_MODULE_SOURCES "${LUA_SOURCE_DIR}/loslib.c")
    list(APPEND LUA_PUBLIC_HEADERS "${LUA_SOURCE_DIR}/luaconf.h")
    list(APPEND LUA_LIBRARY_SOURCES "${LUA_SOURCE_DIR}/linit.c")
endif()
if (LUA_VERSION VERSION_GREATER_EQUAL 5.2)
    list(APPEND LUA_MODULE_SOURCES "${LUA_SOURCE_DIR}/lbitlib.c")
    list(APPEND LUA_MODULE_SOURCES "${LUA_SOURCE_DIR}/lcorolib.c")
    list(APPEND LUA_LIBRARY_SOURCES "${LUA_SOURCE_DIR}/lctype.c")
    list(APPEND LUA_LIBRARY_HEADERS "${LUA_SOURCE_DIR}/lctype.h")
endif()
if (LUA_VERSION VERSION_GREATER_EQUAL 5.3)
    list(APPEND LUA_LIBRARY_HEADERS "${LUA_SOURCE_DIR}/lprefix.h")
    list(APPEND LUA_MODULE_SOURCES "${LUA_SOURCE_DIR}/lutf8lib.c")
endif()
if (LUA_VERSION VERSION_GREATER_EQUAL 5.4)
    list(REMOVE_ITEM LUA_MODULE_SOURCES "${LUA_SOURCE_DIR}/lbitlib.c")
    list(APPEND LUA_LIBRARY_HEADERS "${LUA_SOURCE_DIR}/ljumptab.h")
    list(APPEND LUA_LIBRARY_HEADERS "${LUA_SOURCE_DIR}/lopnames.h")
endif()

source_group("Public Headers" FILES ${LUA_PUBLIC_HEADERS})
source_group("Modules" FILES ${LUA_MODULE_SOURCES})
source_group("Library/Source" FILES ${LUA_LIBRARY_SOURCES})
source_group("Library/Header" FILES ${LUA_LIBRARY_HEADERS})
source_group("Interpreter" FILES ${LUA_INTERPRETER_SOURCES})

################################################################################
# Apply luaconf settings

if(${LUA_CONF_32BITS})
    set(LUA_CONF_DEFINES -DLUA_32BITS ${LUA_CONF_DEFINES})
endif()

if(${LUA_CONF_USE_C89})
    set(LUA_CONF_DEFINES -DLUA_USE_C89 ${LUA_CONF_DEFINES})
endif()

if(NOT ${LUA_CONF_COERSION_TO_STRING})
    set(LUA_CONF_DEFINES -DLUA_NOCVTN2S ${LUA_CONF_DEFINES})
endif()

if(NOT ${LUA_CONF_COERSION_TO_NUMBER})
    set(LUA_CONF_DEFINES -DLUA_NOCVTS2N ${LUA_CONF_DEFINES})
endif()

if(${LUA_CONF_USE_APICHECK})
    set(LUA_CONF_DEFINES -DLUA_USE_APICHECK ${LUA_CONF_DEFINES})
endif()

################################################################################
# Apply patches.

unset(LUA_PATCHES)

# Lambdas
if(LUA_EXTENSION_LAMBDA)
    list(APPEND LUA_PATCHES
        "patches/lambdas.patch"
        "patches/lambdas-tests.patch"
    )
endif()

# Compound Operators
if(LUA_EXTENSION_COMPOUND_OPERATOR)
    list(APPEND LUA_PATCHES
        "patches/restassign-comment.patch"
        "patches/compound-assignment.patch"
        "patches/compound-assignment-tests.patch"
    )
endif()

# Named table functions
if(LUA_EXTENSION_NAMED_TABLE_FUNCTIONS)
    list(APPEND LUA_PATCHES
        "patches/restassign-comment.patch"
        "patches/recfieldkey.patch"
        "patches/table-functions.patch"
        "patches/table-functions-tests.patch"
    )
endif()

# Decorators
if(LUA_EXTENSION_DECORATORS)
    list(APPEND LUA_PATCHES
        "patches/restassign-comment.patch"
        "patches/recfieldkey.patch"
        "patches/callfunc.patch"
        "patches/decorators.patch"
        "patches/decorators-tests.patch"
    )
    # Decorators & Named table functions
    if(LUA_EXTENSION_NAMED_TABLE_FUNCTIONS)
        list(APPEND LUA_PATCHES
            "patches/decorators-fix.patch"
        )
    endif()
endif()

list(REMOVE_DUPLICATES LUA_PATCHES)
foreach(patch ${LUA_PATCHES})
    message(STATUS "Applying patch ${patch}")
    execute_process(
        COMMAND
            git -C "${LUA_SOURCE_DIR}" apply "${CMAKE_CURRENT_LIST_DIR}/${patch}"
        ERROR_VARIABLE error)
    if(error)
        message(FATAL_ERROR "Error applying extension:\n${error}")
    endif()
endforeach()

################################################################################
# Set warnings.

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"
    OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    # Warnings valid for both C and C++
    set(LUA_CWARNSCPP
        "-Wextra"
        "-Wshadow"
        "-Wsign-compare"
        "-Wundef"
        "-Wwrite-strings"
        "-Wredundant-decls"
        "-Wdisabled-optimization"
        "-Wdouble-promotion"
        "-Wstrict-aliasing=3"
        "-Wno-aggressive-loop-optimizations"
        "-Wlogical-op"
        "-Werror"
        # "-pedantic"   # warns if we use jump tables
        # the next warnings generate too much noise, so they are disabled
        # "-Wconversion"  "-Wno-sign-conversion"
        # "-Wsign-conversion"
        # "-Wstrict-overflow=2"
        # "-Wformat=2"
        # "-Wcast-qual"
    )

    # The next warnings are neither valid nor needed for C++
    set(LUA_CWARNSC
        "-Wdeclaration-after-statement"
        "-Wmissing-prototypes"
        "-Wnested-externs"
        "-Wstrict-prototypes"
        "-Wc++-compat"
        "-Wold-style-definition"
    )

    list(APPEND LUA_CONF_DEFINES LUA_USE_LINUX)

    list(APPEND dependencies dl)
    list(APPEND dependencies readline)
    list(APPEND dependencies m)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(LUA_CWARNSC
        "/W4"
        "/WX"
        "/permissive-"
        "/w14254"
        "/w14263"
        "/w14265"
        "/w14287"
        "/we4715"

        "/wd4244" # conversion to 'lua_Number', possible loss of data
        "/wd4267" # conversion to 'lu_mem', possible loss of data
        "/wd4310" # cast truncates constant value
        "/wd4311" # pointer truncation from 'void *const ' to 'lu_hash'
        "/wd4324" # lua_longjmp structure was padded due to alignment specifier
        "/wd4334" # result of 32-bit shift implicitly converted to 64 bits
        "/wd4701" # potentially uninitialized local variable
        "/wd4702" # unreachable code
        "/wd4709" # comma operator within array index expression
        "/wd4996" # getenv
    )
endif()

if (${LUA_LANGUAGE_CPP})
    set(LUA_CWARNS ${LUA_CWARNSC} ${LUA_CWARNSCPP})
    set(LUA_LINKER_LANGUAGE CXX)
else()
    set(LUA_CWARNS ${LUA_CWARNSC})
    set(LUA_LINKER_LANGUAGE C)
endif()

################################################################################
# Set up Lua targets.

# Library.
set(LUA_LIBRARY_TARGET "library")
add_library(${LUA_LIBRARY_TARGET} SHARED
    ${LUA_PUBLIC_HEADERS}
    ${LUA_MODULE_SOURCES}
    ${LUA_LIBRARY_SOURCES}
    ${LUA_LIBRARY_HEADERS}
)

if(MSVC)
    target_sources(${LUA_LIBRARY_TARGET}
        PUBLIC
            $<BUILD_INTERFACE:${LUA_NATVIS}>
    )
endif()

add_library(${LUA_PROJECT_NAME}::${LUA_PROJECT_NAME} ALIAS ${LUA_LIBRARY_TARGET})
target_include_directories(${LUA_LIBRARY_TARGET}
    PUBLIC
        $<BUILD_INTERFACE:${LUA_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${LUA_PROJECT_NAME}${LUA_VERSION}>
)
target_compile_definitions(${LUA_LIBRARY_TARGET}
    PUBLIC
        ${LUA_CONF_DEFINES}
)
target_compile_options(${LUA_LIBRARY_TARGET}
    PRIVATE
        ${LUA_CWARNS}
)
set_target_properties(${LUA_LIBRARY_TARGET}
    PROPERTIES
        LINKER_LANGUAGE ${LUA_LINKER_LANGUAGE}
        FOLDER ${LUA_PROJECT_NAME}
        OUTPUT_NAME ${LUA_LIBRARY_NAME}
        DEBUG_POSTFIX d
)

# Interpreter.
set(LUA_INTERPRETER_TARGET "interpreter")
add_executable(${LUA_INTERPRETER_TARGET}
    ${LUA_INTERPRETER_SOURCES}
)
add_executable(${LUA_PROJECT_NAME}::interpreter ALIAS ${LUA_INTERPRETER_TARGET})
target_compile_options(${LUA_INTERPRETER_TARGET}
    PRIVATE
        ${LUA_CWARNS}
)
set_target_properties(${LUA_INTERPRETER_TARGET}
    PROPERTIES
        LINKER_LANGUAGE ${LUA_LINKER_LANGUAGE}
        FOLDER ${LUA_PROJECT_NAME}
        OUTPUT_NAME ${LUA_INTERPRETER_NAME}
        DEBUG_POSTFIX d
)
target_link_libraries(${LUA_INTERPRETER_TARGET}
    PRIVATE
        ${LUA_LIBRARY_TARGET}
        ${dependencies}
)

################################################################################
# Testing

include(lua_test)

if(LUA_BUILD_TESTS)
    set(LUA_TEST_SOURCE_DIR "${LUA_SOURCE_DIR}/testes/libs")
    add_lua_test_library(lib1 "${LUA_TEST_SOURCE_DIR}/lib1.c")
    add_lua_test_library(lib11 "${LUA_TEST_SOURCE_DIR}/lib11.c")
    add_lua_test_library(lib2 "${LUA_TEST_SOURCE_DIR}/lib2.c")
    add_lua_test_library(lib21 "${LUA_TEST_SOURCE_DIR}/lib21.c")
    add_lua_test_library(lib2-v2 "${LUA_TEST_SOURCE_DIR}/lib22.c")

    function(add_lua_test name basic)
        file(GLOB_RECURSE lua_test_sources "${LUA_SOURCE_DIR}/testes/*")
        set(test_dir "${CMAKE_BINARY_DIR}")
        add_custom_target("${name}"
            COMMAND "${CMAKE_COMMAND}" "-E" "copy_directory_if_different"
                    "${LUA_SOURCE_DIR}/testes" "${test_dir}"
            COMMAND "${CMAKE_COMMAND}" "-E" "chdir" "${test_dir}"
                    "$<TARGET_FILE:${LUA_INTERPRETER_TARGET}>"
                    "-e\"_U=${basic}\"" "all.lua"
            SOURCES ${lua_test_sources}
            DEPENDS ${lua_test_sources}
        )
        add_dependencies(basic_test
            ${LUA_INTERPRETER_TARGET} lib1 lib11 lib2 lib21 lib2-v2)
    endfunction()

    add_lua_test(basic_test "true")
    add_lua_test(complete_test "false")

    # add_executable(internal_test ${LUA_INTERNAL_TEST_SOURCES})
endif()

################################################################################
# Installation

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(package_name         "${LUA_PROJECT_NAME}")
set(cmake_install_dir    "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}")
set(version_config       "${PROJECT_BINARY_DIR}/${package_name}-config-version.cmake")
set(project_config       "${PROJECT_BINARY_DIR}/${package_name}-config.cmake")
set(targets_export_name  "${package_name}-targets")
set(targets_file         "${targets_export_name}.cmake")
set(include_build_dir    "${PROJECT_SOURCE_DIR}/include")

write_basic_package_version_file(
    ${version_config}
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/cmake/lua-config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${cmake_install_dir}"
)

# install project config file and config version file
install(
    FILES
        "${project_config}"
        "${version_config}"
    DESTINATION "${cmake_install_dir}"
)

# Install the public headers
install(
    FILES ${LUA_PUBLIC_HEADERS}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${LUA_PROJECT_NAME}${LUA_VERSION}"
)

# Install the interpreter and library
install(
    TARGETS ${LUA_LIBRARY_TARGET} ${LUA_INTERPRETER_TARGET}
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install targets to an export set
install(
    TARGETS ${LUA_LIBRARY_TARGET}
    EXPORT ${targets_export_name}
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${LUA_PROJECT_NAME}${LUA_VERSION}"
)

# Install the export set to enable importing targets from the build tree
export(
    EXPORT ${targets_export_name}
    FILE ${targets_file}
    NAMESPACE ${package_name}::
)

# Install the export set to enable importing targets from the install tree
install(
    EXPORT ${targets_export_name}
    FILE ${targets_file}
    NAMESPACE ${package_name}::
    DESTINATION "${cmake_install_dir}"
)
