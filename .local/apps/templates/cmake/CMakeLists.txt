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
find_package( fmt REQUIRED )

add_executable( {:lc:NAME:} )
target_sources( {:lc:NAME:}
  PRIVATE
  {:if:SRCS:}
  {:sp:SRCS:}
  {:else:SRCS:}
  {:qx:ls -1 *pp:}
  {:endif:SRCS:}
)
target_link_libraries(         {:lc:NAME:} PRIVATE fmt::fmt )
#> target_compile_definitions( {:lc:NAME:} PRIVATE MYEXAMPLE )
#> target_compile_features(    {:lc:NAME:} PUBLIC cxx_std_11 )
add_test( NAME {:TESTNAME:} COMMAND {:lc:NAME:} {:OPTIONS:} )

#> add_subdirectory( tests )

#> include(doxygen)

# vim:syntax=cmake:nospell
