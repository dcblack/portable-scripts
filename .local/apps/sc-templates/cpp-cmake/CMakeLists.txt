#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.11 )

project(      {:NAME:}
  VERSION     {:VERS:} # n.n[.n[.n]]
  DESCRIPTION "{:DESC:}"
  LANGUAGES   CXX
  )

if( NOT EXISTS ENV{APPS} AND IS_DIRECTORY $ENV{HOME}/.local/apps/cmake )
  set( ENV{APPS} $ENV{HOME}/.local/apps )
endif()
if( NOT IS_DIRECTORY $ENV{APPS}/cmake )
  message( ERROR "Missing or incorrectly set APPS environment variable." )
endif()
list( APPEND CMAKE_MODULE_PATH $ENV{APPS}/cmake )

include( strict )
include( BuildTypes )
set( CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard to build all targets." )
set( CMAKE_CXX_STANDARD_REQUIRED 17 CACHE BOOL "Minimum CMAKE_CXX_STANDARD selected C++ standard is a requirement." )

# Packages
find_package( fmt REQUIRED )
#find_package( yaml-cpp CONFIG REQUIRED )
#find_package( Boost REQUIRED filesystem )

# add a target to generate API documentation with Doxygen
find_package( Doxygen REQUIRED dot )
if( DOXYGEN_FOUND )
  set( DOXYGEN_OUTPUT_DIRECTORY ../doc )
  set( DOXYGEN_IMAGE_PATH .. )
  set( DOXYGEN_EXTRACT_ALL yes )
  set( DOXYGEN_EXTRACT_PRIVATE yes )
  set( DOXYGEN_EXTRACT_STATIC yes )
  set( DOXYGEN_TOC_INCLUDE_HEADINGS 1 )
  set( DOXYGEN_EXCLUDE_PATTERNS */build*/* )
  doxygen_add_docs( docs )
endif( DOXYGEN_FOUND )

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
