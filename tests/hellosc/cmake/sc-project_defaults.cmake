#!cmake .
cmake_minimum_required ( VERSION 3.20 )

include_guard( GLOBAL )

message( "Setting up cmake" )

include( policy )

if( DEFINED ENV{SYSTEMC_HOME} )
  include( systemc )
else()
  message( SEND_ERROR "SYSTEMC_HOME environment variable needs to be setup" )
endif()

# Simplify life
add_compile_definitions( SC_INCLUDE_FX SC_INCLUDE_DYNAMIC_PROCESSES )

# vim:nospell
