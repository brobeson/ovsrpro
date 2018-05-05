#######################################
# kerberos
# NOTE: Requires GnuWin32 in C:\program Files (x86)\GnuWin32
# NOTE: Requires Perl64 in C:\Perl64\
#######################################
xpProOption(kerberos)
#######################################
# setup some pathing variables
set(KERBEROS_DOWNLOAD_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/kerberos)
if(WIN32 OR TRUE) # use this version for all platforms since we're only building on Windows
  set(KERBEROS_DL_URL http://web.mit.edu/kerberos/dist/kfw/4.0/kfw-4.0.1-src.zip)
  set(KERBEROS_DL_MD5 6d58ca865beb5b5c145dc4f579753d33)
  set(KERBEROS_VER 4.0.1)
elseif(ATTEMPTING_TO_BUILD_ON_LINUX)
  set(KERBEROS_DL_URL http://web.mit.edu/kerberos/dist/krb5/1.14/krb5-1.14.tar.gz)
  set(KERBEROS_DL_MD5 0727968764d0208388b85ad31aafde24)
  set(KERBEROS_VER 5.1.14)
  # TRICKY: cmake generation of the projects/README.md doesn't support two versions for one project
  # if two versions needed, there should be two project files -- see externpro 18.01.1 for an example
  # https://github.com/smanders/externpro/tree/18.01.1/projects (two versions of ffmpeg)
endif()
#######################################
set(PRO_KERBEROS
  NAME kerberos
  WEB "Kerberos" http://web.mit.edu/kerberos/ "Kerberos"
  LICENSE "open" http://web.mit.edu/kerberos/krb5-1.14/doc/mitK5license.html "MIT Kerberos License information"
  DESC "Kerberos is a network authentication protocol (only built on Windows)"
  VER ${KERBEROS_VER}
  DLURL ${KERBEROS_DL_URL}
  DLMD5 ${KERBEROS_DL_MD5}
  )
#######################################
function(patch_kerberos)
  if(NOT (XP_DEFAULT OR XP_PRO_KERBEROS))
    return()
  endif()

  xpPatchProject(${PRO_KERBEROS})

  if(WIN32)
    ExternalProject_Add_Step(kerberos kerberos_windows_minimal_patch
      WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}
      COMMENT "Applying kerberos minimal patch"
      # eliminate executables that we won't ever need for linking etc.
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-windows-minimal-Makefile.in ${KERBEROS_DOWNLOAD_PATH}/src/Makefile.in
      # fix the install script due to the parts we removed
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-windows-Makefile.in ${KERBEROS_DOWNLOAD_PATH}/src/windows/Makefile.in
      # fix libecho to work on 64 bit...
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-libecho.c ${KERBEROS_DOWNLOAD_PATH}/src/util/windows/libecho.c
      DEPENDEES download
      )

    if(${XP_BUILD_STATIC})
      ExternalProject_Add_Step(kerberos kerberos_windows_static_patch
        WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}
        COMMENT "Updating kerberos to /MT flags"
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-windows-static-win-pre.in ${KERBEROS_DOWNLOAD_PATH}/src/config/win-pre.in
        DEPENDEES download
        )
    endif()
  endif()
endfunction()
#######################################
function(build_kerberos)
  if(NOT (XP_DEFAULT OR XP_PRO_KERBEROS))
    return()
  endif()

  if(NOT TARGET kerberos)
    patch_kerberos()
  endif()

  if(WIN32)
    if(${XP_BUILD_DEBUG})
      set(NODEBUG 0)
    else()
      set(NODEBUG 1)
    endif()

    set(ADD_TO_PATH "C:\\Program Files (x86)\\GnuWin32\\bin\;C:\\Perl64\\bin\;")

    add_custom_target(kerberos_build ALL
      COMMENT "Building kerberos"
      WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}/src
      # build the 64 bit libraries
      COMMAND set PATH=%PATH%\;${ADD_TO_PATH}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/kerberos
      COMMAND ${CMAKE_COMMAND} -E env CPU=AMD64 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos nmake -f Makefile.in prep-windows
      COMMAND ${CMAKE_COMMAND} -E env CPU=AMD64 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos CL=/D_XKEYCHECK_H=1 nmake NODEBUG=${NODEBUG}
      COMMAND ${CMAKE_COMMAND} -E env CPU=AMD64 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos nmake install NODEBUG=${NODEBUG}
      # re-arrange the installation a bit...
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${STAGE_DIR}/kerberos/include ${STAGE_DIR}/include/kerberos
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${STAGE_DIR}/kerberos/lib ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${STAGE_DIR}/kerberos/bin ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${STAGE_DIR}/kerberos
      DEPENDS kerberos
      )
  elseif(NOT WIN32)
    # NOTE - Only building for Windows.  Including these libraries on Linux could
    # cause conflicts with OS-installed versions (with care that can be avoided).
    # To enable building on Linux simply remove the elseif(NOT WIN32) and return()
    return()
  else()
    # Put data where it won't be in the STAGE_DIR and copy over what is wanted later
    set(DATA_DIR ${KERBEROS_DOWNLOAD_PATH}/data)
    add_custom_target(kerberos_build ALL
      COMMENT "Building kerberos"
      WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}/src
      COMMAND ./configure --prefix=${STAGE_DIR} --includedir=${STAGE_DIR}/include/kerberos --datadir=${DATA_DIR} --localedir=${DATA_DIR} --mandir=${DATA_DIR} --localstatedir=${DATA_DIR}
      COMMAND make
      COMMAND make install
      DEPENDS kerberos
      )
  endif()

  set(numBits 64)
  if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(numBits 32)
  endif()

  # Copy NOTICE and README files to STAGE_DIR
  add_custom_command(TARGET kerberos_build POST_BUILD
    WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/kerberos
    COMMAND ${CMAKE_COMMAND} -E copy ${KERBEROS_DOWNLOAD_PATH}/NOTICE ${STAGE_DIR}/share/kerberos
    COMMAND ${CMAKE_COMMAND} -E copy ${KERBEROS_DOWNLOAD_PATH}/README ${STAGE_DIR}/share/kerberos
    )

  configure_file(${PRO_DIR}/use/useop-kerberos-config.cmake ${STAGE_DIR}/share/cmake/useop-kerberos-config.cmake)
endfunction()
