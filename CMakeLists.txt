# A universal CMakeLists file for Lua 5.0 to 5.5.
#
# This CMakeLists is set up so that it can build any of the commonly used
# versions of Lua. It requires that LUA_SOURCE_DIR and LUA_VERSION be defined
# prior to calling add_subdirectory on it. It will then select the appropriate
# set of files to build and generate the library.

set(LUA_VERSION_MAJOR "5")
set(LUA_VERSION_MINOR "5")
set(LUA_VERSION "${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")

set(LUA_PROJECT_NAME "lua" CACHE STRING "The name of the project itself.")

cmake_minimum_required(VERSION 3.5)
project(Lua
    VERSION ${LUA_VERSION}
    LANGUAGES CXX C
)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

################################################################################
# Configuration settings.

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(LUA_LANGUAGE_CPP FALSE CACHE BOOL "Compile the library in C++")
set(LUA_CONF_32BITS FALSE CACHE BOOL "Enables Lua with 32-bit integers and 32-bit floats.")
set(LUA_CONF_USE_C89 FALSE CACHE BOOL "Controls the use of non-ISO-C89 features. Define it if you want Lua to avoid the use of a few C99 features or Windows-specific features on Windows.")
set(LUA_CONF_COERSION_TO_STRING TRUE CACHE BOOL "Control how Lua performs some coercions. If ON, turns on automatic coercion from strings to numbers.")
set(LUA_CONF_COERSION_TO_NUMBER TRUE CACHE BOOL "Control how Lua performs some coercions. If ON, turns on automatic coercion from numbers to strings.")
set(LUA_CONF_USE_APICHECK FALSE CACHE BOOL "Turns on several consistency checks on the C API. Define it as a help when debugging C code.")

set(LUA_LIBRARY_NAME "${LUA_PROJECT_NAME}${LUA_VERSION_MAJOR}${LUA_VERSION_MINOR}" CACHE STRING "The name of the built library.")
set(LUA_INTERPRETER_NAME "${LUA_PROJECT_NAME}${LUA_VERSION_MAJOR}${LUA_VERSION_MINOR}" CACHE STRING "The name of the Lua interpreter.")

set(LUA_BUILD_TESTS TRUE CACHE BOOL "Generate targets to run each test.")

################################################################################
# Files

set(LUA_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})

set(LUA_PUBLIC_HEADERS
    ${LUA_SOURCE_DIR}/lauxlib.h
    ${LUA_SOURCE_DIR}/lua.h
    ${LUA_SOURCE_DIR}/lualib.h
)

set(LUA_MODULE_SOURCES
    ${LUA_SOURCE_DIR}/lbaselib.c
    ${LUA_SOURCE_DIR}/ldblib.c
    ${LUA_SOURCE_DIR}/liolib.c
    ${LUA_SOURCE_DIR}/lmathlib.c
    ${LUA_SOURCE_DIR}/loadlib.c
    ${LUA_SOURCE_DIR}/lstrlib.c
    ${LUA_SOURCE_DIR}/ltablib.c
)

set(LUA_LIBRARY_SOURCES
    ${LUA_SOURCE_DIR}/lapi.c
    ${LUA_SOURCE_DIR}/lauxlib.c
    ${LUA_SOURCE_DIR}/lcode.c
    ${LUA_SOURCE_DIR}/ldebug.c
    ${LUA_SOURCE_DIR}/ldo.c
    ${LUA_SOURCE_DIR}/ldump.c
    ${LUA_SOURCE_DIR}/lfunc.c
    ${LUA_SOURCE_DIR}/lgc.c
    ${LUA_SOURCE_DIR}/linit.c
    ${LUA_SOURCE_DIR}/llex.c
    ${LUA_SOURCE_DIR}/lmem.c
    ${LUA_SOURCE_DIR}/lobject.c
    ${LUA_SOURCE_DIR}/lopcodes.c
    ${LUA_SOURCE_DIR}/lparser.c
    ${LUA_SOURCE_DIR}/lstate.c
    ${LUA_SOURCE_DIR}/lstring.c
    ${LUA_SOURCE_DIR}/ltable.c
    ${LUA_SOURCE_DIR}/ltm.c
    ${LUA_SOURCE_DIR}/lundump.c
    ${LUA_SOURCE_DIR}/lvm.c
    ${LUA_SOURCE_DIR}/lzio.c
)

set(LUA_LIBRARY_HEADERS
    ${LUA_SOURCE_DIR}/lapi.h
    ${LUA_SOURCE_DIR}/lcode.h
    ${LUA_SOURCE_DIR}/ldebug.h
    ${LUA_SOURCE_DIR}/ldo.h
    ${LUA_SOURCE_DIR}/lfunc.h
    ${LUA_SOURCE_DIR}/lgc.h
    ${LUA_SOURCE_DIR}/llex.h
    ${LUA_SOURCE_DIR}/llimits.h
    ${LUA_SOURCE_DIR}/lmem.h
    ${LUA_SOURCE_DIR}/lobject.h
    ${LUA_SOURCE_DIR}/lopcodes.h
    ${LUA_SOURCE_DIR}/lparser.h
    ${LUA_SOURCE_DIR}/lstate.h
    ${LUA_SOURCE_DIR}/lstring.h
    ${LUA_SOURCE_DIR}/ltable.h
    ${LUA_SOURCE_DIR}/ltm.h
    ${LUA_SOURCE_DIR}/lundump.h
    ${LUA_SOURCE_DIR}/lvm.h
    ${LUA_SOURCE_DIR}/lzio.h
)

