#[========================================================================[.rst:
FindOpenH264
============

Finds the OpenH264 library as part of Ovsrpro.

Imported Target
---------------

This modules provides the :prop_tgt:`IMPORTED` target ``OpenH264::OpenH264``.

Result Variables
----------------

This module defines the following variables:

::

  OpenH264_INCLUDE_DIR - include directories for OpenH264
  OpenH264_LIBRARY_RELEASE - the normal OpenH264 library for Release configuration
  OpenH264_LIBRARY_DEBUG - the normal OpenH264 library for Debug configuration
  OpenH264_FOUND - true if OpenH264 has been found and can be used

#]========================================================================]

if(TARGET OpenH264::OpenH264)
  return()
endif()

set(OpenH264_VERSION @VER@)

find_path(
  OpenH264_INCLUDE_DIR
  NAMES wels/codec_api.h
  PATHS "${ovsrpro_INCLUDE_DIR}/openh264_${OpenH264_VERSION}"
  DOC "The location of the OpenH264 headers."
  NO_DEFAULT_PATH
)
mark_as_advanced(OpenH264_INCLUDE_DIR)

find_library(
  OpenH264_LIBRARY_RELEASE
  NAME OpenH264_1.13.0
  PATHS "${ovsrpro_LIBRARY_DIR}"
  DOC "The release build of the OpenH264 library."
)
mark_as_advanced(OpenH264_LIBRARY_RELEASE)

find_library(
  OpenH264_LIBRARY_DEBUG
  NAME OpenH264_1.13.0-d
  PATHS "${ovsrpro_LIBRARY_DIR}"
  DOC "The debug build of the OpenH264 library."
)
mark_as_advanced(OpenH264_LIBRARY_DEBUG)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  OpenH264
  REQUIRED_VARS
    OpenH264_INCLUDE_DIR
    OpenH264_LIBRARY_RELEASE
  VERSION_VAR OpenH264_VERSION
)

if(OpenH264_FOUND)
  add_library(OpenH264::OpenH264 UNKNOWN IMPORTED)
  set_target_properties(
    OpenH264::OpenH264
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${OpenH264_INCLUDE_DIR}"
      IMPORTED_LOCATION "${OpenH264_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_RELEASE "${OpenH264_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_MINSIZEREL "${OpenH264_LIBRARY_RELEASE}"
      IMPORTED_CONFIGURATIONS "RELEASE;MINSIZEREL"
  )

  if(OpenH264_LIBRARY_DEBUG)
    set_target_properties(
      OpenH264::OpenH264
      PROPERTIES
        IMPORTED_LOCATION_RELWITHDEBINFO "${OpenH264_LIBRARY_DEBUG}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${OpenH264_LIBRARY_DEBUG}"
    )
    set_property(
      TARGET OpenH264::OpenH264
      APPEND
      PROPERTY IMPORTED_CONFIGURATIONS "DEBUG;RELWITHDEBINFO"
    )
  endif()
endif()
