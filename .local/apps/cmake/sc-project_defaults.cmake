#!cmake .
cmake_minimum_required ( VERSION 3.21 )

# Header style guard for multiple inclusion protection
if( DEFINED PROJECT_DEFAULTS )
  return()
endif()
set( MODERN_CMAKE_UTILS ON )

#-------------------------------------------------------------------------------
# Extend module path
#-------------------------------------------------------------------------------
if( DEFINED ENV{CMAKE_PREFIX_PATH} )
  foreach( _dir $ENV{CMAKE_PREFIX_PATH} )
    if( EXISTS "${_dir}" )
      list( INSERT CMAKE_MODULE_PATH 1 "${_dir}" )
    endif()
  endforeach()
endif()
list( REMOVE_DUPLICATES CMAKE_MODULE_PATH )

#-------------------------------------------------------------------------------
# Increase sensitivity to all warnings
#-------------------------------------------------------------------------------
include( strict )  # << Report as many compilation issues as able

#------------------------------------------------------------------------------
# Choose minimum C++ standard for remainder of code
#------------------------------------------------------------------------------
set( CMAKE_CXX_STANDARD          17 CACHE STRING "C++ standard to build all targets." )
set( CMAKE_CXX_STANDARD_REQUIRED 17 CACHE BOOL   "The CMAKE_CXX_STANDARD selected C++ standard is a requirement." )
set( CMAKE_C_STANDARD            11 CACHE STRING "C standard to build all targets." )
set( CMAKE_C_STANDARD_REQUIRED   11 CACHE BOOL   "The CMAKE_CXX_STANDARD selected C standard is a requirement." )

if( DEFINED ENV{SYSTEMC_HOME} )
  include( SystemC )
else()
  message( SEND_ERROR "SYSTEMC_HOME environment variable needs to be setup" )
endif()

enable_testing()

include( set_target )

# Simplify life
add_compile_definitions( SC_INCLUDE_FX SC_INCLUDE_DYNAMIC_PROCESSES )

# vim:nospell
