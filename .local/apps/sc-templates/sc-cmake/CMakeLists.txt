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
  LANGUAGES   CXX C
  )

set( TARGET_NAME {:lc:NAME:} )
set( default_build_type "Debug" )

include( $ENV{SCC_APPS}/cmake/SystemC.cmake )
include( $ENV{SCC_APPS}/cmake/strict.cmake )
include( $ENV{SCC_APPS}/cmake/BuildTypes.cmake )
#find_package( yaml-cpp CONFIG REQUIRED )
#find_package( Boost 1.65 REQUIRED filesystem )

add_compile_definitions( SC_INCLUDE_FX SC_INCLUDE_DYNAMIC_PROCESSES )

add_executable( {:lc:NAME:} )
target_include_directories( {:lc:NAME:} PRIVATE . )
target_sources( {:lc:NAME:} PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *.cpp:}
  {:endif:SRCS:}
)
# Uncomment the following only if specifically needed
#> target_compile_definitions( {:NAME:} PRIVATE MYEXAMPLE )
#> target_link_libraries( {:NAME:} yaml-cpp )
#> target_compile_features( {:NAME:} PUBLIC cxx_std_11 )
#> target_include_directories( {:NAME:} includes )

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

# TAF! vim:syntax=cmake:nospell
