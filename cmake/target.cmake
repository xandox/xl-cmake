set(XL_TARGET_EXE "executable")
set(XL_TARGET_STATIC "static-library")
set(XL_TARGET_SHARED "shared-library")
set(XL_TARGET_INTERFACE "interface-library")

macro(xl_add_target)
    set(_flags)
    set(_args HEADERS_DIR HEADERS_PREFIX SOURCES_PREFIX TARGET_TYPE TARGET_NAME)
    set(_kwargs SOURCES HEADERS PRIVATED_DEPS PUBLIC_DEPS INTERFACE_DEPS)
    cmake_parse_arguments(_at "${_flags}" "${_args}" "${_kwargs}" ${ARGN})

    xl_set_default_value(_at_HEADERS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
    xl_set_default_value(_at_SOURCE_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/src)
    xl_assert_defined(_at_TARGET_NAME "TARGET_NAME is required for add_target macro")
    xl_assert_defined(_at_HEADERS_PREFIX "HEADERS_PREFIX is required argument for add_target macro")
    xl_assert_defined(_at_TARGET_TYPE "TARGET_TYPE is required argument for add_target macro")

    if (NOT _at_TARGET_TYPE STREQUAL XL_TARGET_INTERFACE)
        _assert_defined(_at_SOURCES "SOURCES is required argument for add_target macro if TARGET_TYPE not ${XL_TARGET_INTERFACE}")
    endif()

    xl_add_prefix(_target_sources ${_at_SOURCE_PREFIX} "/" ${_at_SOURCES})
    xl_add_prefix(_target_headers ${_at_HEADERS_DIR}/${_at_HEADERS_PREFIX} "/" ${_at_HEADERS})

    set(_public PUBLIC)
    set(_target_output ${_at_TARGET_NAME})

    if (_at_TARGET_TYPE STREQUAL XL_TARGET_EXE)
        add_executable(${_at_TARGET_NAME} ${_target_sources} ${_target_headers})
        string(REGEX REPLACE "^exe-" "" _target_output "${_at_TARGET_NAME}")
    elseif(_at_TARGET_TYPE STREQUAL XL_TARGET_STATIC)
        add_library(${_at_TARGET_NAME} STATIC ${_target_sources} ${_target_headers})
        string(REGEX REPLACE "^lib-" "" _target_output "${_at_TARGET_NAME}")
    elseif(_at_TARGET_TYPE STREQUAL XL_TARGET_SHARED)
        add_library(${_at_TARGET_NAME} SHARED ${_target_sources} ${_target_headers})
        string(REGEX REPLACE "^dll-" "" _target_output "${_at_TARGET_NAME}")
    elseif(_at_TARGET_TYPE STREQUAL XL_TARGET_INTERFACE)
        add_library(${_at_TARGET_NAME} INTERFACE ${_target_headers})
        set(_public INTERFACE)
    else()
        message(FATAL_ERROR "Unknown or unsupported target type '${_at_TARGET_TYPE}'")
    endif()
    target_include_directories(${_at_TARGET_NAME} ${_public} ${_at_HEADERS_DIR})


    xl_debug_var(_target_output)
    set_target_properties(${_at_TARGET_NAME} PROPERTIES OUTPUT_NAME ${_target_output})
endmacro()

macro(xl_add_static_lib)
    xl_add_target(TARGET_TYPE ${XL_TARGET_STATIC} ${ARGN})
endmacro()

macro(xl_add_shared_lib)
    xl_add_target(TARGET_TYPE ${XL_TARGET_SHARED} ${ARGN})
endmacro()
    
macro(xl_add_exe)
    xl_add_target(TARGET_TYPE ${XL_TARGET_EXE} ${ARGN})
endmacro()

macro(xl_add_interface)
    xl_add_target(TARGET_TYPE ${XL_TARGET_INTERFACE} ${ARGN})
endmacro()
