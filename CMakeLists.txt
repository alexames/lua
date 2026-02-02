cmake_minimum_required(VERSION 3.15)

# Lua 5.1.1

project(Lua
  VERSION 5.1.1
  LANGUAGES C
)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(CheckLibraryExists)

# ------------------------------------------------------------------------------
# User-facing knobs
# ------------------------------------------------------------------------------

set(LUA_PROJECT_NAME "lua51" CACHE STRING "Package/namespace name (exported as <name>::<name>, <name>::<name>_interpreter).")

# Build products
option(LUA_BUILD_LIBRARY      "Build the Lua library target" ON)
option(LUA_BUILD_INTERPRETER  "Build the 'lua' interpreter executable" ON)

# Library type
set(LUA_LIBRARY_TYPE "SHARED" CACHE STRING "Library type: STATIC or SHARED")
set_property(CACHE LUA_LIBRARY_TYPE PROPERTY STRINGS STATIC SHARED)

# Warnings
option(LUA_ENABLE_WERROR "Treat warnings as errors" ON)

# Core Lua compile-time feature knobs (mostly from luaconf.h)
option(LUA_ANSI                   "Define LUA_ANSI (avoid non-ANSI features)" OFF)
option(LUA_CONF_USE_APICHECK      "Define LUA_USE_APICHECK (extra C API checks)" OFF)

# 5.0 compatibility options (Lua 5.1 can enable these for 5.0 compatibility)
# Note: LUA_COMPAT_VARARG/MOD/LSTR/GFIND/OPENLIB are already defined in luaconf.h,
# so we default them to OFF here to avoid macro redefinition warnings.
# Only enable these if you need to override luaconf.h's defaults.
option(LUA_COMPAT_GETN            "Define LUA_COMPAT_GETN (setn/getn behavior from 5.0)" OFF)
option(LUA_COMPAT_LOADLIB         "Define LUA_COMPAT_LOADLIB (global loadlib function)" OFF)
option(LUA_COMPAT_VARARG          "Define LUA_COMPAT_VARARG (old 'arg' table for varargs) - already in luaconf.h" OFF)
option(LUA_COMPAT_MOD             "Define LUA_COMPAT_MOD (math.mod function) - already in luaconf.h" OFF)
option(LUA_COMPAT_LSTR            "Define LUA_COMPAT_LSTR (old long string nesting) - already in luaconf.h" OFF)
option(LUA_COMPAT_GFIND           "Define LUA_COMPAT_GFIND (string.gfind name) - already in luaconf.h" OFF)
option(LUA_COMPAT_OPENLIB         "Define LUA_COMPAT_OPENLIB (luaL_openlib behavior) - already in luaconf.h" OFF)

# Hard limits (safe-ish knobs)
set(LUAI_MAXSTACK  "" CACHE STRING "Override LUAI_MAXSTACK (max Lua stack size). Empty = default")

# ABI-sensitive knobs (must match all consumers embedding/linking Lua)
set(LUA_IDSIZE        "" CACHE STRING "Override LUA_IDSIZE (ABI-sensitive). Empty = default")
set(LUAL_BUFFERSIZE   "" CACHE STRING "Override LUAL_BUFFERSIZE (ABI-sensitive). Empty = default")
set(LUAI_EXTRASPACE   "" CACHE STRING "Override LUAI_EXTRASPACE (ABI-sensitive). Empty = default")

# Platform feature knobs (interpreter/runtime)
option(LUA_USE_DLOPEN    "Enable dynamic module loading (LUA_USE_DLOPEN) where supported" ON)
option(LUA_USE_READLINE  "Enable readline support for interactive interpreter (LUA_USE_READLINE)" OFF)

