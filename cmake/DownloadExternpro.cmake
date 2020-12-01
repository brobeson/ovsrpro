option(verbose "Show details when downloading externpro files." off)
if(verbose)
  set(SHOW_PROGRESS "SHOW_PROGRESS")
else()
  unset(SHOW_PROGRESS)
endif()

function(download_externpro_file file_path)
  message(STATUS "Downloading and updating ${file_path}")
  file(REMOVE "${CMAKE_SOURCE_DIR}/${file_path}")
  file(
    DOWNLOAD
    "https://raw.githubusercontent.com/smanders/externpro/18.08.4/${file_path}"
    "${CMAKE_SOURCE_DIR}/${file_path}"
    ${SHOW_PROGRESS}
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
  string(REPLACE "${pattern}" "${replace}" file_content "${file_content}")
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
  # Modules needed by the build system at large
  modules/cmscopyfiles.cmake
  modules/Findscript.cmake.in
  modules/macpro.cmake
  modules/xpfunmac.cmake
  modules/xpopts.cmake.in
  projects/patch.cmake

  # Boost and its dependencies
  # TODO Try to figure out how to remove the requirement on Boost 1.67. It's
  # not needed by ovsrpro, but extracting references to it from boost.cmake is
  # not trivial.
  projects/boost.cmake
  projects/boost1_63.cmake
  projects/boost1_67.cmake
  projects/boostbuild1_63.cmake
  projects/boostgil1_63.cmake
  projects/boostgil1_67.cmake
  projects/boostinterprocess1_63.cmake
  projects/boostmpl1_63.cmake
  projects/boostmpl1_67.cmake
  projects/boostunits1_63.cmake
  projects/boostunits1_67.cmake
  patches/boost.build.1_63.patch
  patches/boost.gil.1_63.patch
  patches/boost.gil.1_67.patch
  patches/boost.interprocess.1_63.patch
  patches/boost.mpl.1_63.patch
  patches/boost.mpl.1_67.patch
  patches/boost.units.1_63.patch
  patches/boost.units.1_67.patch
  projects/bzip2.cmake
  patches/bzip2.patch
  projects/zlib.cmake
  patches/zlib.patch
  modules/flags.cmake

  # FFMPEG and its dependencies
  modules/cmsappendsuffix.cmake
  projects/ffmpeg.cmake
  projects/ffmpeg_2.6.2.cmake
  patches/ffmpeg_2.6.2.patch
  # projects/openh264.cmake
  # patches/openh264_1.4.0.patch
  projects/yasm.cmake
  patches/yasm.patch
)
foreach(f IN LISTS files)
  download_externpro_file(${f})
  prepend_download_warning(${f})
endforeach()

replace_in_file("${CMAKE_SOURCE_DIR}/modules/macpro.cmake" externpro ovsrpro)
replace_in_file("${CMAKE_SOURCE_DIR}/modules/xpfunmac.cmake" externpro ovsrpro)

replace_in_file(
  "${CMAKE_SOURCE_DIR}/projects/boost.cmake"
  "configure_file(\${PRO_DIR}/use/usexp-boost-config.cmake \${STAGE_DIR}/share/cmake/\n    @ONLY NEWLINE_STYLE LF\n    )"
  "#configure_file(\${PRO_DIR}/use/usexp-boost-config.cmake \${STAGE_DIR}/share/cmake/\n    #@ONLY NEWLINE_STYLE LF\n    #)"
)
replace_in_file(
  "${CMAKE_SOURCE_DIR}/projects/bzip2.cmake"
  "configure_file(\${PRO_DIR}/use/usexp-bzip2-config.cmake \${STAGE_DIR}/share/cmake/\n    @ONLY NEWLINE_STYLE LF\n    )"
  "#configure_file(\${PRO_DIR}/use/usexp-bzip2-config.cmake \${STAGE_DIR}/share/cmake/\n    #@ONLY NEWLINE_STYLE LF\n    #)"
)
replace_in_file(
  "${CMAKE_SOURCE_DIR}/projects/ffmpeg.cmake"
  "configure_file(\${PRO_DIR}/use/usexp-ffmpeg-config.cmake \${STAGE_DIR}/share/cmake/\n    @ONLY NEWLINE_STYLE LF\n    )"
  "#configure_file(\${PRO_DIR}/use/usexp-ffmpeg-config.cmake \${STAGE_DIR}/share/cmake/\n    #@ONLY NEWLINE_STYLE LF\n    #)"
)
# replace_in_file(
#   "${CMAKE_SOURCE_DIR}/projects/openh264.cmake"
#   "configure_file(\${PRO_DIR}/use/usexp-openh264-config.cmake \${STAGE_DIR}/share/cmake/\n    @ONLY NEWLINE_STYLE LF\n    )"
#   "#configure_file(\${PRO_DIR}/use/usexp-openh264-config.cmake \${STAGE_DIR}/share/cmake/\n    #@ONLY NEWLINE_STYLE LF\n    #)"
# )
replace_in_file(
  "${CMAKE_SOURCE_DIR}/projects/patch.cmake"
  "configure_file(\${PRO_DIR}/use/usexp-patch-config.cmake \${STAGE_DIR}/share/cmake/\n    @ONLY NEWLINE_STYLE LF\n    )"
  "#configure_file(\${PRO_DIR}/use/usexp-patch-config.cmake \${STAGE_DIR}/share/cmake/\n    #@ONLY NEWLINE_STYLE LF\n    #)"
)
replace_in_file(
  "${CMAKE_SOURCE_DIR}/projects/yasm.cmake"
  "configure_file(\${PRO_DIR}/use/usexp-yasm-config.cmake \${STAGE_DIR}/share/cmake/\n      @ONLY NEWLINE_STYLE LF\n      )"
  "#configure_file(\${PRO_DIR}/use/usexp-yasm-config.cmake \${STAGE_DIR}/share/cmake/\n      #@ONLY NEWLINE_STYLE LF\n      #)"
)
replace_in_file(
  "${CMAKE_SOURCE_DIR}/projects/zlib.cmake"
  "configure_file(\${PRO_DIR}/use/usexp-zlib-config.cmake \${STAGE_DIR}/share/cmake/\n    @ONLY NEWLINE_STYLE LF\n    )"
  "#configure_file(\${PRO_DIR}/use/usexp-zlib-config.cmake \${STAGE_DIR}/share/cmake/\n    #@ONLY NEWLINE_STYLE LF\n    #)"
)
