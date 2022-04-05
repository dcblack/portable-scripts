#!cmake .
#
# See $ENV{APPS}/cmake/ABOUT_CMAKE.md for more information.

cmake_minimum_required( VERSION 3.20 )

project( {:NAME:} VERSION {:VERS:} DESCRIPTION "{:DESC:}" LANGUAGES C CXX )

list( PREPEND CMAKE_MODULE_PATH "$ENV{PROJECT_DIR}/cmake" )
include( project_defaults )

# Packages for this project
find_package( fmt REQUIRED )

set_target( {:lc:NAME:} )
add_executable( "${TARGET}" )
target_sources( "${TARGET}" PRIVATE {:lc:NAME:}.cpp )
target_link_libraries( "${TARGET}" PRIVATE fmt::fmt )
#> target_compile_definitions( "${TARGET}" PRIVATE MYEXAMPLE )
#> target_compile_features(    "${TARGET}" PUBLIC cxx_std_11 )
add_test( NAME test-"${TARGET}" COMMAND "${TARGET}" {:OPTIONS:} )

#> add_subdirectory( tests )
#> include(doxygen)
# vim:syntax=cmake:nospell
