# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# PATCH_FOUND - patch was found
# PATCH_EXE - the patch executable
# PATCH_CMD - the patch command
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
if(UNIX)
  set(PATCH_EXE ${XP_ROOTDIR}/bin/patch)
  set(PATCH_CMD ${PATCH_EXE})
else()
  set(PATCH_EXE ${XP_ROOTDIR}/bin/patcz.exe)
  set(PATCH_CMD ${PATCH_EXE} --binary)
  # NOTE: --binary so patch.exe can handle line ending character issue
endif()
set(reqVars PATCH_EXE PATCH_CMD)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(patch REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
