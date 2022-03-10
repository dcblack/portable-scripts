#!cmake .
#
# Some sensible minimums for SystemC

cmake_minimum_required (VERSION 3.20)


set( CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard to build all targets." )
set( CMAKE_CXX_STANDARD_REQUIRED 17 CACHE BOOL "The with CMAKE_CXX_STANDARD selected C++ standard is a requirement." )

include( SystemC )
include( strict )
include( BuildTypes )

add_compile_definitions( SC_INCLUDE_FX SC_INCLUDE_DYNAMIC_PROCESSES )
