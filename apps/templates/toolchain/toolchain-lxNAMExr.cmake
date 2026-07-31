# {:NAME:}
#
# Invoke with cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/this/file

set( cxx       "{:CXX:}"       )
set( cc        "{:CC:}"        )
set( version   "{:VERSION:}"   )
set( system    "{:SYSTEM:}"    )
set( processor "{:PROCESSOR:}" )
set( vendor    "{:VENDOR:}"    )
set( major     "{:MAJOR:}"     )
set( minor     "{:MINOR:}"     )
set( tooldiir  "{:TOOLDIR:}"   )

# Set the system name
set( CMAKE_SYSTEM_NAME "${system}" )
set( CMAKE_SYSTEM_PROCESSOR "${processor}" )

# Specify the cross compiler
set( tooldir /usr/bin )
set( CMAKE_CXX_COMPILER ${tooldir}/${cxx}${version} )
set( CMAKE_C_COMPILER   ${tooldir}/${cc}${version} )

# Other compiler options
set( CMAKE_CXX_COMPILER_ID "${vendor}" )
set( CMAKE_CXX_COMPILER_VERSION "${major}.${minor}" )
set( CMAKE_CXX_FLAGS ${flags} )

# Where to look for the target environment
#set( CMAKE_FIND_ROOT_PATH ${tooldir}/arm-linux-gnueabihf )

# Search for headers and libraries in the target environment
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )
