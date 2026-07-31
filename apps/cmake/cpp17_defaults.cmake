#!cmake .
#
# Some sensible minimum setup (can use for project defaults)

cmake_minimum_required (VERSION 3.20)

#------------------------------------------------------------------------------
# Choose minimum C++ standard for remainder of code
#------------------------------------------------------------------------------
set( CMAKE_CXX_STANDARD          17 CACHE STRING "C++ standard to build all targets." )
set( CMAKE_CXX_STANDARD_REQUIRED 17 CACHE BOOL   "The CMAKE_CXX_STANDARD selected C++ standard is a requirement." )


#------------------------------------------------------------------------------
# If using local installation of libraries
#------------------------------------------------------------------------------
if( EXISTS $ENV{WORKTREE_DIR}/extern )
  include_directories( $ENV{WORKTREE_DIR}/extern/include )
  link_directories( $ENV{WORKTREE_DIR}/extern/lib )
endif()

#------------------------------------------------------------------------------
# Setup Boost if available
#------------------------------------------------------------------------------
find_package( Boost )
if( Boost_FOUND )
  message( VERBOSE "Boost found and available" )
  include_directories( ${Boost_INCLUDE_DIRS} )
endif()

#------------------------------------------------------------------------------
# Setup GoogleTest
#------------------------------------------------------------------------------
find_package( GTest )
if( GTest_FOUND )
  message( VERBOSE "GTest found and available" )
  include_directories( ${GTEST_INCLUDE_DIRS} )
  link_libraries(  GTest::gtest GTest::gmock GTest::gtest_main pthread )
endif()

#-------------------------------------------------------------------------------
# Increase sensitivity to all warnings
#-------------------------------------------------------------------------------
include( strict )  # << Report as many compilation issues as able

enable_testing()

# vim:syntax=cmake:nospell
