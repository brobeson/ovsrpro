cmake_minimum_required(VERSION 3.9.6)
project(ovsrpro)
if(NOT CMAKE_COMPILER_IS_GNUCXX)
  message(WARNING "${CMAKE_CXX_COMPILER} is not supported.")
endif()

# Download some files from externpro and modify them in place.
include(cmake/DownloadExternpro.cmake)

include(modules/macpro.cmake)
proInit()
proAddProjectDir(projects)
set(CPACK_PACKAGE_CHECKSUM SHA256)
if(PACKAGE_TYPE AND ${XP_STEP} STREQUAL "build")
  # This must be set before proExecuteStep otherwise the generator will be STGZ
  set(CPACK_GENERATOR ${PACKAGE_TYPE})
  set(CPACK_PACKAGE_RELOCATABLE FALSE)
  set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
  set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
  if(PACKAGE_TYPE STREQUAL "RPM")
    # This will expose the shared object files in ovsrpro by adding a .conf file to /etc/ld.so.conf.d/ and run ldconfig
    configure_file(ovsrproconf.sh.in ${CMAKE_BINARY_DIR}/ovsrproconf.sh @ONLY NEWLINE_STYLE LF)
    set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE ${CMAKE_BINARY_DIR}/ovsrproconf.sh)
    # This will remove the ovsrpro.conf file from /etc/ld.so.conf.d/ and run ldconfig on uninstall
    set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/removeovsrproconf.sh)
    # This will prevent rpmbuild from stripping the binaries (avoids some
    # weird errors when linking against a few of the stripped libraries)
    set(CPACK_RPM_SPEC_INSTALL_POST /bin/true)
  endif()
endif()
proExecuteStep()

if(XP_STEP STREQUAL "build")
  execute_process(
    COMMAND git describe --tags
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  string(REGEX REPLACE "-.*" "" version "${version}")
  configure_file(
    Findovsrpro.cmake
    "${STAGE_DIR}/share/cmake/Findovsrpro.cmake"
    @ONLY
  )
endif()
