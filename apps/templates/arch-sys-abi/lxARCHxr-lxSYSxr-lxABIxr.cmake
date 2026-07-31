
# Target platform
set( CMAKE_SYSTEM_NAME        {:target_system:} )
set( CMAKE_SYSTEM_PROCESSOR   {:target_system:} )

# Executables
set( CMAKE_AR                 {:path_to_ar:}      )
set( CMAKE_ASM_COMPILER       {:path_to_as:}      )
set( CMAKE_C_COMPILER         {:path_to_c:}       )
set( CMAKE_CXX_COMPILER       {:path_to_cpp:}     )
set( CMAKE_LINKER             {:path_to_ld:}      )
set( CMAKE_OBJCOPY            {:path_to_objcopy:} )
set( CMAKE_RANLIB             {:path_to_ranlib:}  )
set( CMAKE_SIZE               {:path_to_size:}    )
set( CMAKE_STRIP              {:path_to_strip:}   )

# Compilation and linking flags
set( CMAKE_C_FLAGS            {:c_flags:}               )
set( CMAKE_CXX_FLAGS          {:cpp_flags:}             )
set( CMAKE_C_FLAGS_DEBUG      {:c_flags_for_debug:}     )
set( CMAKE_C_FLAGS_RELASE     {:c_flags_for_release:}   )
set( CMAKE_CXX_FLAGS_DEBUG    {:cpp_flags_for_debug:}   )
set( CMAKE_CXX_FLAGS_RELASE   {:cpp_flags_for_release:} )
set( CMAKE_EXE_LINKER_FLAGS   {:linker_flags:}          )

# Toolchain sysroot settings
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM  NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY  ONLY  )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE  ONLY  )

# Optionally reduce compiler sanity check when cross-compiling
SET( CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY )
