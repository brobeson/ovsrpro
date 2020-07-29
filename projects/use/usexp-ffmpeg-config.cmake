# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# FFMPEG_FOUND - FFmpeg was found
# FFMPEG_VER - FFmpeg version
# FFMPEG_INCLUDE_DIR - the FFmpeg include directories
# FFMPEG_LIBRARIES - the FFmpeg libraries
# FFMPEG_DLLS - the FFmpeg shared objects (dll, so)
xpGetPkgVar(openh264 LIBRARIES) # sets OPENH264_LIBRARIES
set(prj ffmpeg)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
set(${PRJ}_VER "@VER@ [@PROJECT_NAME@]")
set(ver _@VER@)
set(verDir /${prj}${ver})
unset(${PRJ}_INCLUDE_DIR CACHE)
find_path(${PRJ}_INCLUDE_DIR ffmpeg/libavcodec/avcodec.h PATHS ${XP_ROOTDIR}/include${verDir} NO_DEFAULT_PATH)
list(APPEND ${PRJ}_INCLUDE_DIR ${XP_ROOTDIR}/include${verDir}/ffmpeg) # for internal header includes
set(reqVars ${PRJ}_VER ${PRJ}_INCLUDE_DIR)
set(${PRJ}_LIBRARIES
  avdevice${ver}
  avformat${ver}
  avfilter${ver}
  avcodec${ver}
  swresample${ver}
  swscale${ver}
  avutil${ver}
  )
list(APPEND reqVars ${PRJ}_LIBRARIES)
link_directories(${XP_ROOTDIR}/lib)
if(WIN32)
  set(${PRJ}_DLLS
    ${XP_ROOTDIR}/bin${verDir}/avcodec-56.dll
    ${XP_ROOTDIR}/bin${verDir}/avdevice-56.dll
    ${XP_ROOTDIR}/bin${verDir}/avfilter-5.dll
    ${XP_ROOTDIR}/bin${verDir}/avformat-56.dll
    ${XP_ROOTDIR}/bin${verDir}/avutil-54.dll
    ${XP_ROOTDIR}/bin${verDir}/swresample-1.dll
    ${XP_ROOTDIR}/bin${verDir}/swscale-3.dll
    )
  list(APPEND reqVars ${PRJ}_DLLS)
else()
  include(CheckLibraryExists)
  function(checkLibraryConcat lib symbol liblist)
    string(TOUPPER ${lib} LIB)
    check_library_exists("${lib}" "${symbol}" "" XP_FFMPEG_HAS_${LIB})
    if(XP_FFMPEG_HAS_${LIB})
      list(APPEND ${liblist} ${lib})
      set(${liblist} ${${liblist}} PARENT_SCOPE)
    endif()
  endfunction()
  checkLibraryConcat(asound snd_strerror syslibs)
  checkLibraryConcat(Xext XShmDetach syslibs)
  list(APPEND ${PRJ}_LIBRARIES ${OPENH264_LIBRARIES} ${syslibs})
endif()
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
