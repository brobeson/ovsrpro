# patch (aka patcz)
# * renamed to patcz on MSW because of MSFT boneheadedness:
#   any exe with "setup" "install" "update" "patch" is flagged to be run as administrator
#   http://stackoverflow.com/questions/7914180/windows-7-exe-filename-starts-with-patch-wont-run
set(PATCH_MSWVER 2.5.9-7)
set(PATCH_GNUVER 2.7.5)
set(PRO_PATCH
  NAME patch
  WEB "patch" http://www.gnu.org/software/patch "GNU patch website"
  LICENSE "GPL" http://www.gnu.org/licenses/gpl.html "GNU GPL v3"
  DESC "pre-built (MSW), built here (non-MSW) used internally to apply a patch file of differences"
  REPO "repo" http://git.savannah.gnu.org/cgit/patch.git "patch (git) repo on gnu.org"
  VER ${PATCH_MSWVER}/${PATCH_GNUVER}
  GIT_ORIGIN git://git.savannah.gnu.org/patch.git
  DLURL http://ftp.gnu.org/gnu/patch/patch-${PATCH_GNUVER}.tar.gz
  DLMD5 ed4d5674ef4543b4eb463db168886dc7
  DLURL_MSW http://prdownloads.sourceforge.net/gnuwin32/patch-${PATCH_MSWVER}-bin.zip
  DLMD5_MSW b9c8b31d62f4b2e4f1887bbb63e8a905
  DLADD _MSW
  )
####################
get_property(baseDir DIRECTORY PROPERTY "EP_BASE")
set(patchbld_DIR ${baseDir}/bld.patch)
if(WIN32 AND NOT UNIX)
  set(PATCH_EXE ${patchbld_DIR}/bin/patcz.exe)
  set(PATCH_CMD ${PATCH_EXE} --binary)
  # NOTE: --binary so patch.exe can handle line ending character issue
else()
  set(PATCH_EXE ${patchbld_DIR}/bin/patch)
  set(PATCH_CMD ${PATCH_EXE})
endif()
########################################
function(patch_patch)
  if(NOT TARGET patch)
    if(WIN32 AND NOT UNIX)
      xpGetArgValue(${PRO_PATCH} ARG DLURL_MSW VALUE dwnldUrl)
      xpGetArgValue(${PRO_PATCH} ARG DLMD5_MSW VALUE dwnldMd5)
      ExternalProject_Add(patch
        DOWNLOAD_DIR ${DWNLD_DIR}
        URL ${dwnldUrl}  URL_MD5 ${dwnldMd5}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${CMAKE_COMMAND} -E copy_if_different
          <SOURCE_DIR>/bin/patch.exe ${patchbld_DIR}/bin/patcz.exe
        INSTALL_COMMAND "" INSTALL_DIR ${NULL_DIR}
        )
    else()
      xpGetArgValue(${PRO_PATCH} ARG DLURL VALUE dwnldUrl)
      xpGetArgValue(${PRO_PATCH} ARG DLMD5 VALUE dwnldMd5)
      ExternalProject_Add(patch
        DOWNLOAD_DIR ${DWNLD_DIR}
        URL ${dwnldUrl}  URL_MD5 ${dwnldMd5}
        CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${patchbld_DIR}
        BUILD_COMMAND   # use default
        INSTALL_COMMAND # use default
        )
    endif()
    set_property(TARGET patch PROPERTY FOLDER ${src_folder})
  endif()
endfunction()
########################################
function(build_patch)
  configure_file(${PRO_DIR}/use/usexp-patch-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
  get_filename_component(patchExe ${PATCH_EXE} NAME)
  ExternalProject_Add(patch_bld DEPENDS patch
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR} CONFIGURE_COMMAND ""
    SOURCE_DIR ${NULL_DIR} BINARY_DIR ${NULL_DIR} INSTALL_DIR ${NULL_DIR}
    BUILD_COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${PATCH_EXE} ${STAGE_DIR}/bin/${patchExe}
    INSTALL_COMMAND ""
    )
  set_property(TARGET patch_bld PROPERTY FOLDER ${bld_folder})
  message(STATUS "target patch_bld")
endfunction()