# Path/layout knobs (string macros)
# These are best handled via LUA_USER_H include hook (lua.h includes LUA_USER_H if defined). :contentReference[oaicite:0]{index=0}
set(LUA_PATH_DEFAULT  "" CACHE STRING "Override LUA_PATH_DEFAULT (string). Empty = upstream default")
set(LUA_CPATH_DEFAULT "" CACHE STRING "Override LUA_CPATH_DEFAULT (string). Empty = upstream default")
set(LUA_DIRSEP        "" CACHE STRING "Override LUA_DIRSEP (string). Empty = upstream default")
set(LUA_PATH_SEP      "" CACHE STRING "Override LUA_PATH_SEP (string). Empty = upstream default")
set(LUA_PATH_MARK     "" CACHE STRING "Override LUA_PATH_MARK (string). Empty = upstream default")
set(LUA_EXEC_DIR      "" CACHE STRING "Override LUA_EXEC_DIR (string). Empty = upstream default")
set(LUA_IGMARK        "" CACHE STRING "Override LUA_IGMARK (string). Empty = upstream default")

# Interpreter UI knobs (string/int macros in lua.c)
set(LUA_INIT_VAR  "" CACHE STRING "Override LUA_INIT_VAR (string). Empty = upstream default")
set(LUA_PROMPT    "" CACHE STRING "Override LUA_PROMPT (string). Empty = upstream default")
set(LUA_PROMPT2   "" CACHE STRING "Override LUA_PROMPT2 (string). Empty = upstream default")
set(LUA_MAXINPUT  "" CACHE STRING "Override LUA_MAXINPUT (integer). Empty = upstream default")

# Output names
set(LUA_LIBRARY_NAME     "${LUA_PROJECT_NAME}" CACHE STRING "Output name for the Lua library")
set(LUA_INTERPRETER_NAME "${LUA_PROJECT_NAME}" CACHE STRING "Output name for the Lua interpreter")

# ------------------------------------------------------------------------------
# Sources (assumes this CMakeLists.txt sits in the same directory as *.c/*.h)
# ------------------------------------------------------------------------------

set(LUA_PUBLIC_HEADERS
  "${CMAKE_CURRENT_LIST_DIR}/lauxlib.h"
  "${CMAKE_CURRENT_LIST_DIR}/lua.h"
  "${CMAKE_CURRENT_LIST_DIR}/luaconf.h"
  "${CMAKE_CURRENT_LIST_DIR}/lualib.h"
)

set(LUA_MODULE_SOURCES
  "${CMAKE_CURRENT_LIST_DIR}/lbaselib.c"
  "${CMAKE_CURRENT_LIST_DIR}/ldblib.c"
  "${CMAKE_CURRENT_LIST_DIR}/liolib.c"
  "${CMAKE_CURRENT_LIST_DIR}/lmathlib.c"
  "${CMAKE_CURRENT_LIST_DIR}/loadlib.c"
  "${CMAKE_CURRENT_LIST_DIR}/loslib.c"
  "${CMAKE_CURRENT_LIST_DIR}/lstrlib.c"
  "${CMAKE_CURRENT_LIST_DIR}/ltablib.c"
)

set(LUA_LIBRARY_SOURCES
  "${CMAKE_CURRENT_LIST_DIR}/lapi.c"
  "${CMAKE_CURRENT_LIST_DIR}/lauxlib.c"
  "${CMAKE_CURRENT_LIST_DIR}/lcode.c"
  "${CMAKE_CURRENT_LIST_DIR}/ldebug.c"
  "${CMAKE_CURRENT_LIST_DIR}/ldo.c"
  "${CMAKE_CURRENT_LIST_DIR}/ldump.c"
  "${CMAKE_CURRENT_LIST_DIR}/lfunc.c"
  "${CMAKE_CURRENT_LIST_DIR}/lgc.c"
  "${CMAKE_CURRENT_LIST_DIR}/linit.c"
  "${CMAKE_CURRENT_LIST_DIR}/llex.c"
  "${CMAKE_CURRENT_LIST_DIR}/lmem.c"
  "${CMAKE_CURRENT_LIST_DIR}/lobject.c"
  "${CMAKE_CURRENT_LIST_DIR}/lopcodes.c"
  "${CMAKE_CURRENT_LIST_DIR}/lparser.c"
  "${CMAKE_CURRENT_LIST_DIR}/lstate.c"
  "${CMAKE_CURRENT_LIST_DIR}/lstring.c"
  "${CMAKE_CURRENT_LIST_DIR}/ltable.c"
  "${CMAKE_CURRENT_LIST_DIR}/ltm.c"
  "${CMAKE_CURRENT_LIST_DIR}/lundump.c"
  "${CMAKE_CURRENT_LIST_DIR}/lvm.c"
  "${CMAKE_CURRENT_LIST_DIR}/lzio.c"
)

