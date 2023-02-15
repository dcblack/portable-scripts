# Things we want for all CMake compilations

#-------------------------------------------------------------------------------
# Don't allow in-source compilation
#-------------------------------------------------------------------------------
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed")
endif()

set( CMAKE_FIND_PACKAGE_PREFER_CONFIG ON )

#-------------------------------------------------------------------------------
# Extend module path
#-------------------------------------------------------------------------------
if( DEFINED ENV{WORKTREE_DIR} )
  set( PROJECT_DIRS "$ENV{WORKTREE_DIR}/extern;$ENV{APPS}" )
  foreach( _dir ${PROJECT_DIRS} )
     if( EXISTS "${_dir}" )
       list( APPEND CMAKE_PREFIX_PATH "${_dir}" )
     endif()
  endforeach()
  list( REMOVE_DUPLICATES CMAKE_PREFIX_PATH )
  include_directories( . "$ENV{WORKTREE_DIR}/include" "$ENV{WORKTREE_DIR}/extern/include" )
else()
  message( WARNING "WORKTREE_DIR environment variable was not defined" )
endif()

#-------------------------------------------------------------------------------
# Increase sensitivity to all warnings
#-------------------------------------------------------------------------------
if (MSVC)
    # warning level 4
    add_compile_options( /W4 )
else()
    # lots of warnings
    add_compile_options( -Wall -Wextra -pedantic )
endif()

#------------------------------------------------------------------------------
# Choose minimum C++ standard for remainder of code
#------------------------------------------------------------------------------
if( NOT DEFINED USE_CXX_VERSION )
  set( USE_CXX_VERSION 17 )
endif()
if( NOT DEFINED USE_C_VERSION )
  set( USE_C_VERSION 11 )
endif()
set( CMAKE_CXX_STANDARD          ${USE_CXX_VERSION} CACHE STRING "C++ standard to build all targets." )
set( CMAKE_CXX_STANDARD_REQUIRED ${USE_CXX_VERSION} CACHE BOOL   "The CMAKE_CXX_STANDARD selected C++ standard is a requirement." )
set( CMAKE_C_STANDARD            ${USE_C_VERSION}   CACHE STRING "C standard to build all targets." )
set( CMAKE_C_STANDARD_REQUIRED   ${USE_C_VERSION}   CACHE BOOL   "The CMAKE_CXX_STANDARD selected C standard is a requirement." )
set( CMAKE_CXX_EXTENSIONS NO )

enable_testing()

include( set_target )

