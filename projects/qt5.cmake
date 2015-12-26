########################################
# qt5
########################################
# NOTES: see instructions http://wiki.qt.io/Building-Qt-5-from-Git
# requires git >=1.6.x, Perl >= 5.14, Python >= 2.6,
# and postgres >= 7.3 to build.
########################################
xpProOption(qt5)
set(QT5_VER v5.5.0)
set(QT5_REPO http://code.qt.io/qt/qt5.git)
set(QT5_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/qt5)
set(QT5_DOWNLOAD_FILE qt-everywhere-opensource-src-5.5.0.tar.gz)
set(PRO_QT5
  NAME qt5
  WEB "Qt" http://qt.io/ "Qt - Home"
  LICENSE "lgpl" http://www.qt.io/qt-licensing-terms/ "LGPL"
  DESC "One Qt Code: Create Powerful Applications & Devices"
  REPO "repo" ${QT5_REPO} "Qt5 main repo"
  VER ${QT5_VER}
  GIT_ORIGIN ${QT5_REPO}
  GIT_TAG ${QT5_VER}
  DLURL http://download.qt.io/archive/qt/5.5/5.5.0/single/${QT5_DOWNLOAD_FILE}
  DLMD5 828594c91ba736ce2cd3e1e8a6146452
)
set(QT5_REMOVE_SUBMODULES
  qtandroidextras
  qtwebchannel
  qtwebengine
  qtwebkit
  qtwebkit-examples
  qtwebsockets)
#######################################
# setup the configure options
macro(setConfigureOptions)
  set(QT5_INSTALL_PATH ${STAGE_DIR}/qt5)
  # Define configure parameters
  set(QT5_CONFIGURE
    -qt-zlib
    -qt-pcre
    -qt-libpng
    -qt-libjpeg
    -qt-freetype
    -opengl desktop
    -openssl
    -qt-sql-psql
    -qmake
    -opensource
    -confirm-license
    -make libs
    -nomake examples
    -nomake tools
    -nomake tests
    -prefix ${QT5_INSTALL_PATH})
  # Check whether to include debug build
  if(${XP_BUILD_DEBUG})
    list(APPEND QT5_CONFIGURE -debug-and-release)
  else()
    list(APPEND QT5_CONFIGURE -release)
  endif()
  # Check if this is a static build
  if(${XP_BUILD_STATIC})
    list(APPEND QT5_CONFIGURE -static)
  endif()
  if(WIN32)
    list(APPEND QT5_CONFIGURE -platform win32-msvc2013)
  else()
    list(APPEND QT5_CONFIGURE -platform linux-g++ -c++11)
  endif() # OS type
endmacro(setConfigureOptions)
#######################################
# Update the qmake conf with the /MT flag for static windows builds
macro(setQtQmakeConf)
  if(WIN32)
    if(${XP_BUILD_STATIC})
      # Copy the qmake conf file to setup the /MT compiler flag and enable
      # multiple cores while compiling
      configure_file(${PATCH_DIR}/qt5-msvc-desktop-mt.conf
                     ${QT5_REPO_PATH}/qtbase/mkspecs/common/msvc-desktop.conf
                     COPYONLY)
    else()
      # Copy the qmake conf file to setup the /MD compiler flag and enable
      # multiple cores while compiling
      configure_file(${PATCH_DIR}/qt5-msvc-desktop-md.conf
                     ${QT5_REPO_PATH}/qtbase/mkspecs/common/msvc-desktop.conf
                     COPYONLY)
    endif()
  endif()
endmacro(setQtQmakeConf)
#######################################
# mkpatch_qt5 - initialize and clone the main repository
function(mkpatch_qt5)
  xpRepo(${PRO_QT5})
endfunction(mkpatch_qt5)
########################################
# download - initialize the git submodules
function(download_qt5)
  xpNewDownload(${PRO_QT5})
endfunction(download_qt5)
########################################
# patch - remove any of the unwanted submodules
# so that they do not configure/compile
function(patch_qt5)
  xpPatch(${PRO_QT5})
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()

  # Remove the modules that aren't wanted
  foreach(RemoveModule ${QT5_REMOVE_SUBMODULES})
    ExternalProject_Add_Step(qt5 qt5_remove_${RemoveModule}
      COMMENT "Removing ${RemoveModule}"
      WORKING_DIRECTORY ${QT5_REPO_PATH}
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${RemoveModule}
      DEPENDEES download
      )
  endforeach()

  # if this didn't come from the repo (direct download) need to
  # add a .gitignore...it is used by the configure scripts to
  # determine whether to compile the configure.exe
  if (NOT EXISTS ${QT5_REPO_PATH}/qtbase/.gitignore)
    ExternalProject_Add_Step(qt5 qt5_add_gitignore
      COMMENT "Creating empty gitignore file"
      WORKING_DIRECTORY ${QT5_REPO_PATH}
      COMMAND ${CMAKE_COMMAND} -E touch ${QT5_REPO_PATH}/qtbase/.gitignore
      DEPENDEES download)
  endif()
endfunction(patch_qt5)
########################################
# Decides which build command to use jom/nmake/make
macro(findBuildCommand BUILD_COMMAND)
  if(WIN32)
    if(EXISTS "c:\\jom\\jom.exe")
      set(${BUILD_COMMAND} "c:\\jom\\jom.exe")
    else()
      set(${BUILD_COMMAND} "nmake")
    endif()
  else()
    set(${BUILD_COMMAND} "make -j")
  endif()
endmacro()
# build - configure then build the libraries
function(build_qt5)
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
    message("leaving build qt5")
  endif()

  # Make sure the qt5 target this depends on has been created
  if(NOT TARGET qt5)
    patch_qt5()
  endif()

  setConfigureOptions()
  setQtQmakeConf()

  # Determine which build command to use (jom/nmake/make)
  findBuildCommand(QT_BUILD_COMMAND)

  # Create a separate target to build and install...this is because for some
  # reason even though the configure succeeds just fine, it stops before
  # executing the build and install commands (may be because configure exits
  # with warnings about static builds)
  add_custom_target(qt5_configure ALL
    WORKING_DIRECTORY ${QT5_REPO_PATH}
    COMMAND configure ${QT5_CONFIGURE})

  # make sure the download and patching happen first...
  add_dependencies(qt5_configure qt5)

  # we need openssl to compile and link
  set(XP_INCLUDE_DIR ${XP_ROOTDIR}/include)
  set(OPENSSL_LIB_DIR ${XP_ROOTDIR}/lib)

  # Finally, build Qt.  But first, upddate the include and lib paths for openssl
  add_custom_target(qt5_build ALL
    WORKING_DIRECTORY ${QT5_REPO_PATH}
    COMMAND set INCLUDE=%INCLUDE%;${XP_INCLUDE_DIR}
    COMMAND set LIB=%LIB%;${OPENSSL_LIB_DIR}
    COMMAND ${QT_BUILD_COMMAND} -I${OPENSSL_INCLUDE_DIR}
    COMMAND ${QT_BUILD_COMMAND} install
    COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-qt5-config.cmake ${STAGE_DIR}/share/cmake
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/qt.conf ${STAGE_DIR}/qt5/bin)
    add_dependencies(qt5_build qt5_configure qt5)
endfunction(build_qt5)
