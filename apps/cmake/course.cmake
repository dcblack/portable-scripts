if (MSVC)
    # warning level 4
    add_compile_options( /W4 )
else()
    # lots of warnings except unused parameters (slightly permissive)
    add_compile_options( -Wall -Wextra -pedantic -Wno-unused-parameter)
endif()