set(LUA_LIBRARY_HEADERS
  "${CMAKE_CURRENT_LIST_DIR}/lapi.h"
  "${CMAKE_CURRENT_LIST_DIR}/lcode.h"
  "${CMAKE_CURRENT_LIST_DIR}/ldebug.h"
  "${CMAKE_CURRENT_LIST_DIR}/ldo.h"
  "${CMAKE_CURRENT_LIST_DIR}/lfunc.h"
  "${CMAKE_CURRENT_LIST_DIR}/lgc.h"
  "${CMAKE_CURRENT_LIST_DIR}/llex.h"
  "${CMAKE_CURRENT_LIST_DIR}/llimits.h"
  "${CMAKE_CURRENT_LIST_DIR}/lmem.h"
  "${CMAKE_CURRENT_LIST_DIR}/lobject.h"
  "${CMAKE_CURRENT_LIST_DIR}/lopcodes.h"
  "${CMAKE_CURRENT_LIST_DIR}/lparser.h"
  "${CMAKE_CURRENT_LIST_DIR}/lstate.h"
  "${CMAKE_CURRENT_LIST_DIR}/lstring.h"
  "${CMAKE_CURRENT_LIST_DIR}/ltable.h"
  "${CMAKE_CURRENT_LIST_DIR}/ltm.h"
  "${CMAKE_CURRENT_LIST_DIR}/lundump.h"
  "${CMAKE_CURRENT_LIST_DIR}/lvm.h"
  "${CMAKE_CURRENT_LIST_DIR}/lzio.h"
)

set(LUA_INTERPRETER_SOURCES
  "${CMAKE_CURRENT_LIST_DIR}/lua.c"
)

# ------------------------------------------------------------------------------
# Helper: add definition only if value is set
# ------------------------------------------------------------------------------

function(lua_add_def_if_set tgt defname value)
  if(NOT "${value}" STREQUAL "")
    target_compile_definitions(${tgt} PUBLIC "${defname}=${value}")
  endif()
endfunction()

# ------------------------------------------------------------------------------
# Generate a custom user header (included via LUA_USER_H in lua.h) for string knobs
# ------------------------------------------------------------------------------

