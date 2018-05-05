########################################
# hdf5
########################################
xpProOption(hdf5)
set(HDF5_VER 1.8.16)
set(PRO_HDF5
  NAME hdf5
  WEB "HDF-GROUP" http://www.hdfgroup.org "The HDF Group"
  LICENSE "open" https://www.hdfgroup.org/ftp/HDF5/current/src/unpacked/COPYING "HDF5 License"
  DESC "HDF5 is a data model, library, and file format for storing and managing data"
  VER ${HDF5_VER}
  DLURL http://www.hdfgroup.org/ftp/HDF5/prev-releases/hdf5-1.8/hdf5-${HDF5_VER}/src/CMake-hdf5-${HDF5_VER}.tar.gz
  DLMD5 a7559a329dfe74e2dac7d5e2d224b1c2
  PATCH ${PATCH_DIR}/hdf5.patch
)
########################################
function(patch_hdf5)
  if(NOT (XP_DEFAULT OR XP_PRO_HDF5))
    return()
  endif()

  xpPatchProject(${PRO_HDF5})

  if(WIN32)
    if(${XP_BUILD_STATIC})
      ExternalProject_Get_Property(hdf5 SOURCE_DIR)
      ExternalProject_Add_Step(hdf5 hdf5_setFlags
        WORKING_DIRECTORY ${SOURCE_DIR}
        # Update hdf5 to use /MT
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/hdf5-windows-static-UserMacros.cmake ${SOURCE_DIR}/hdf5-1.8.16/UserMacros.cmake
        # Decompress SZip, update to use /MT, then re-zip
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${SOURCE_DIR}/SZip.tar.gz
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/hdf5-windows-static-UserMacros.cmake ${SOURCE_DIR}/SZip/UserMacros.cmake
        COMMAND ${CMAKE_COMMAND} -E tar cfvz ${SOURCE_DIR}/SZip.tar.gz ${SOURCE_DIR}/SZip
        # Decompress ZLib, update to use /MT, then re-zip
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${SOURCE_DIR}/ZLib.tar.gz
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/hdf5-windows-static-UserMacros.cmake ${SOURCE_DIR}/ZLib/UserMacros.cmake
        COMMAND ${CMAKE_COMMAND} -E tar cfvz ${SOURCE_DIR}/ZLib.tar.gz ${SOURCE_DIR}/ZLib
        DEPENDEES download
      )
    endif()
  endif()
endfunction()
########################################
function(build_hdf5)
  if (NOT (XP_DEFAULT OR XP_PRO_HDF5))
    return()
  endif()

  if(NOT TARGET hdf5)
    patch_hdf5()
  endif()

  configure_file(${PRO_DIR}/use/useop-hdf5-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-hdf5-config.cmake
                 COPYONLY)

  # Build hdf5, just building the static libraries for now...
  ExternalProject_Get_Property(hdf5 SOURCE_DIR)
  set(XP_CONFIGURE
      -DBUILD_SHARED_LIBS=OFF
      -DHDF5_INSTALL_INCLUDE_DIR=${STAGE_DIR}/include/hdf5
      -DHDF5_INSTALL_DATA_DIR=${STAGE_DIR}/share/hdf5
      -DHDF5_INSTALL_CMAKE_DIR=${STAGE_DIR}/share/cmake
      -DHDF5_ALLOW_EXTERNAL_SUPPORT=TGZ
      -DTGZPATH=${SOURCE_DIR}
      -DHDF5_BUILD_FORTRAN=OFF
      -DHDF5_ENABLE_F2003=OFF
      -DHDF5_PACKAGE_EXTLIBS=ON
      -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
      -DZLIB_PACKAGE_NAME=zlib
      -DZLIB_TGZ_NAME=ZLib.tar.gz
      -DHDF5_ENABLE_SZIP_SUPPORT=ON
      -DHDF5_ENABLE_SZIP_ENCODING=ON
      -DSZIP_PACKAGE_NAME=szip
      -DSZIP_TGZ_NAME=SZip.tar.gz
  )

  xpCmakeBuild(hdf5 "" "${XP_CONFIGURE}")

  # The "old" way that stuff was built would be to generate a package, untar it, then copy the bin, include and lib folders out
  # Surely there is a better way, but haven't figured out how to get the zlib and szip
  # libraries and includes to install in the hdf5 install command, so manually copy some pieces
  ExternalProject_Get_Property(hdf5_Release BINARY_DIR)
  ExternalProject_Add(hdf5_install_files DEPENDS hdf5_Release
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${NULL_DIR} CONFIGURE_COMMAND "" BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/bin/libszip.a ${STAGE_DIR}/lib &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/bin/libz.a ${STAGE_DIR}/lib &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/SZIP-prefix/src/SZIP/src/ricehdf.h ${STAGE_DIR}/include/hdf5 &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/SZIP-prefix/src/SZIP/src/szip_adpt.h ${STAGE_DIR}/include/hdf5 &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/SZIP-prefix/src/SZIP/src/szlib.h ${STAGE_DIR}/include/hdf5 &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/SZIP-prefix/src/SZIP-build/SZconfig.h ${STAGE_DIR}/include/hdf5 &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/ZLIB-prefix/src/ZLIB/zlib.h ${STAGE_DIR}/include/hdf5 &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/ZLIB-prefix/src/ZLIB-build/zconf.h ${STAGE_DIR}/include/hdf5
  )

   if(${XP_BUILD_DEBUG})
  # For debug the only things that need copied are the debug versions of SZIP and ZLIB
  ExternalProject_Get_Property(hdf5_Debug BINARY_DIR)
  ExternalProject_Add(hdf5_install_debug_files DEPENDS hdf5_Debug
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${NULL_DIR} CONFIGURE_COMMAND "" BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/bin/libszip_debug.a ${STAGE_DIR}/lib &&
      ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/hdf5-${HDF5_VER}/bin/libz_debug.a ${STAGE_DIR}/lib
  )
   endif()

  endfunction()
