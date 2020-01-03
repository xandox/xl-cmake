
option(XL_CMAKE_DEBUG "xl-cmake in DEBUG mode" OFF)


macro(xl_debug_var in_var)
    if (XL_CMAKE_DEBUG)
        message(STATUS "[XL_DEBUG_VAR] ${in_var} == ${${in_var}}")
    endif()
endmacro()

macro(xl_log)
    message(STATUS "[XL_LOG I] ${ARGN}")
endmacro()

macro(xl_log_warn)
    message(AUTHOR_WARNING "[XL_LOG W] ${ARGN}")
endmacro()

macro(xl_log_error)
    message(FATAL_ERROR "[XL_LOG E] ${ARGN}")
endmacro()

macro(xl_log_debug)
    if (XL_CMAKE_DEBUG)
        message(STATUS "[XL_LOG D] ${in_var} == ${${in_var}}")
    endif()
endmacro()

macro(xl_set_default_value in_variable in_default_value)
    if (NOT DEFINED ${in_variable})
        set(${in_variable} ${in_default_value})
    endif()
endmacro()

macro(xl_assert_defined in_variable in_msg)
    if (NOT DEFINED ${in_variable})
        xl_log_error(${in_msg})
    endif()
endmacro()

macro(xl_add_prefix out_list in_prefix in_sep in_list)
    set(${out_list})
    foreach (item ${in_list})
        list(APPEND ${out_list} ${in_prefix}${in_sep}${item})
    endforeach()
endmacro()
