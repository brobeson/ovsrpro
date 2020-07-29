option(
  ovsrpro_download_externpro
  "Download files from externpro. Turn this off if you need to debug those files. Otherwise, it should remain on."
  on
)
mark_as_advanced(ovsrpro_download_externpro)
if(NOT ovsrpro_download_externpro)
  message(
    AUTHOR_WARNING
    "Externpro files will not be downloaded. This should only be skipped to "
    "troubleshoot issues with the existing externpro files. If this was "
    "disabled by mistake, set ovsrpro_download_externpro to true."
  )
  return()
endif()

function(download_externpro_file file_path)
  message(STATUS "Downloading and updating ${file_path}")
  file(REMOVE "${CMAKE_SOURCE_DIR}/${file_path}")
  file(
    DOWNLOAD
    "https://raw.githubusercontent.com/smanders/externpro/18.08.4/${file_path}"
    "${CMAKE_SOURCE_DIR}/${file_path}"
    SHOW_PROGRESS
    STATUS download_status
  )
  list(GET download_status 0 exit_code)
  if(NOT exit_code EQUAL 0)
    list(GET download_status 1 error_message)
    message(STATUS "Downloading and updating ${file_path} - failed")
    message(FATAL_ERROR "${error_message}")
  endif()
  message(STATUS "Downloading and updating ${file_path} - done")
endfunction()

function(replace_in_file file_path pattern replace)
  file(READ "${file_path}" file_content)
  string(REGEX REPLACE "${pattern}" "${replace}" file_content "${file_content}")
  file(WRITE "${file_path}" "${file_content}")
endfunction()

function(prepend_download_warning file_path)
  file(READ "${file_path}" file_content)
  string(
    PREPEND
    file_content
    "# WARNING\n# This file is downloaded and modified by CMake.\n# Manual edits will be overwritten.\n\n"
  )
  file(WRITE "${file_path}" "${file_content}")
endfunction()


set(
  files
  modules/cmsappendsuffix.cmake
  modules/cmscopyfiles.cmake
  modules/Findscript.cmake.in
  modules/macpro.cmake
  modules/xpfunmac.cmake
  modules/xpopts.cmake.in

  # Patch is required for the build process to patch some projects.
  projects/patch.cmake
  projects/use/usexp-patch-config.cmake

  # projects/boost1_63.cmake
  # patches/boost.build.1_63.patch

  # FFMPEG and its dependencies
  projects/ffmpeg.cmake
  projects/ffmpeg_2.6.2.cmake
  projects/use/usexp-ffmpeg-config.cmake
  patches/ffmpeg_2.6.2.patch
  projects/openh264.cmake
  projects/use/usexp-openh264-config.cmake
  patches/openh264_1.4.0.patch
  projects/yasm.cmake
  patches/yasm.patch

  # GLEW and its dependencies
  projects/glew.cmake
  projects/glew_1.13.0.cmake
  patches/glew_1.13.0.patch
  projects/use/usexp-glew-config.cmake
)
foreach(f IN LISTS files)
  download_externpro_file(${f})
  prepend_download_warning(${f})
endforeach()

replace_in_file("${CMAKE_SOURCE_DIR}/modules/macpro.cmake" externpro ovsrpro)
replace_in_file("${CMAKE_SOURCE_DIR}/modules/xpfunmac.cmake" externpro ovsrpro)
