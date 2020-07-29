# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# glew
set(GLEW_MSWVER 1.7.0)
set(GLEW_BLDVER 1.13.0)
########################################
function(build_glew)
  if(NOT (XP_DEFAULT OR XP_PRO_GLEW_${GLEW_MSWVER} OR XP_PRO_GLEW_${GLEW_BLDVER}))
    return()
  endif()
  configure_file(${PRO_DIR}/use/usexp-glew-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
endfunction()
