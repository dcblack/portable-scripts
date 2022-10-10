#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.20 )

project( {:NAME:} VERSION {:VERS:} DESCRIPTION "{:DESC:}" LANGUAGES C CXX )

# Determine the working tree directory where cmake files are stored
if( NOT DEFINED ENV{WORKTREE_DIR} )
  exec_program( git ARGS -C ${CMAKE_CURRENT_SOURCE_DIR} rev-parse --show-toplevel OUTPUT_VARIABLE WORKTREE_DIR )
  set( ENV{WORKTREE_DIR} "${WORKTREE_DIR}" )
endif()
message( "WORKTREE_DIR=$ENV{WORKTREE_DIR}" )

list( PREPEND CMAKE_MODULE_PATH "$ENV{WORKTREE_DIR}/cmake" )
include( project_defaults )

# Packages for this project
find_package( fmt REQUIRED )

set_target( {:lc:NAME:} )
add_executable( "${Target}" )
target_sources( "${Target}" PRIVATE {:lc:NAME:}.cpp )
target_link_libraries( "${Target}" PRIVATE fmt::fmt )
#> target_compile_definitions( "${Target}" PRIVATE MYEXAMPLE )
#> target_compile_features(    "${Target}" PUBLIC cxx_std_11 )
add_test( NAME test-"${Target}" COMMAND "${Target}" {:OPTIONS:} )

#> add_subdirectory( tests )
#> include(doxygen)
# vim:syntax=cmake:nospell
