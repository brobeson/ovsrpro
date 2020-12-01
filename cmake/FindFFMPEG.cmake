#[========================================================================[.rst:
FindFFMPEG
==========

Finds the FFMPEG library as part of Ovsrpro.

Imported Target
---------------

This modules provides the following :prop_tgt:`IMPORTED` targets:

::

  FFMPEG::avcodec
  FFMPEG::avdevice
  FFMPEG::avfilter
  FFMPEG::avformat
  FFMPEG::avutil
  FFMPEG::swresample
  FFMPEG::swscale

Result Variables
----------------

This module defines the following variables:

::

  FFMPEG_INCLUDE_DIR - include directories for FFMPEG
  FFMPEG_LIBRARY_RELEASE - the normal FFMPEG library for Release configuration
  FFMPEG_LIBRARY_DEBUG - the normal FFMPEG library for Debug configuration
  FFMPEG_FOUND - true if FFMPEG has been found and can be used

#]========================================================================]

if(TARGET FFMPEG::FFMPEG)
  return()
endif()

set(FFMPEG_VERSION @FFMPEG_BLDVER@)

find_path(
  FFMPEG_INCLUDE_DIR
  NAMES ffmpeg.h
  PATHS "${ovsrpro_INCLUDE_DIR}/GL"
  DOC "The location of the FFMPEG headers."
  NO_DEFAULT_PATH
)
mark_as_advanced(FFMPEG_INCLUDE_DIR)

find_library(
  FFMPEG_LIBRARY_RELEASE
  NAME FFMPEG_1.13.0
  PATHS "${ovsrpro_LIBRARY_DIR}"
  DOC "The release build of the FFMPEG library."
)
mark_as_advanced(FFMPEG_LIBRARY_RELEASE)

find_library(
  FFMPEG_LIBRARY_DEBUG
  NAME FFMPEG_1.13.0-d
  PATHS "${ovsrpro_LIBRARY_DIR}"
  DOC "The debug build of the FFMPEG library."
)
mark_as_advanced(FFMPEG_LIBRARY_DEBUG)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  FFMPEG
  REQUIRED_VARS
    FFMPEG_INCLUDE_DIR
    FFMPEG_LIBRARY_RELEASE
  VERSION_VAR FFMPEG_VERSION
)

if(FFMPEG_FOUND)
  add_library(FFMPEG::FFMPEG UNKNOWN IMPORTED)
  set_target_properties(
    FFMPEG::FFMPEG
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${FFMPEG_INCLUDE_DIR}"
      IMPORTED_LOCATION "${FFMPEG_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_RELEASE "${FFMPEG_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_MINSIZEREL "${FFMPEG_LIBRARY_RELEASE}"
      IMPORTED_CONFIGURATIONS "RELEASE;MINSIZEREL"
  )

  if(FFMPEG_LIBRARY_DEBUG)
    set_target_properties(
      FFMPEG::FFMPEG
      PROPERTIES
        IMPORTED_LOCATION_RELWITHDEBINFO "${FFMPEG_LIBRARY_DEBUG}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${FFMPEG_LIBRARY_DEBUG}"
    )
    set_property(
      TARGET FFMPEG::FFMPEG
      APPEND
      PROPERTY IMPORTED_CONFIGURATIONS "DEBUG;RELWITHDEBINFO"
    )
  endif()
endif()
