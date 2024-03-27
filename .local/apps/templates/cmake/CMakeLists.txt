#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.21 )

project(      {:NAME:}
  VERSION     {:VERS:}
  DESCRIPTION "{:DESC:}"
  LANGUAGES   C CXX
  )

list( PREPEND CMAKE_MODULE_PATH "$ENV{WORKTREE_DIR}/cmake" )
include( project_defaults )

# Packages for this project
find_package( fmt )

set( Target {:lc:NAME:} )
add_executable( "${Target}" )
target_sources( "${Target}"
  PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *pp:}
  {:endif:SRCS:}
)
if( fmt_FOUND )
  target_link_libraries( "${Target}" PRIVATE fmt::fmt )
endif()
#> target_compile_definitions( "${Target}" PRIVATE MYEXAMPLE )
#> target_compile_features(    "${Target}" PUBLIC cxx_std_11 )
add_test( NAME "${Target}-{:TESTNAME:}" COMMAND "${Target}" {:OPTIONS:} )

#> add_subdirectory( tests )

#> include(doxygen)

# vim:syntax=cmake:nospell
