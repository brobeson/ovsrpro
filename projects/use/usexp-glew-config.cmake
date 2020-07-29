# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# GLEW_FOUND - GLEW was found
# GLEW_VER - GLEW version
# GLEW_INCLUDE_DIR - the GLEW include directory
# GLEW_LIBRARIES - the GLEW libraries
# GLEW_DLLS - the GLEW DLLs
set(prj glew)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
if(NOT WIN32)
  set(XP_USE_LATEST_GLEW ON)
elseif(WIN32 AND NOT DEFINED XP_USE_LATEST_GLEW)
  option(XP_USE_LATEST_GLEW "build with glew @GLEW_BLDVER@ instead of pre-built @GLEW_MSWVER@" OFF)
endif()
if(XP_USE_LATEST_GLEW)
  set(glewVer @GLEW_BLDVER@)
else()
  set(glewVer @GLEW_MSWVER@)
endif()
set(${PRJ}_VER "${glewVer} [@PROJECT_NAME@]")
set(ver _${glewVer})
set(verDir /${prj}${ver})
unset(${PRJ}_INCLUDE_DIR CACHE)
find_path(${PRJ}_INCLUDE_DIR GL/glew.h PATHS ${XP_ROOTDIR}/include${verDir} NO_DEFAULT_PATH)
set(reqVars ${PRJ}_VER ${PRJ}_INCLUDE_DIR)
if(EXISTS ${XP_ROOTDIR}/lib/cmake/${prj}${ver}/${prj}-targets.cmake) # built via cmake
  include(${XP_ROOTDIR}/lib/cmake/${prj}${ver}/${prj}-targets.cmake)
  set(${PRJ}_LIBRARIES GLEW::glew_s) # GLEW::glewmx_s TODO determine if glewmx is needed
  list(APPEND reqVars ${PRJ}_LIBRARIES)
elseif(WIN32) # pre-built
  set(${PRJ}_LIBRARIES glew32) # TODO opengl32 glu32 system libraries?
  set(${PRJ}_DLLS
    ${XP_ROOTDIR}/lib/glew32.dll
    ${XP_ROOTDIR}/lib/glew32mx.dll # TODO determine if this is needed
    )
  list(APPEND reqVars ${PRJ}_LIBRARIES ${PRJ}_DLLS)
endif()
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
