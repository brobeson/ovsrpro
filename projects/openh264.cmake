xpProOption(openh264 DBG)
set(openh264_version 1.4.0)
set(REPO https://github.com/cisco/openh264)
# set(FORK https://github.com/smanders/openh264)
# set(DLBIN ${REPO}/releases/download/v${openh264_version})
set(PRO_OPENH264
  NAME openh264
  WEB "OpenH264" http://www.openh264.org/ "OpenH264 website"
  LICENSE "open" http://www.openh264.org/faq.html "Two-Clause BSD license"
  DESC "a codec library which supports H.264 encoding and decoding"
  REPO "repo" ${REPO} "openh264 repo on github"
  VER ${openh264_version}
  GIT_ORIGIN git://github.com/cisco/openh264.git
  GIT_TAG v${openh264_version}
  PATCH ${PATCH_DIR}/openh264.patch
  # DIFF ${FORK}/compare/cisco:
  DLURL ${REPO}/archive/v${openh264_version}.tar.gz
  DLMD5 ca77b91a7a33efb4c5e7c56a5c0f599f
  DLNAME openh264-${openh264_version}.tar.gz
  )

function(build_openh264)
  if(NOT (XP_DEFAULT OR XP_PRO_OPENH264))
    return()
  endif()
  if(NOT (XP_DEFAULT OR XP_PRO_YASM))
    message(STATUS "openh264.cmake: requires yasm")
    set(XP_PRO_YASM ON CACHE BOOL "include yasm" FORCE)
    xpPatchProject(${PRO_YASM})
  endif()
  build_yasm(yasmTgts)
  set(XP_CONFIGURE
    -DOPENH264_VER=${openh264_version}
    -DCMAKE_ASM_NASM_COMPILER=${YASM_EXE}
  )
  xpCmakeBuild(openh264 "${yasmTgts}" "${XP_CONFIGURE}" openh264Targets)
  if(ARGN)
    set(${ARGN} "${openh264Targets}" PARENT_SCOPE)
  endif()
endfunction()
