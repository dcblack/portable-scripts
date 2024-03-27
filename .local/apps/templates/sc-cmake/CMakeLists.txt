#!cmake .
#
# This works with SystemC versions 2.3.2 and later, which have support for
# cmake and specify SystemC_CXX_STANDARD.
#
# REQUIREMENTS:
#   Define SYSTEMC_HOME to point to install directory of SystemC (not source)
#   that has been built with CMake.
#
# See $ENV{SCC_APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.20 )

project(      {:NAME:}
  VERSION     {:VERS:} # n.n[.n[.n]]
  DESCRIPTION "{:DESCRIPTION:}"
  LANGUAGES   CXX
  )
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
find_package( fmt REQUIRED )

set_target( {:lc:NAME:} )
add_executable( "${Target}" )
target_include_directories( "${Target}" PRIVATE . )
target_sources( "${Target}" PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *.cpp:}
  {:endif:SRCS:}
)
if( fmt_FOUND )
  target_link_libraries( "${Target}" PRIVATE fmt::fmt )
endif()
add_test( NAME "${Target}-{:TESTNAME:}" COMMAND "${Target}" {:OPTIONS:} )

# vim:syntax=cmake:nospell
