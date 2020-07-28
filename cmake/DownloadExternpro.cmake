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

function(download_externpro_file file_path sha256)
  message(STATUS "Downloading and updating ${file_path}")
  file(REMOVE "${CMAKE_SOURCE_DIR}/${file_path}")
  file(
    DOWNLOAD
    "https://raw.githubusercontent.com/smanders/externpro/18.08.4/${file_path}"
    "${CMAKE_SOURCE_DIR}/${file_path}"
    SHOW_PROGRESS
    STATUS download_status
    EXPECTED_HASH SHA256=${sha256}
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

# Download and modify CMake modules.
download_externpro_file(
  modules/macpro.cmake
  818cb7e3a17cfb826a3c7c275cea0c77bf14f6cd915710acc8f7be4aae184121
)
replace_in_file("${CMAKE_SOURCE_DIR}/modules/macpro.cmake" externpro ovsrpro)
download_externpro_file(
  modules/xpfunmac.cmake
  ebc6b2cd96ebfbb47105f8526c49f2157384148d9f6e422a52f2ab7509fda3ef
)
replace_in_file("${CMAKE_SOURCE_DIR}/modules/xpfunmac.cmake" externpro ovsrpro)
download_externpro_file(
  modules/Findscript.cmake.in
  da8a168e15610ca488ae6be06371558c7e94649cfa93aeaf8cfa6170fd7f0102
)
download_externpro_file(
  modules/xpopts.cmake.in
  9976aa6e8f135716bc749cdc284da0b0e1b7b71c43462b49ba9ee6463fcce8d4
)
download_externpro_file(
  modules/cmscopyfiles.cmake
  b5c12b4b6a45520e743c69a3cd858718fb5bddf750fd2d5d01131607808d8bdc
)

# Download project CMake files.
# patch.cmake is required by the externpro/ovsrpro build process to implement
# the patch step.
download_externpro_file(
  projects/patch.cmake
  678a603f5fa555de4627a44005f1b9151368ae9c13d801e6b8682600406a606e
)
download_externpro_file(
  projects/use/usexp-patch-config.cmake
  971c1a895e5ba671bce267022ee5f69b1f86f04b0876539a61c43ff6dc9fc7bd
)
# download_externpro_file(
#   projects/glew_1.13.0.cmake
#   3c9ebb77a33c35ddf24fb5f4fbbbfc425f75c3b659e74c9884f95d785b489852
# )
# download_externpro_file(
#   projects/ffmpeg_2.6.2.1.cmake
#   90cb21908f36361db9769f5dee42fc1820731a819f314a215162f94ed2a29821
# )
# download_externpro_file(
#   projects/boost1_63.cmake
#   d6e3f02bd683af9fb2e3cb81c28b55be167299602205d79e8ae42d7029712bef
# )

# Download patch files.
# download_externpro_file(
#   patches/ffmpeg_2.6.2.1.patch
#   efed922942fe2ee1a83727257515a88ef38b2fd6c2e9a2d3bdefaec8cb13f90c
# )
# download_externpro_file(
#   patches/glew_1.13.0.patch
#   712945dc8495b3a9a7452a81ce1117ca1ac373d5980b2db335a075f1cb05ac60
# )
# download_externpro_file(
#   patches/boost.build.1_63.patch
#   17155ec1d1c7e5348b8ee8a6c8e59b077f4b1361df3d9da709624c97106644e9
# )