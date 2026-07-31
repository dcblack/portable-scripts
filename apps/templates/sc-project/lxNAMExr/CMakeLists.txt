#!cmake .
#
# This works with SystemC versions 2.3.2 and later, which have support for
# cmake and specify SystemC_CXX_STANDARD.
#
# REQUIREMENTS:
# - Adjust ../../setup.profile if needed

cmake_minimum_required( VERSION 3.20 )

project( {:NAME:} VERSION 0.1 DESCRIPTION "{:DESC:}" LANGUAGES CXX )

#-------------------------------------------------------------------------------
# Find project directory containing defaults
#-------------------------------------------------------------------------------
set( defaults "sc-project_defaults" )
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

# Packages
find_package( fmt )

#-------------------------------------------------------------------------------
# Code
#-------------------------------------------------------------------------------
set_target( "${PROJECT_NAME}" )
add_executable( "${Target}" )
target_sources( "${Target}" PRIVATE
  {:lc:NAME:}.hpp
  {:lc:NAME:}.cpp
  main.cpp
)
if( fmt_FOUND )
  target_link_libraries( "${Target}" PRIVATE fmt::fmt )
endif()
add_test( NAME "${Target}" COMMAND "${Target}" )
set_tests_properties( "${Target}" PROPERTIES LABELS "exercise;${PROJECT_NAME}" )

#TAF!

