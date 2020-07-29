# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# yasm
xpProOption(yasm)
set(VER 1.3.0)
set(REPO https://github.com/smanders/yasm)
set(PRO_YASM
  NAME yasm
  WEB "yasm" http://yasm.tortall.net/ "yasm website"
  LICENSE "open" ${REPO}/blob/v${VER}/COPYING "new BSD license"
  DESC "assembler and disassembler for the Intel x86 architecture"
  REPO "repo" ${REPO} "forked yasm repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/yasm.git
  GIT_UPSTREAM git://github.com/yasm/yasm.git
  GIT_TAG xp${VER}
  GIT_REF v${VER}
  DLURL http://www.tortall.net/projects/yasm/releases/yasm-${VER}.tar.gz
  DLMD5 fc9e586751ff789b34b1f21d572d96af
  PATCH ${PATCH_DIR}/yasm.patch
  DIFF ${REPO}/compare/yasm:
  )
########################################
function(build_yasm)
  if(NOT (XP_DEFAULT OR XP_PRO_YASM))
    return()
  endif()
  set(XP_CONFIGURE
    -DBUILD_SHARED_LIBS=OFF
    -DINSTALL_YASM_ONLY=ON
    )
  if(DEFINED XP_YASM_COMPLETE_PKG)
    xpGetArgValue(${PRO_YASM} ARG VER VALUE VER)
    list(APPEND XP_CONFIGURE -DYASM_VER=${VER})
    configure_file(${PRO_DIR}/use/usexp-yasm-config.cmake ${STAGE_DIR}/share/cmake/
      @ONLY NEWLINE_STYLE LF
      )
  endif()
  set(BUILD_CONFIGS Release) # we only need a release executable
  xpCmakeBuild(yasm "" "${XP_CONFIGURE}" yasmTargets)
  if(ARGN)
    set(${ARGN} "${yasmTargets}" PARENT_SCOPE)
    if(WIN32)
      set(ext ".exe")
    endif()
    set(YASM_EXE ${STAGE_DIR}/bin/yasm${ext} PARENT_SCOPE)
  endif()
endfunction()
