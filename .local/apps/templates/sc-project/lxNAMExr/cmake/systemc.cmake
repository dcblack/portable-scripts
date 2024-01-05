#!cmake .

# SystemC specific needs
find_package( SystemCLanguage CONFIG REQUIRED PATHS "$ENV{SYSTEMC_HOME}" )

set ( CMAKE_CXX_STANDARD ${SystemC_CXX_STANDARD} CACHE STRING "C++ standard to build all targets. Supported values are 98, 11, 14, and 17." )
set ( CMAKE_CXX_STANDARD_REQUIRED ${SystemC_CXX_STANDARD_REQUIRED} CACHE BOOL "The CMAKE_CXX_STANDARD selected C++ standard is a requirement." )
set ( SC_ALLOW_DEPRECATED_IEEE_API 1 CACHE BOOL "Allow deprecated SystemC features such as SC_HAS_PROCESS" )

if( ${SC_ALLOW_DEPRECATED_IEEE_API} EQUAL 1 )
  add_compile_definitions( SC_ALLOW_DEPRECATED_IEEE_API )
endif()
link_libraries( SystemC::systemc )
