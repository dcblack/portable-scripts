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

cmake_minimum_required( VERSION 3.11 )

project(      {:NAME:}
  VERSION     {:VERS:} # n.n[.n[.n]]
  DESCRIPTION "{:DESCRIPTION:}"
  LANGUAGES   CXX
  )
set( CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};$ENV{CMAKE_MODULE_PATH}" )
include( project_defaults )
include( systemc_defaults ) #< could move to project defaults

# Packages
find_package( fmt REQUIRED )
#find_package( yaml-cpp CONFIG REQUIRED )
#find_package( Boost REQUIRED filesystem )

add_executable( {:lc:NAME:} )
target_include_directories( {:lc:NAME:} PRIVATE . )
target_sources( {:lc:NAME:} PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *.cpp:}
  {:endif:SRCS:}
)
# Uncomment the following only as needed
#> target_compile_definitions( {:NAME:} PRIVATE MYEXAMPLE )
#> target_link_libraries( {:NAME:} yaml-cpp )
#> target_compile_features( {:NAME:} PUBLIC cxx_std_11 )
#> target_include_directories( {:NAME:} includes )

# vim:syntax=cmake:nospell
