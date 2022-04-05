cmake_minimum_required( VERSION "3.20" )

macro( set_target target )
  set( TARGET "${target}" )
  list( APPEND TARGETS "${target}" )
endmacro()

# vim:nospell
