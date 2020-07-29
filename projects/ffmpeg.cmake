# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# ffmpeg
xpProOption(ffmpeg)
set(FFMPEG_MSWVER 2.6.2.1)
set(FFMPEG_CFGVER 2.6.2)
########################################
function(patch_ffmpeg)
  set(mswVer ${FFMPEG_MSWVER})
  set(cfgVer ${FFMPEG_CFGVER})
  if(NOT (XP_DEFAULT OR XP_PRO_FFMPEG OR XP_PRO_FFMPEG_${mswVer} OR XP_PRO_FFMPEG_${cfgVer}))
    return()
  endif()
  if(XP_DEFAULT) # edit this to set default versions(s) to build
    if(WIN32)
      xpListAppendIfDne(FFMPEG_VERSIONS ${mswVer})
    else()
      xpListAppendIfDne(FFMPEG_VERSIONS ${cfgVer})
    endif()
  else()
    if(XP_PRO_FFMPEG AND NOT (XP_PRO_FFMPEG_${mswVer} OR XP_PRO_FFMPEG_${cfgVer}))
      if(WIN32)
        set(XP_PRO_FFMPEG_${mswVer} ON CACHE BOOL "include ffmpeg_${mswVer}" FORCE)
      else()
        set(XP_PRO_FFMPEG_${cfgVer} ON CACHE BOOL "include ffmpeg_${cfgVer}" FORCE)
      endif()
    endif()
    if(XP_PRO_FFMPEG_${mswVer})
      xpListAppendIfDne(FFMPEG_VERSIONS ${mswVer})
    endif()
    if(XP_PRO_FFMPEG_${cfgVer})
      xpListAppendIfDne(FFMPEG_VERSIONS ${cfgVer})
    endif()
  endif()
  set(FFMPEG_VERSIONS ${FFMPEG_VERSIONS} PARENT_SCOPE) # make FFMPEG_VERSIONS available to build_ffmpeg
endfunction()
########################################
function(build_ffmpeg)
  set(mswVer ${FFMPEG_MSWVER})
  set(cfgVer ${FFMPEG_CFGVER})
  if(NOT (XP_DEFAULT OR XP_PRO_FFMPEG_${mswVer} OR XP_PRO_FFMPEG_${cfgVer}))
    return()
  endif()
  if(WIN32)
    set(VER ${mswVer})
  else()
    set(VER ${cfgVer})
  endif()
  #configure_file(${PRO_DIR}/use/usexp-ffmpeg-config.cmake ${STAGE_DIR}/share/cmake/
    #@ONLY NEWLINE_STYLE LF
    #)
  foreach(ver ${FFMPEG_VERSIONS})
    build_ffmpegv(VER ${ver})
  endforeach()
