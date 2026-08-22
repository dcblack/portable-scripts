#!/usr/bin/env build

# Source setup.profile if needed

cmake_minimum_required( VERSION 3.20 )

project( HelloSystemC VERSION 6.2 DESCRIPTION "Hello SystemC" LANGUAGES CXX )

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

#-------------------------------------------------------------------------------
# Example specific

add_executable( hellosc hellosc.cpp )
add_test( NAME hellosc COMMAND hellosc )
set_tests_properties( hellosc PROPERTIES LABELS "sample" PASS_REGULAR_EXPRESSION "Hello SystemC" )
