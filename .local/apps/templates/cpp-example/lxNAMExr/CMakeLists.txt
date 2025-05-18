#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.20 )

project( {:NAME:}
  VERSION {:VERS:}
  DESCRIPTION "{:DESC:}"
  LANGUAGES CXX
)
set( USE_CXX_VERSION 17 )

#-------------------------------------------------------------------------------
# Find project directory containing defaults
#-------------------------------------------------------------------------------
set( defaults "project_defaults" )
set( _dir "${CMAKE_CURRENT_SOURCE_DIR}" )
cmake_path( GET _dir ROOT_PATH _root )
while( NOT EXISTS "${_dir}/cmake/${defaults}.cmake" )
  cmake_path( GET _dir PARENT_PATH _dir )
  if( "${_dir}" STREQUAL "${_root}" )
    message( FATAL_ERROR "Unable to find project working tree directory!" )
  endif()
endwhile()
set( WORKTREE_DIR "${_dir}" CACHE PATH "Contains cmake/${defaults}.cmake" )
list( PREPEND CMAKE_MODULE_PATH "${WORKTREE_DIR}/cmake" )
include( "${defaults}" )

# Packages for this project
find_package( fmt )

#-------------------------------------------------------------------------------
# Code
#-------------------------------------------------------------------------------
set_target( {:lc:NAME:} )
add_executable( "${Target}" )
target_sources( "${Target}"
  PRIVATE
  {:lc:NAME:}.hpp
  {:lc:NAME:}.cpp
  main.cpp
  )
if( fmt_FOUND )
  target_link_libraries( "${Target}" PRIVATE fmt::fmt )
endif()
#> target_compile_definitions( "${Target}" PRIVATE MYEXAMPLE )
#> target_compile_features(    "${Target}" PUBLIC cxx_std_11 )
add_test(
  NAME test-"${Target}"
  COMMAND "${Target}" )

# vim:syntax=cmake:nospell
