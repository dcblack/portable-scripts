cmake_minimum_required ( VERSION 3.17 )

macro( set_target target )
  set( Target "${target}" )
  list( LENGTH Targets count )
  if( ${count} EQUAL 1)
    list( GET Targets 0 first )
    if( "${first}" STREQUAL "${PROJECT_NAME}" )
      list( REMOVE_AT Targets 0 )
    endif()
  endif()
  list( APPEND Targets "${target}" )
endmacro()

# Default
set_target( ${PROJECT_NAME} )

# vim:nospell
