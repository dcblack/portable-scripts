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

# Packages
find_package( fmt REQUIRED )
#find_package( yaml-cpp CONFIG REQUIRED )
#find_package( Boost REQUIRED filesystem )

# add a target to generate API documentation with Doxygen

add_executable( {:NAME:} )
target_include_directories( {:lc:NAME:} PRIVATE . )
target_sources( {:lc:NAME:} PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *.cpp:}
  {:endif:SRCS:}
)
add_test( ex9 COMMAND ./ex9-ans )

# Uncomment the following only as needed
#> target_compile_definitions( {:NAME:} PRIVATE MYEXAMPLE )
#> target_link_libraries( {:NAME:} fmt )
#> target_link_libraries( {:NAME:} yaml-cpp )
#> target_compile_features( {:NAME:} PUBLIC cxx_std_11 )
#> target_include_directories( {:NAME:} includes )
#>
#> include(doxygen)

# vim:syntax=cmake:nospell
