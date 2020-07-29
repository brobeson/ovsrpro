# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# ZLIB_FOUND - zlib was found
# ZLIB_VER - zlib version
# ZLIB_INCLUDE_DIR - the zlib include directory
# ZLIB_INCLUDE_DIRS - the zlib include directory (match FindZLIB.cmake)
# ZLIB_LIBRARIES - the zlib libraries
set(prj zlib)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
set(${PRJ}_VER "@VER@ [@PROJECT_NAME@]")
set(ver _@VER@)
set(verDir /${prj}${ver})
unset(${PRJ}_INCLUDE_DIR CACHE)
find_path(${PRJ}_INCLUDE_DIR zlib/zlib.h PATHS ${XP_ROOTDIR}/include${verDir} NO_DEFAULT_PATH)
set(${PRJ}_INCLUDE_DIRS ${${PRJ}_INCLUDE_DIR}/zlib)
# targets file (-targets) installed to lib/cmake
include(${XP_ROOTDIR}/lib/cmake/${prj}${ver}-targets.cmake)
set(${PRJ}_LIBRARIES zlibstatic)
set(reqVars ${PRJ}_VER ${PRJ}_INCLUDE_DIR ${PRJ}_INCLUDE_DIRS ${PRJ}_LIBRARIES)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
