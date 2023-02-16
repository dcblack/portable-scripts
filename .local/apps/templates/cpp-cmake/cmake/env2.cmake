cmake_minimum_required ( VERSION 3.18 )

# Reads a script and extracts the environment variables
macro( env2 filename )
  find_program( env2_exe NAMES env2 )
  set( env2_val "unknown" )
  if( EXISTS "${filename}" )
    execute_process( COMMAND "${env2_exe}" --ignore PATH --to cmake "${filename}" OUTPUT_VARIABLE env2_val )
  elseif( DEFINED "ENV{WORKTREE_DIR}" AND EXISTS "$ENV{WORKTREE_DIR}/${filename}" )
    execute_process( COMMAND "${env2_exe}" --ignore PATH --to cmake "$ENV{WORKTREE_DIR}/${filename}" OUTPUT_VARIABLE env2_val )
  else()
    find_program( git_exe NAMES git )
    execute_process( COMMAND "${git_exe}" rev-parse --show-toplevel OUTPUT_VARIABLE worktree_dir )
    if( is_directory "${worktree_dir}" )
      execute_process( COMMAND "${env2_exe}" --ignore PATH --to cmake "${worktree_dir}/${filename}" OUTPUT_VARIABLE env2_val )
    else()
      message( SENDERROR "Unable to locate ${filename}" )
    endif()
  endif()
  cmake_language( EVAL CODE "${env2_val}" )
endmacro()

# vim:nospell
