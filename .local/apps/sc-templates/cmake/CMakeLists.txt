#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.11 )

project(      {:NAME:}
  VERSION     {:VERS:} # n.n[.n[.n]]
  DESCRIPTION "{:DESC:}"
  LANGUAGES   CXX
  )

set( default_build_type "Debug" )
set( CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard to build all targets." )
set( CMAKE_CXX_STANDARD_REQUIRED 17 CACHE BOOL "The with CMAKE_CXX_STANDARD selected C++ standard is a requirement." )
include( $ENV{APPS}/cmake/strict.cmake )
include( $ENV{APPS}/cmake/BuildTypes.cmake )

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

# Uncomment the following only as needed
#> target_compile_definitions( {:NAME:} PRIVATE MYEXAMPLE )
target_link_libraries( {:NAME:} fmt )
#> target_link_libraries( {:NAME:} yaml-cpp )
#> target_compile_features( {:NAME:} PUBLIC cxx_std_11 )
#> target_include_directories( {:NAME:} includes )

# vim:syntax=cmake:nospell
