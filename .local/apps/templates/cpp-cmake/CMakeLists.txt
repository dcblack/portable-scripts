#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.11 )

project(      {:NAME:}
  VERSION     {:VERS:} # n.n[.n[.n]]
  DESCRIPTION "{:DESC:}"
  LANGUAGES   CXX
  )
set( CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};$ENV{CMAKE_MODULE_PATH}" )
include( project_defaults )

# Packages as needed
find_package( fmt REQUIRED )
#find_package( yaml-cpp CONFIG REQUIRED )
#find_package( Boost REQUIRED filesystem )

add_executable( {:NAME:} )
target_include_directories( {:lc:NAME:} PRIVATE . )
target_sources( {:lc:NAME:} PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *.cpp:}
  {:endif:SRCS:}
)

# vim:syntax=cmake:nospell
