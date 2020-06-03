# See the instructions at http://wiki.qt.io/Building-Qt-5-from-Git.
# Required tools are:
#   - Perl >= 5.14
#   - Python >= 2.7
# Required libraries are:
#   - openssl from externpro
#   - psql from ovsrpro
# After installation, the qt.conf file in OVSRPRO_INSTALL_PATH/qt5/bin
# must be manually modified setting the "Prefix" value to the qt5 installation
# path (e.g. C:/Program Files/ovsrpro 0.0.1-vc120-64/qt5)

xpProOption(qt5)
set(QT5_MAJOR_VERSION 5)
set(QT5_MINOR_VERSION 12)
SET(QT5_PATCH_VERSION 8)
set(QT5_VERSION ${QT5_MAJOR_VERSION}.${QT5_MINOR_VERSION}.${QT5_PATCH_VERSION})
set(QT5_REPO http://code.qt.io/cgit/qt/qt5.git)
set(QT5_DOWNLOAD_FILE qt-everywhere-src-${QT5_VERSION}.tar.xz)
set(PRO_QT5
  NAME qt5
  WEB "Qt" http://qt.io/ "Qt - Home"
  LICENSE "LGPL" http://www.qt.io/qt-licensing-terms/ "LGPL"
  DESC "One Qt Code: Create Powerful Applications & Devices"
  REPO "repo" ${QT5_REPO} "Qt5 main repo"
  VER ${QT5_VERSION}
  GIT_ORIGIN ${QT5_REPO}
  GIT_TAG v${QT5_VERSION}
  DLURL http://download.qt.io/archive/qt/${QT5_MAJOR_VERSION}.${QT5_MINOR_VERSION}/${QT5_VERSION}/single/${QT5_DOWNLOAD_FILE}
  DLMD5 8ec2a0458f3b8e9c995b03df05e006e4
)


macro(setConfigureOptions)
  set(QT5_INSTALL_PATH ${STAGE_DIR}/qt5)
  set(QT5_CONFIGURE
    -qt-zlib
    -qt-pcre
    -qt-libpng
    -qt-libjpeg
    -system-freetype
    -opengl desktop
    -sql-psql
    -psql_config ${STAGE_DIR}/bin/pg_config
    -opensource
    -confirm-license
    -make libs
    -nomake examples
    -make tools
    -nomake tests
    -prefix ${QT5_INSTALL_PATH})
  if(XP_BUILD_DEBUG AND WIN32)
    list(APPEND QT5_CONFIGURE -debug-and-release)
  else()
    list(APPEND QT5_CONFIGURE -release)
  endif()
  if(XP_BUILD_STATIC)
    list(APPEND QT5_CONFIGURE -static)
  else()
    list(APPEND QT5_CONFIGURE -shared)
  endif()
  if(WIN32)
    list(APPEND QT5_CONFIGURE -platform win32-msvc2013 -qmake -mp)
  else()
    list(APPEND QT5_CONFIGURE -platform linux-g++
      -c++std c++14
      -qt-xcb
      -fontconfig
      -optimized-qmake
      -verbose
      -glib
      -no-cups
      -no-iconv
      -no-evdev
      -no-tslib
      -no-icu
      -no-android-style-assets
      -no-gstreamer)
  endif()
endmacro()


macro(qt5CheckDependencies)
  find_program(gperf gperf)
  mark_as_advanced(gperf)
  if(NOT gperf)
    message(FATAL_ERROR "\n"
      "Gperf is required for Qt5.  To install on linux:\n"
      "  apt install gperf\n"
      "  yum install gperf  # requires epel-release\n")
    return()
  endif()

  find_package(EXPAT REQUIRED)
  mark_as_advanced(pkgcfg_lib_PC_EXPAT_expat)

  find_program(bison bison)
  mark_as_advanced(bison)
  if(NOT bison)
    message(FATAL_ERROR "\n"
      "Bison is required for Qt5. To install on linux:\n"
      "  apt install bison\n"
      "  yum install bison")
    return()
  endif()

  find_program(python python)
  mark_as_advanced(python)
  if(NOT python)
    message(FATAL_ERROR "\n"
      "Python is required for Qt5. To install on linux:\n"
      "  apt install python\n"
      "  yum install python")
  endif()

  find_program(perl perl)
  mark_as_advanced(perl)
  if(NOT perl)
    message(FATAL_ERROR "\n"
      "Perl is required for Qt5. To install on linux:\n"
      "  apt install perl\n"
      "  yum install perl")
  endif()
endmacro()


function(build_qt5)
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()
  if(NOT (XP_DEFAULT OR XP_PRO_PSQL))
    message(FATAL_ERROR "Qt5 requires psql")
  endif()
  qt5CheckDependencies()
  setConfigureOptions()

  if(WIN32)
    set(MAKE_CMD nmake)
    set(
      ADDITIONAL_CFG
      "set _CL_=%_CL_% /I'${XP_ROOTDIR}/include' /I'${STAGE_DIR}/include/psql' &&
      set LIB=${XP_ROOTDIR}/lib\;${STAGE_DIR}/lib\;%LIB% &&"
    )
  else()
    set(MAKE_CMD $(MAKE))
  endif()

  ExternalProject_Get_Property(qt5 SOURCE_DIR)
  ExternalProject_Add(
    qt5_build
    DEPENDS qt5 psql_Release
    DOWNLOAD_COMMAND ""
    SOURCE_DIR "${SOURCE_DIR}"
    CONFIGURE_COMMAND ./configure ${QT5_CONFIGURE}
    BUILD_COMMAND ${ADDITIONAL_CFG} ${MAKE_CMD}
    BUILD_IN_SOURCE true
    INSTALL_COMMAND
      ${MAKE_CMD} install
  )

  ExternalProject_Get_Property(qt5 DOWNLOAD_DIR)
  ExternalProject_Add(
    qt5_install_files
    DEPENDS qt5_build
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/LICENSE.FDL"
        "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/LICENSE.GPLv2"
        "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/LICENSE.GPLv3"
        "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/LICENSE.LGPLv21"
        "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E copy
        "${SOURCE_DIR}/LICENSE.LGPLv3"
        "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E copy
        "${DOWNLOAD_DIR}/${QT5_DOWNLOAD_FILE}"
        "${STAGE_DIR}/share/qt5"
      && ${CMAKE_COMMAND}
        -E echo
        "Compile flags used when building the library: '${QT5_CONFIGURE}'"
        > "${STAGE_DIR}/share/qt5/compileFlags"
  )

endfunction(build_qt5)
