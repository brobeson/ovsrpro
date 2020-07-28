xpProOption(psql)

set(PSQL_REPO https://github.com/postgres/postgres)
set(PSQL_VERSION 9.6.10)
string(REPLACE "." "_" TAG ${PSQL_VERSION})

# setup the function arguments used by externpro
set(PRO_PSQL
  NAME psql
  WEB "PostgreSQL" http://www.postgresql.org/ "PostgreSQL"
  LICENSE "open" http://www.postgresql.org/about/licence "PostgreSQL license"
  DESC "PostgreSQL redistributable binaries"
  REPO "repo" ${PSQL_REPO} "Mirror of the official PostgreSQL GIT repository on github"
  VER ${PSQL_VERSION}
  GIT_ORIGIN ${PSQL_REPO}.git
  GIT_TAG REL${TAG}
  DLURL https://ftp.postgresql.org/pub/source/v9.6.10/postgresql-9.6.10.tar.gz
  DLMD5 4d7c59f21bff8ab91ceb4f931258d729
)


function(patch_psql)
  if(NOT (XP_DEFAULT OR XP_PRO_PSQL))
    return()
  endif()
  xpPatchProject(${PRO_PSQL})
  if(WIN32 AND XP_BUILD_STATIC)
    ExternalProject_Get_Property(psql SOURCE_DIR)
    ExternalProject_Add_Step(
      psql
      updateToStatic
      COMMENT "Replacing win32.mak file to enable /MT compiler flag"
      COMMAND
        ${CMAKE_COMMAND}
        -E copy
        "${PATCH_DIR}/psql-win32-static.mak"
        "${SOURCE_DIR}/src/interfaces/libpq/win32.mak"
      COMMAND
        ${CMAKE_COMMAND}
        -E copy
        "${PATCH_DIR}/psql-win32-top-level-static.mak"
        "${SOURCE_DIR}/src/win32.mak"
      COMMAND
        ${CMAKE_COMMAND}
        -E copy
        "${PATCH_DIR}/psql-win32error-static_patch.c"
        "${SOURCE_DIR}/src/port/win32error.c"
      DEPENDEES download
    )
  endif()
endfunction()


function(build_psql)
  if(NOT (XP_DEFAULT OR XP_PRO_PSQL))
    return()
  endif()
  if(TARGET psql_build)
    return()
  endif()
  if(NOT TARGET psql)
    patch_psql()
  endif()
  configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/Findpsql.cmake"
    "${STAGE_DIR}/share/cmake/Findpsql.cmake"
    @ONLY
  )
  ExternalProject_Get_Property(psql SOURCE_DIR)
  if(WIN32)
    _build_psql_on_windows()
  elseif(UNIX)
    _build_psql_on_linux()
  endif()
  ExternalProject_Add(
    psql_install_files
    DEPENDS psql_Release
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory "${STAGE_DIR}/share/psql"
      && ${CMAKE_COMMAND} -E copy "${SOURCE_DIR}/COPYRIGHT" "${STAGE_DIR}/share/psql"
  )

endfunction()


