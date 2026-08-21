#!cmake -S . -B .

# IMPORTANT: Do not modify this file.

cmake_minimum_required( VERSION 3.20 )

project( "cpp-hello-bad-link"
  VERSION 0.1
  DESCRIPTION "C++ hello world won't link"
  LANGUAGES CXX
)

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

set_target( "${PROJECT_NAME}" )
add_executable( "${Target}" )
target_sources( "${Target}" PRIVATE cpp-hello.cpp )
add_test( NAME "${Target}" COMMAND "${Target}" )

# vim:syntax=cmake:nospell
