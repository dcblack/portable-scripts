#!cmake .
cmake_minimum_required( VERSION "3.20" )

macro ( show_vars )
  message( "WORKTREE_DIR=$ENV{WORKTREE_DIR}" )
  message( "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}" )
  message( "CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}" )
  message( "SYSTEMC_HOME=$ENV{SYSTEMC_HOME}" )
  message( "SystemC_CXX_STANDARD=${SystemC_CXX_STANDARD}" )
  message( "CMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}" )
endmacro()
