# Insist on full C++ compliance

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (MSVC)
    # warning level 4
    add_compile_options( /W4 )
else()
    # lots of warnings
    add_compile_options( -Wall -Wextra -pedantic )
endif()
