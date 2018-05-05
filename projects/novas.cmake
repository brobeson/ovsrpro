########################################
# novas 
########################################
xpProOption(novas)
set(NOVAS_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/novas)
if(WIN32)
  set(NOVAS_DLURL http://aa.usno.navy.mil/software/novas/novas_c/novasc3.1.zip)
  set(NOVAS_DLMD5 23429099025999970b2e5497c57a1e21)
else()
  set(NOVAS_DLURL http://aa.usno.navy.mil/software/novas/novas_c/novasc3.1.tar.gz)
  set(NOVAS_DLMD5 f5dd6f7930b18616154b33aae1ef02d6)
endif()
set(PRO_NOVAS
  NAME novas
  WEB "NOVAS" http://aa.usno.navy.mil/software/novas/novas_info.php "NOVAS"
  LICENSE "open" http://aa.usno.navy.mil/software/novas/novas_c/README.txt "(See Section IV. Using NOVAS in Your Applications)"
  DESC "NOVAS is an integrated package of ANSI C functions for computing many commonly needed quantities in positional astronomy."
  VER 3.1
  DLURL ${NOVAS_DLURL}
  DLMD5 ${NOVAS_DLMD5}
  PATCH ${PATCH_DIR}/novas.patch
)
########################################
function(build_novas)
  if (NOT (XP_DEFAULT OR XP_PRO_NOVAS))
    return()
  endif()
  configure_file(${PRO_DIR}/use/useop-novas-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
  )

  xpCmakeBuild(novas)

endfunction()