set(LUA_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${LUA_GENERATED_DIR}")

set(LUA_USER_HEADER "${LUA_GENERATED_DIR}/luaconf_custom.h")

# Minimal, safe header: only defines overrides when non-empty.
# This avoids editing luaconf.h directly while still using upstream’s supported hook. :contentReference[oaicite:1]{index=1}
file(WRITE "${LUA_USER_HEADER}" "/* Auto-generated by CMake. */\n#pragma once\n\n")

# String macro helper (C-escaped quotes)
function(lua_write_string_define name value)
  if(NOT "${value}" STREQUAL "")
    string(REPLACE "\\" "\\\\" _v "${value}")
    string(REPLACE "\"" "\\\"" _v "${_v}")
    file(APPEND "${LUA_USER_HEADER}" "#undef ${name}\n#define ${name} \"${_v}\"\n\n")
  endif()
endfunction()

lua_write_string_define(LUA_PATH_DEFAULT  "${LUA_PATH_DEFAULT}")
lua_write_string_define(LUA_CPATH_DEFAULT "${LUA_CPATH_DEFAULT}")
lua_write_string_define(LUA_DIRSEP        "${LUA_DIRSEP}")
lua_write_string_define(LUA_PATH_SEP      "${LUA_PATH_SEP}")
lua_write_string_define(LUA_PATH_MARK     "${LUA_PATH_MARK}")
lua_write_string_define(LUA_EXEC_DIR      "${LUA_EXEC_DIR}")
lua_write_string_define(LUA_IGMARK        "${LUA_IGMARK}")

lua_write_string_define(LUA_INIT_VAR "${LUA_INIT_VAR}")
lua_write_string_define(LUA_PROMPT   "${LUA_PROMPT}")
lua_write_string_define(LUA_PROMPT2  "${LUA_PROMPT2}")

if(NOT "${LUA_MAXINPUT}" STREQUAL "")
  file(APPEND "${LUA_USER_HEADER}" "#undef LUA_MAXINPUT\n#define LUA_MAXINPUT ${LUA_MAXINPUT}\n\n")
endif()

# ------------------------------------------------------------------------------
# Targets
# ------------------------------------------------------------------------------

if(LUA_BUILD_LIBRARY)
  set(LUA_LIBRARY_TARGET "${LUA_LIBRARY_NAME}")
  if(LUA_LIBRARY_TYPE STREQUAL "SHARED")
    add_library(${LUA_LIBRARY_TARGET} SHARED
      ${LUA_PUBLIC_HEADERS}
      ${LUA_MODULE_SOURCES}
      ${LUA_LIBRARY_SOURCES}
      ${LUA_LIBRARY_HEADERS}
    )
  else()
    add_library(${LUA_LIBRARY_TARGET} STATIC
      ${LUA_PUBLIC_HEADERS}
      ${LUA_MODULE_SOURCES}
      ${LUA_LIBRARY_SOURCES}
      ${LUA_LIBRARY_HEADERS}
    )
  endif()

  add_library(${LUA_PROJECT_NAME}::${LUA_LIBRARY_TARGET} ALIAS ${LUA_LIBRARY_TARGET})

  # When building as a shared library on Windows, define LUA_BUILD_AS_DLL so that
  # luaconf.h marks API functions with __declspec(dllexport) during the build and
  # __declspec(dllimport) for consumers. This is required for C modules (DLLs) to
  # link against the shared Lua library at runtime.
  if(LUA_LIBRARY_TYPE STREQUAL "SHARED" AND WIN32)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PRIVATE LUA_BUILD_AS_DLL)
    target_compile_definitions(${LUA_LIBRARY_TARGET} INTERFACE LUA_BUILD_AS_DLL)
  endif()

  target_include_directories(${LUA_LIBRARY_TARGET}
    PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
      $<BUILD_INTERFACE:${LUA_GENERATED_DIR}>
      $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )

  # Ensure the custom header is seen via the upstream hook in lua.h. :contentReference[oaicite:2]{index=2}
  # LUA_USER_H must expand to a quoted include name.
  target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_USER_H=\"luaconf_custom.h\")

  # C standard
  # Note: Lua 5.1 uses POSIX functions (popen, mkstemp, _longjmp) that require
  # GNU extensions on Linux/macOS. C_EXTENSIONS must be YES for non-Windows.
  if(WIN32)
    set_target_properties(${LUA_LIBRARY_TARGET} PROPERTIES
      C_STANDARD 99
      C_STANDARD_REQUIRED YES
      C_EXTENSIONS NO
      OUTPUT_NAME "${LUA_LIBRARY_NAME}"
    )
  else()
    set_target_properties(${LUA_LIBRARY_TARGET} PROPERTIES
      C_STANDARD 99
      C_STANDARD_REQUIRED YES
      C_EXTENSIONS YES
      OUTPUT_NAME "${LUA_LIBRARY_NAME}"
    )
  endif()

  # Core compile definitions (no -D prefixes)
  if(LUA_ANSI)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_ANSI)
  endif()
  if(LUA_CONF_USE_APICHECK)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_USE_APICHECK)
  endif()

  # 5.0 compatibility options
  if(LUA_COMPAT_GETN)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_GETN)
  endif()
  if(LUA_COMPAT_LOADLIB)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_LOADLIB)
  endif()
  if(LUA_COMPAT_VARARG)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_VARARG)
  endif()
  if(LUA_COMPAT_MOD)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_MOD)
  endif()
  if(LUA_COMPAT_LSTR)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_LSTR)
  endif()
  if(LUA_COMPAT_GFIND)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_GFIND)
  endif()
  if(LUA_COMPAT_OPENLIB)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_COMPAT_OPENLIB)
  endif()

  # Limits
  lua_add_def_if_set(${LUA_LIBRARY_TARGET} LUAI_MAXSTACK "${LUAI_MAXSTACK}")

  # ABI-sensitive (warn if user sets)
  foreach(_abi LUA_IDSIZE LUAL_BUFFERSIZE LUAI_EXTRASPACE)
    if(NOT "${${_abi}}" STREQUAL "")
      message(WARNING "Lua ABI-sensitive override set: ${_abi}=${${_abi}}. All consumers must compile with matching settings.")
      lua_add_def_if_set(${LUA_LIBRARY_TARGET} ${_abi} "${${_abi}}")
    endif()
  endforeach()

  # Platform features & libs
  set(_lua_platform_libs "")

  # Note: LUA_USE_WINDOWS is auto-detected in luaconf.h based on _WIN32
  # On Windows, luaconf.h also sets LUA_DL_DLL for dynamic loading support
  if(NOT WIN32)
    target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_USE_POSIX)
    if(LUA_USE_DLOPEN)
      target_compile_definitions(${LUA_LIBRARY_TARGET} PUBLIC LUA_USE_DLOPEN)
      # Prefer CMake-provided dl libs (empty on platforms that don't need it).
      list(APPEND _lua_platform_libs ${CMAKE_DL_LIBS})
    endif()
  endif()

  # libm: only link if needed (portable check)
  if(NOT WIN32)
    check_library_exists(m cos "" LUA_HAS_LIBM)
    if(LUA_HAS_LIBM)
      list(APPEND _lua_platform_libs m)
    endif()
  endif()

  target_link_libraries(${LUA_LIBRARY_TARGET} PRIVATE ${_lua_platform_libs})

  # Warnings
  if(MSVC)
    target_compile_options(${LUA_LIBRARY_TARGET} PRIVATE /W4)
    # Disable warnings triggered by Lua source code:
    #   C4005: macro redefinition (compat macros defined both in luaconf.h and command line)
    #   C4244: conversion from 'int' to smaller type, possible loss of data
    #   C4310: cast truncates constant value
    #   C4324: structure was padded due to alignment specifier
    #   C4334: 32-bit shift implicitly converted to 64 bits
    #   C4701: potentially uninitialized local variable used
    #   C4702: unreachable code
    #   C4709: comma operator within array index expression
    #   C4996: deprecated CRT functions (fopen, sprintf, etc.)
    target_compile_options(${LUA_LIBRARY_TARGET} PRIVATE /wd4005 /wd4244 /wd4310 /wd4324 /wd4334 /wd4701 /wd4702 /wd4709 /wd4996)
    if(LUA_ENABLE_WERROR)
      target_compile_options(${LUA_LIBRARY_TARGET} PRIVATE /WX)
    endif()
  else()
    target_compile_options(${LUA_LIBRARY_TARGET} PRIVATE -Wall -Wextra -Wshadow -Wsign-compare -Wundef -Wwrite-strings -Wredundant-decls)
    # Disable warnings triggered by Lua 5.1 source code:
    #   -Wno-implicit-fallthrough: ltable.c has intentional fallthrough in luaH_get
    #   -Wno-address: ldump.c has getstr(s)==NULL comparison that's always false
    #   -Wno-misleading-indentation: (GCC) lauxlib.c has intentional while(...) ; pattern
    #   -Wno-empty-body: (Clang) lauxlib.c has intentional while(...) ; pattern
    target_compile_options(${LUA_LIBRARY_TARGET} PRIVATE -Wno-implicit-fallthrough -Wno-address -Wno-misleading-indentation -Wno-empty-body)
    if(LUA_ENABLE_WERROR)
      target_compile_options(${LUA_LIBRARY_TARGET} PRIVATE -Werror)
    endif()
  endif()

  # Natvis for Visual Studio debugging
  if(MSVC)
    set(LUA_NATVIS "${CMAKE_CURRENT_LIST_DIR}/natvis/lua.natvis")
    if(EXISTS "${LUA_NATVIS}")
      target_sources(${LUA_LIBRARY_TARGET} PUBLIC
        $<BUILD_INTERFACE:${LUA_NATVIS}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_DATADIR}/${LUA_PROJECT_NAME}/lua.natvis>
      )
      install(FILES "${LUA_NATVIS}" DESTINATION "${CMAKE_INSTALL_DATADIR}/${LUA_PROJECT_NAME}")
    endif()
  endif()
