cmake_minimum_required ( VERSION 3.21 )

macro( set_target target )
  set( Target "${target}" )
  list( APPEND TARGETS "${target}" )
endmacro()

# vim:nospell