endfunction()
########################################
function(build_ffmpegv)
  cmake_parse_arguments(ff "" "VER" "" ${ARGN})
  if(NOT (XP_DEFAULT OR XP_PRO_FFMPEG_${ff_VER}))
    return()
  endif()
  if(${ff_VER} STREQUAL ${FFMPEG_MSWVER})
    set(BUILD_CONFIGS Release) # we only need a release version
    xpCmakeBuild(ffmpeg_${ff_VER} "" "-DFFMPEG_VER=${ff_VER}")
  elseif(${ff_VER} STREQUAL ${FFMPEG_CFGVER})
    if(NOT (XP_DEFAULT OR XP_PRO_OPENH264))
      message(STATUS "ffmpeg.cmake: requires openh264")
      set(XP_PRO_OPENH264 ON CACHE BOOL "include openh264" FORCE)
      xpPatchProject(${PRO_OPENH264})
      # NOTE: openh264 depends on yasm, so the above already taken care of in openh264
    endif()
    build_yasm(yasmTgts) # sets YASM_EXE
    build_openh264(openh264Tgts)
    set(XP_CONFIGURE_BASE ${CMAKE_COMMAND} -E env PKG_CONFIG_PATH=${STAGE_DIR}/share/cmake
      PATH=${STAGE_DIR}/bin:$ENV{PATH} # prepend path to yasm
      <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> #--enable-shared --disable-static
      --enable-libopenh264 --disable-bzlib --disable-iconv
      --disable-libxcb --disable-libxcb-shm --disable-libxcb-xfixes --disable-libxcb-shape
      --disable-lzma --disable-sdl --disable-xlib --disable-zlib
      )
    set(XP_CONFIGURE_Debug ${XP_CONFIGURE_BASE} --enable-debug=1)
    set(XP_CONFIGURE_Release ${XP_CONFIGURE_BASE} --disable-debug)
    set(BUILD_CONFIGS Release) # TODO: I'm seeing no difference between Release and Debug
    foreach(cfg ${BUILD_CONFIGS})
      set(XP_CONFIGURE_CMD ${XP_CONFIGURE_${cfg}})
      set(FFMPEG_TARGET ffmpeg_${ff_VER}_${cfg})
      addproject_ffmpeg(${FFMPEG_TARGET})
      # add version and debug suffix to libraries
      if(${cfg} STREQUAL "Debug")
        set(appendSuffix ${CMAKE_COMMAND} -Dsrc:STRING=<BINARY_DIR>/lib/lib*.a
          -Dsuffix:STRING=_${ff_VER}-d -P ${MODULES_DIR}/cmsappendsuffix.cmake)
      else() # not Debug
        set(appendSuffix ${CMAKE_COMMAND} -Dsrc:STRING=<BINARY_DIR>/lib/lib*.a
          -Dsuffix:STRING=_${ff_VER} -P ${MODULES_DIR}/cmsappendsuffix.cmake)
      endif()
      ExternalProject_Get_Property(ffmpeg_${ff_VER} SOURCE_DIR)
      ExternalProject_Get_Property(${FFMPEG_TARGET} INSTALL_DIR)
      set(verDir /ffmpeg_${ff_VER})
      ExternalProject_Add(${FFMPEG_TARGET}_stage DEPENDS ${FFMPEG_TARGET}
        DOWNLOAD_DIR ${NULL_DIR} DOWNLOAD_COMMAND ""
        SOURCE_DIR ${SOURCE_DIR} BINARY_DIR ${INSTALL_DIR}
        CONFIGURE_COMMAND ${appendSuffix}
        BUILD_COMMAND ${CMAKE_COMMAND} -Dsrc:STRING=<BINARY_DIR>/lib/lib*.a
          -Ddst:STRING=${STAGE_DIR}/lib -P ${MODULES_DIR}/cmscopyfiles.cmake
        INSTALL_COMMAND ${CMAKE_COMMAND} -Dsrc:STRING=<BINARY_DIR>/include
          -Ddst:STRING=${STAGE_DIR}/include${verDir}/ffmpeg -P ${MODULES_DIR}/cmscopyfiles.cmake
        INSTALL_DIR ${NULL_DIR}
        )
    endforeach()
  endif()
endfunction()
########################################
macro(addproject_ffmpeg XP_TARGET)
  message(STATUS "target ${XP_TARGET}")
  if(XP_BUILD_VERBOSE)
    xpVerboseListing("[CONFIGURE]" "${XP_CONFIGURE_CMD}")
  endif()
  ExternalProject_Get_Property(ffmpeg_${ff_VER} SOURCE_DIR)
  ExternalProject_Add(${XP_TARGET} DEPENDS ffmpeg_${ff_VER} ${openh264Tgts}
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ${XP_CONFIGURE_CMD}
    BUILD_COMMAND ${CMAKE_COMMAND} -E env PATH=${STAGE_DIR}/bin:$ENV{PATH} make # prepend path to yasm
    INSTALL_COMMAND # use default
    )
  set_property(TARGET ${XP_TARGET} PROPERTY FOLDER ${bld_folder})
endmacro()
