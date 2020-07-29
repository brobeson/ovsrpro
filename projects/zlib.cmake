# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# zlib
xpProOption(zlib DBG)
set(VER 1.2.8)
set(REPO https://github.com/smanders/zlib)
set(PRO_ZLIB
  NAME zlib
  WEB "zlib" http://zlib.net/ "zlib website"
  LICENSE "open" http://zlib.net/zlib_license.html "zlib license"
  DESC "compression library"
  REPO "repo" ${REPO} "forked zlib repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/zlib.git
  GIT_UPSTREAM git://github.com/madler/zlib.git
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF v${VER} # create patch from this tag to 'git checkout'
  DLURL http://zlib.net/fossils/zlib-${VER}.tar.gz
  DLMD5 44d667c142d7cda120332623eab69f40
  PATCH ${PATCH_DIR}/zlib.patch
  DIFF ${REPO}/compare/madler:
  )
########################################
function(build_zlib)
  if(NOT (XP_DEFAULT OR XP_PRO_ZLIB))
    return()
  endif()
  xpGetArgValue(${PRO_ZLIB} ARG VER VALUE VER)
  #configure_file(${PRO_DIR}/use/usexp-zlib-config.cmake ${STAGE_DIR}/share/cmake/
    #@ONLY NEWLINE_STYLE LF
    #)
  set(XP_CONFIGURE
    -DSKIP_INSTALL_SHARED_LIBRARIES=ON # only need static library
    -DSKIP_INSTALL_FILES=ON # no need for share/man and share/pkgconfig
    -DZLIB_VER=${VER}
    )
  xpCmakeBuild(zlib "" "${XP_CONFIGURE}" zlibTargets)
  if(ARGN)
    set(${ARGN} "${zlibTargets}" PARENT_SCOPE)
  endif()
endfunction()