set(LUA_NATVIS
    ${LUA_SOURCE_DIR}/natvis/lua.natvis
)

if (LUA_VERSION VERSION_GREATER_EQUAL 5.1)
    list(APPEND LUA_MODULE_SOURCES ${LUA_SOURCE_DIR}/loslib.c)
    list(APPEND LUA_PUBLIC_HEADERS ${LUA_SOURCE_DIR}/luaconf.h)
endif()
if (LUA_VERSION VERSION_GREATER_EQUAL 5.2)
    list(APPEND LUA_MODULE_SOURCES ${LUA_SOURCE_DIR}/lbitlib.c)
    list(APPEND LUA_MODULE_SOURCES ${LUA_SOURCE_DIR}/lcorolib.c)
    list(APPEND LUA_LIBRARY_SOURCES ${LUA_SOURCE_DIR}/lctype.c)
    list(APPEND LUA_LIBRARY_HEADERS ${LUA_SOURCE_DIR}/lctype.h)
endif()
if (LUA_VERSION VERSION_GREATER_EQUAL 5.3)
    list(APPEND LUA_LIBRARY_HEADERS ${LUA_SOURCE_DIR}/lprefix.h)
    list(APPEND LUA_MODULE_SOURCES ${LUA_SOURCE_DIR}/lutf8lib.c)
endif()
if (LUA_VERSION VERSION_GREATER_EQUAL 5.4)
    list(REMOVE_ITEM LUA_MODULE_SOURCES ${LUA_SOURCE_DIR}/lbitlib.c)
    list(APPEND LUA_LIBRARY_HEADERS ${LUA_SOURCE_DIR}/ljumptab.h)
    list(APPEND LUA_LIBRARY_HEADERS ${LUA_SOURCE_DIR}/lopnames.h)
endif()

set(LUA_INTERPRETER_SOURCES
    ${LUA_SOURCE_DIR}/lua.c
)

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
# Set warnings.

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" 
    OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    # Warnings valid for both C and C++
    set(LUA_CWARNSCPP
        -Wextra
        -Wshadow
        -Wsign-compare
        -Wundef
        -Wwrite-strings
        -Wredundant-decls
        -Wdisabled-optimization
        -Wdouble-promotion
        -Wstrict-aliasing=3
        -Wno-aggressive-loop-optimizations
        -Wlogical-op
        -Werror
        # -pedantic   # warns if we use jump tables
        # the next warnings generate too much noise, so they are disabled
        # -Wconversion  -Wno-sign-conversion
        # -Wsign-conversion
        # -Wstrict-overflow=2
        # -Wformat=2
        # -Wcast-qual
    )

    # The next warnings are neither valid nor needed for C++
    set(LUA_CWARNSC
        -Wdeclaration-after-statement
        -Wmissing-prototypes
        -Wnested-externs
        -Wstrict-prototypes
        -Wc++-compat
        -Wold-style-definition
    )

    list(APPEND LUA_CONF_DEFINES LUA_USE_LINUX)
    list(APPEND LUA_CONF_DEFINES LUA_USE_READLINE)

    list(APPEND dependencies dl)
    list(APPEND dependencies readline)
    list(APPEND dependencies m)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    # TODO: Add MSVC warnings
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
add_library(${LUA_LIBRARY_TARGET} STATIC
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
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
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
)

# Interpreter.
set(LUA_INTERPRETER_TARGET "interpreter")
add_executable(${LUA_INTERPRETER_TARGET}
    ${LUA_INTERPRETER_SOURCES}
)
add_executable(${LUA_PROJECT_NAME}::interpreter ALIAS ${LUA_INTERPRETER_TARGET})
set_target_properties(${LUA_INTERPRETER_TARGET}
    PROPERTIES
        LINKER_LANGUAGE ${LUA_LINKER_LANGUAGE}
        FOLDER ${LUA_PROJECT_NAME}
        OUTPUT_NAME ${LUA_INTERPRETER_NAME}
)
target_link_libraries(${LUA_INTERPRETER_TARGET}
    PRIVATE
        ${LUA_LIBRARY_TARGET}
        ${dependencies}
)

################################################################################
# Installation

set(package_name         "${LUA_PROJECT_NAME}")
set(cmake_install_dir    "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}")
set(version_config       "${PROJECT_BINARY_DIR}/${package_name}-config-version.cmake")
set(project_config       "${PROJECT_BINARY_DIR}/${package_name}-config.cmake")
set(targets_export_name  "${package_name}-targets")
set(targets_file         "${targets_export_name}.cmake")
set(include_build_dir    "${PROJECT_SOURCE_DIR}/include/")

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
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
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
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
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