endif()

# Interpreter
if(LUA_BUILD_INTERPRETER)
  set(LUA_INTERPRETER_TARGET "${LUA_PROJECT_NAME}_interpreter")
  add_executable(${LUA_INTERPRETER_TARGET} ${LUA_INTERPRETER_SOURCES})
  add_executable(${LUA_PROJECT_NAME}::${LUA_INTERPRETER_TARGET} ALIAS ${LUA_INTERPRETER_TARGET})

  set_target_properties(${LUA_INTERPRETER_TARGET} PROPERTIES
    OUTPUT_NAME "${LUA_INTERPRETER_NAME}"
  )

  if(LUA_BUILD_LIBRARY)
    target_link_libraries(${LUA_INTERPRETER_TARGET} PRIVATE ${LUA_LIBRARY_TARGET})
    # Inherit public defs/includes from lua target
  endif()

  # Match warning suppressions from library target
  if(MSVC)
    target_compile_options(${LUA_INTERPRETER_TARGET} PRIVATE /wd4005 /wd4996)
  endif()

  if(LUA_USE_READLINE AND NOT WIN32)
    target_compile_definitions(${LUA_INTERPRETER_TARGET} PRIVATE LUA_USE_READLINE)

    find_library(LUA_READLINE_LIB readline)
    if(NOT LUA_READLINE_LIB)
      message(FATAL_ERROR "LUA_USE_READLINE=ON but readline library not found.")
    endif()

    # Many platforms also require termcap/ncurses for readline; try common libs.
    find_library(LUA_NCURSES_LIB ncurses)
    find_library(LUA_TINFO_LIB tinfo)
    find_library(LUA_TERMCAP_LIB termcap)

    target_link_libraries(${LUA_INTERPRETER_TARGET} PRIVATE ${LUA_READLINE_LIB})
    if(LUA_NCURSES_LIB)
      target_link_libraries(${LUA_INTERPRETER_TARGET} PRIVATE ${LUA_NCURSES_LIB})
    elseif(LUA_TINFO_LIB)
      target_link_libraries(${LUA_INTERPRETER_TARGET} PRIVATE ${LUA_TINFO_LIB})
    elseif(LUA_TERMCAP_LIB)
      target_link_libraries(${LUA_INTERPRETER_TARGET} PRIVATE ${LUA_TERMCAP_LIB})
    endif()
  endif()
