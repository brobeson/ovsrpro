########################################
# zookeeper
# Note: Requires apache ant in the system path (http://ant.apache.org/)
# Note: Requires JDK in the system path
# Note: Requres gnu32 for windows to use sed, find, and xargs (c:\program files(x86)\gnuwin32)
########################################
xpProOption(zookeeper)
set(ZK_REPO https://github.com/apache/zookeeper)
set(ZK_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper)
set(ZK_SRC_PATH ${ZK_REPO_PATH}/src/c/src)
set(ZK_INSTALL_PATH ${CMAKE_BINARY_DIR}/xpbase/Install/zookeeper)
set(ZK_VER 3.4.9)
if(WIN32)
  set(ZOO_PATCH ${PATCH_DIR}/zookeeper-windows.patch)
else()
  set(ZOO_PATCH "${PATCH_DIR}/zookeeper.patch")
endif()
set(PRO_ZOOKEEPER
  NAME zookeeper
  WEB "Zookeeper" https://zookeeper.apache.org/ "Zookeeper - Home"
  LICENSE "open" http://www.apache.org/licenses/ "Apache V2.0"
  DESC "Apache ZooKeeper is an effort to develop and maintain an open-source server which enables highly reliable distributed coordination. -- [windows-only patch](../patches/zookeeper-windows.patch)"
  REPO "repo" ${ZK_REPO} "Zookeeper main repo"
  VER ${ZK_VER}
  GIT_ORIGIN ${ZK_REPO}
  GIT_TAG release-${ZK_VER}
  DLURL ${ZK_REPO}/archive/release-${ZK_VER}.tar.gz
  DLMD5 790c9b028f2f9c6ed17938a396365b74
  DLNAME zookeeper-release-${ZK_VER}.tar.gz
  PATCH ${ZOO_PATCH} #This is only defined for Windows builds
)
set(CPP_UNIT_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/cppunit)
set(CPP_UNIT_VER 1.12.1)
set(CPP_UNIT
  NAME cppunit
  WEB "CppUnit" http://cppunit.sourceforge.net "CppUnit-C++ port of JUnit"
  LICENSE "LGPL" http://cppunit.sourceforge.net/doc/cvs "LGPL"
  DESC "C++ port of JUnit"
  VER ${CPP_UNIT_VER}
  DLURL http://sourceforge.net/projects/cppunit/files/cppunit/1.12.1/cppunit-1.12.1.tar.gz
  DLMD5 bd30e9cf5523cdfc019b94f5e1d7fd19
)
########################################
# Some helper stuff to clean up the builds
macro(zookeepercheckDependencies)
  find_program(javac javac)
  if(${javac} MATCHES javac-NOTFOUND)
    message(FATAL_ERROR "javac required for zookeeper")
  endif()

  find_program(ant ant)
  if(${ant} MATCHES ant-NOTFOUND)
    message(FATAL_ERROR "ant required for zookeeper")
  endif()
endmacro()
########################################
# build
function(build_zookeeper)
  if(NOT (XP_DEFAULT OR XP_PRO_ZOOKEEPER))
    return()
  endif()

  if(NOT TARGET zookeeper)
    xpPatchProject(${PRO_ZOOKEEPER})
  endif()

  zookeeperCheckDependencies()

  configure_file(${PRO_DIR}/use/useop-zookeeper-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-zookeeper-config.cmake
                 COPYONLY)

  ExternalProject_Get_Property(zookeeper SOURCE_DIR)
  ExternalProject_Add(zookeeper_ant DEPENDS zookeeper
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ant compile_jute
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
  )

  if(WIN32)
    #TODO Still need to convert the Windows build to use ExternalProject...
    set(ZK_INCLUDE_PATH ${SOURCE_DIR}/src/c/include)
    set(zookeeper_hdr_files
      ${ZK_INCLUDE_PATH}/proto.h
      ${ZK_INCLUDE_PATH}/recordio.h
      ${ZK_INCLUDE_PATH}/zookeeper.h
      ${ZK_INCLUDE_PATH}/zookeeper_log.h
      ${ZK_INCLUDE_PATH}/zookeeper_version.h
      ${SOURCE_DIR}/src/c/generated/zookeeper.jute.h
      ${SOURCE_DIR}/src/c/src/winport.h
      ${ZK_INCLUDE_PATH}/winconfig.h
      ${ZK_INCLUDE_PATH}/winstdint.h)

    add_custom_target(zookeeper_build ALL
      WORKING_DIRECTORY ${ZK_REPO_PATH}/src/c
      COMMAND msbuild ${ZK_REPO_PATH}/src/c/zookeeper.sln /p:Configuration=Release\;Platform=x64 /t:zookeeper:rebuild
      COMMAND msbuild ${ZK_REPO_PATH}/src/c/zookeeper.sln /p:Configuration=Debug\;Platform=x64 /t:zookeeper:rebuild
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/zookeeper
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy ${ZK_REPO_PATH}/src/c/x64/Debug/libzookeeperd-mt.lib ${STAGE_DIR}/lib/libzookeeperd-mt.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${ZK_REPO_PATH}/src/c/x64/Release/libzookeeper-mt.lib ${STAGE_DIR}/lib/libzookeeper-mt.lib
      DEPENDS zookeeper zookeeper_ant
    )

    # copy the needed header files
    foreach(hdr_file ${zookeeper_hdr_files})
      get_filename_component(hdr_name ${hdr_file} NAME)
      add_custom_command(TARGET zookeeper_build POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${hdr_file} ${STAGE_DIR}/include/zookeeper/${hdr_name}
      )
    endforeach()
  else()
    # This is only needed for non-windows build
    xpDownloadProject(${CPP_UNIT})

    set(ACLOCAL_STR "aclocal -I ${SOURCE_DIR}/src/c/cppunit-${CPP_UNIT_VER}")
    ExternalProject_Add(zookeeper_configure DEPENDS zookeeper_ant download_cppunit-${CPP_UNIT_VER}.tar.gz
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      SOURCE_DIR ${SOURCE_DIR}/src/c
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E tar xzf ${DWNLD_DIR}/cppunit-${CPP_UNIT_VER}.tar.gz
      BUILD_COMMAND ${CMAKE_COMMAND} -E env ACLOCAL=${ACLOCAL_STR} autoreconf -if -W none
      BUILD_IN_SOURCE 1
      INSTALL_COMMAND ""
    )

    ExternalProject_Add(zookeeper_Release DEPENDS zookeeper_configure
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      SOURCE_DIR ${SOURCE_DIR}/src/c
      CONFIGURE_COMMAND ./configure --without-cppunit --prefix=${STAGE_DIR}
      BUILD_COMMAND $(MAKE) clean && $(MAKE)
      BUILD_IN_SOURCE 1
      INSTALL_COMMAND $(MAKE) install
    )

    if(${XP_BUILD_DEBUG})
      #TODO need to make zookeeper add a suffix so debug build can go in lib folder
      ExternalProject_Add(zookeeper_Debug DEPENDS zookeeper_Release
        DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
        SOURCE_DIR ${SOURCE_DIR}/src/c
        CONFIGURE_COMMAND ./configure --without-cppunit --libdir=${STAGE_DIR}/lib/zookeeperDebug --enable-debug
        BUILD_COMMAND $(MAKE) clean && $(MAKE)
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND $(MAKE) install-libLTLIBRARIES
      )
    endif()
  endif()

  # Copy LICENSE, NOTICE, and README files to STAGE_DIR
  ExternalProject_Add(zookeeper_install_files DEPENDS zookeeper_Release
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${NULL_DIR} CONFIGURE_COMMAND "" BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/zookeeper &&
      ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/src/c/LICENSE ${STAGE_DIR}/share/zookeeper &&
      ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/src/c/NOTICE.txt ${STAGE_DIR}/share/zookeeper &&
      ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/src/c/README ${STAGE_DIR}/share/zookeeper
  )

endfunction(build_zookeeper)