function(_build_psql_on_windows)
  add_custom_target(psql_build ALL
    COMMENT "Configuring and building psql"
    WORKING_DIRECTORY "${PSQL_REPO_PATH}/src"
    COMMAND
      nmake
      /f win32.mak
      CPU=AMD64
      SSL_INC="${OPENSSL_INCLUDE_DIR}"
      SSL_LIB_PATH="${XP_ROOTDIR}/lib"
      LIB_ONLY
    COMMAND ${CMAKE_COMMAND} -E make_directory "${STAGE_DIR}/lib"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy_directory
      "${SOURCE_DIR}/src/include"
      "${STAGE_DIR}/include/psql"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/pg_config_paths.h"
      "${STAGE_DIR}/include/psql/pg_config_paths.h"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/fe-auth.h"
      "${STAGE_DIR}/include/psql/fe-auth.h"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/libpq-events.h"
      "${STAGE_DIR}/include/psql/libpq-events.h"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/libpq-fe.h"
      "${STAGE_DIR}/include/psql/libpq-fe.h"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/libpq-int.h"
      "${STAGE_DIR}/include/psql/libpq-int.h"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/pqexpbuffer.h"
      "${STAGE_DIR}/include/psql/pqexpbuffer.h"
    COMMAND
      ${CMAKE_COMMAND}
      -E copy
      "${SOURCE_DIR}/src/interfaces/libpq/win32.h"
      "${STAGE_DIR}/include/psql/win32.h"
    DEPENDS psql
  )
  if(XP_BUILD_STATIC)
    add_custom_command(
      TARGET psql_build
      POST_BUILD
      WORKING_DIRECTORY "${SOURCE_DIR}/src"
      COMMAND
        lib
        /out:"${STAGE_DIR}/lib/libpq.lib"
        "${SOURCE_DIR}/src/interfaces/libpq/Release/libpq.lib"
        Secur32.lib
    )
  else()
    add_custom_command(
      TARGET psql_build
      POST_BUILD
      WORKING_DIRECTORY "${SOURCE_DIR}/src"
      COMMAND
        ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/src/interfaces/libpq/Release/libpq.lib"
        "${STAGE_DIR}/lib/libpq.lib"
    )
  endif()
  if(XP_BUILD_DEBUG)
    add_custom_command(
      TARGET psql_build
      POST_BUILD
      COMMENT "Build psql - debug"
      WORKING_DIRECTORY "${PSQL_REPO_PATH}/src"
      COMMAND
        nmake
        /f win32.mak
        CPU=AMD64
        SSL_INC="${OPENSSL_INCLUDE_DIR}"
        SSL_LIB_PATH="${XP_ROOTDIR}/lib"
        DEBUG=1
        LIB_ONLY
      COMMAND
        ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/src/interfaces/libpq/Debug/libpqd.lib"
        "${STAGE_DIR}/lib/libpqd.lib"
    )
    if(XP_BUILD_STATIC)
      add_custom_command(
        TARGET psql_build
        POST_BUILD
        WORKING_DIRECTORY "${SOURCE_DIR}/src"
        COMMAND
          lib
          /out:"${STAGE_DIR}/lib/libpqd.lib"
          "${SOURCE_DIR}/src/interfaces/libpq/Debug/libpqd.lib"
          Secur32.lib
      )
    else()
      add_custom_command(
        TARGET psql_build
        POST_BUILD
        WORKING_DIRECTORY "${SOURCE_DIR}/src"
        COMMAND
          ${CMAKE_COMMAND}
          -E copy
          "${SOURCE_DIR}/src/interfaces/libpq/Debug/libpqd.lib"
          "${STAGE_DIR}/lib/libpqd.lib"
      )
    endif()
  endif()
endfunction()


function(_build_psql_on_linux)
  # The 'configure' command cannot have quotes around the directory options:
  # --prefix="${STAGE_DIR}" leads to an error.
  ExternalProject_Add(
    psql_Release
    DEPENDS psql
    DOWNLOAD_COMMAND ""
    SOURCE_DIR "${SOURCE_DIR}"
    CONFIGURE_COMMAND
      ./configure
      --prefix=${STAGE_DIR}
      --libdir=${STAGE_DIR}/lib
      --includedir=${STAGE_DIR}/include/psql
      --datadir=${SOURCE_DIR}/data
      --without-readline
    BUILD_COMMAND $(MAKE) clean && $(MAKE)
    BUILD_IN_SOURCE true
    INSTALL_COMMAND
      $(MAKE) -C src/include install
      && $(MAKE) -C src/bin/pg_config install
      && $(MAKE) -C src/interfaces install
  )
  if(XP_BUILD_DEBUG)
    ExternalProject_Add(
      psql_Debug
      DEPENDS psql_Release
      DOWNLOAD_COMMAND ""
      SOURCE_DIR "${SOURCE_DIR}"
      CONFIGURE_COMMAND
        ./configure
        --prefix=${STAGE_DIR}
        --libdir=${STAGE_DIR}/lib/psqldebug
        --includedir=${STAGE_DIR}/include/psql
        --datadir=${SOURCE_DIR}/data
        --without-readline
        --enable-debug
      BUILD_COMMAND $(MAKE) clean && $(MAKE)
      BUILD_IN_SOURCE true
      INSTALL_COMMAND $(MAKE) -C src/interfaces install
    )
  endif()
endfunction()