endif()

# ------------------------------------------------------------------------------
# Installation + CMake package export
# ------------------------------------------------------------------------------

if(LUA_BUILD_LIBRARY)
  install(
    FILES ${LUA_PUBLIC_HEADERS}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )

  # Install generated user header too, so consumers who rely on it can reproduce settings.
  install(
    FILES "${LUA_USER_HEADER}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )

  set(_install_targets ${LUA_LIBRARY_NAME})
  if(LUA_BUILD_INTERPRETER)
    list(APPEND _install_targets ${LUA_INTERPRETER_TARGET})
  endif()

  install(TARGETS ${_install_targets}
    EXPORT "${LUA_PROJECT_NAME}-targets"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  )

  set(cmake_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${LUA_PROJECT_NAME}")
  set(version_config    "${PROJECT_BINARY_DIR}/${LUA_PROJECT_NAME}-config-version.cmake")
  set(project_config    "${PROJECT_BINARY_DIR}/${LUA_PROJECT_NAME}-config.cmake")

  write_basic_package_version_file(
    "${version_config}"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY AnyNewerVersion
  )

  # Minimal config: just loads exported targets.
  set(package_name "${LUA_PROJECT_NAME}")
  set(targets_file "${LUA_PROJECT_NAME}-targets.cmake")
  configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/cmake/lua-config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${cmake_install_dir}"
  )

  install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${cmake_install_dir}"
  )

  install(
    EXPORT "${LUA_PROJECT_NAME}-targets"
    FILE "${LUA_PROJECT_NAME}-targets.cmake"
    NAMESPACE "${LUA_PROJECT_NAME}::"
    DESTINATION "${cmake_install_dir}"
  )
endif()
