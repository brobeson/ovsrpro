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
  modules/macpro.cmake
  modules/xpfunmac.cmake
  modules/Findscript.cmake.in
  modules/xpopts.cmake.in
  modules/cmscopyfiles.cmake
  # patches/boost.build.1_63.patch
  # patches/ffmpeg_2.6.2.1.patch
  # patches/glew_1.13.0.patch
  # projects/boost1_63.cmake
  # projects/ffmpeg_2.6.2.1.cmake
  # projects/glew_1.13.0.cmake
  # patch.cmake is required by the externpro/ovsrpro build process to implement
  # the patch step.
  projects/patch.cmake
  projects/use/usexp-patch-config.cmake
)
foreach(f IN LISTS files)
  download_externpro_file(${f})
  prepend_download_warning(${f})
endforeach()

replace_in_file("${CMAKE_SOURCE_DIR}/modules/macpro.cmake" externpro ovsrpro)
replace_in_file("${CMAKE_SOURCE_DIR}/modules/xpfunmac.cmake" externpro ovsrpro)
