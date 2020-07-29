# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost
xpProOption(boost DBG)
set(BOOST_OLDVER 1.63.0)
set(BOOST_NEWVER 1.67.0)
####################
function(patch_boost)
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" ov ${BOOST_OLDVER})
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" nv ${BOOST_NEWVER})
  if(NOT (XP_DEFAULT OR XP_PRO_BOOST OR XP_PRO_BOOST${ov} OR XP_PRO_BOOST${nv}))
    return()
  endif()
  if(XP_DEFAULT)
    if(MSVC AND MSVC_VERSION GREATER 1910 AND MSVC_VERSION LESS 1919) # VS 15.0 2017
      xpListAppendIfDne(BOOST_VERSIONS ${BOOST_NEWVER}) # edit this to set default version(s) to build
    else()
      xpListAppendIfDne(BOOST_VERSIONS ${BOOST_OLDVER} ${BOOST_NEWVER}) # edit this to set default version(s) to build
    endif()
  else()
    if(XP_PRO_BOOST AND NOT (XP_PRO_BOOST${ov} OR XP_PRO_BOOST${nv}))
      if(MSVC AND MSVC_VERSION GREATER 1910 AND MSVC_VERSION LESS 1919) # VS 15.0 2017
        set(XP_PRO_BOOST${ov} OFF CACHE BOOL "include boost${ov}" FORCE)
      else()
        set(XP_PRO_BOOST${ov} ON CACHE BOOL "include boost${ov}" FORCE)
      endif()
      set(XP_PRO_BOOST${nv} ON CACHE BOOL "include boost${nv}" FORCE)
    endif()
    if(XP_PRO_BOOST${ov})
      xpListAppendIfDne(BOOST_VERSIONS ${BOOST_OLDVER})
    endif()
    if(XP_PRO_BOOST${nv})
      xpListAppendIfDne(BOOST_VERSIONS ${BOOST_NEWVER})
    endif()
  endif()
  foreach(ver ${BOOST_VERSIONS})
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" ver2_ ${ver})
    xpPatchProject(${PRO_BOOST${ver2_}})
  endforeach()
  set(BOOST_VERSIONS ${BOOST_VERSIONS} PARENT_SCOPE) # make BOOST_VERSIONS available to build_boost
endfunction()
####################
function(build_boost)
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" ov ${BOOST_OLDVER})
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" nv ${BOOST_NEWVER})
  if(NOT (XP_DEFAULT OR XP_PRO_BOOST${ov} OR XP_PRO_BOOST${nv}))
    return()
  endif()
  cmake_parse_arguments(boost "" TARGETS "" ${ARGN})
  if(NOT (XP_DEFAULT OR XP_PRO_ZLIB))
    message(STATUS "boost.cmake: requires zlib")
    set(XP_PRO_ZLIB ON CACHE BOOL "include zlib" FORCE)
    xpPatchProject(${PRO_ZLIB})
  endif()
  if(NOT (XP_DEFAULT OR XP_PRO_BZIP2))
    message(STATUS "boost.cmake: requires bzip2")
    set(XP_PRO_BZIP2 ON CACHE BOOL "include bzip2" FORCE)
    xpPatchProject(${PRO_BZIP2})
  endif()
  build_zlib(zlibTgts)
  build_bzip2(bzip2Tgts)
  list(APPEND tgts
    ${zlibTgts}
    ${bzip2Tgts}
    )
  #configure_file(${PRO_DIR}/use/usexp-boost-config.cmake ${STAGE_DIR}/share/cmake/
    #@ONLY NEWLINE_STYLE LF
    #)
  foreach(ver ${BOOST_VERSIONS})
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" ver2_ ${ver})
    ExternalProject_Get_Property(boost${ver2_} SOURCE_DIR)
    build_boostb2(PRO boost${ver2_} BOOTSTRAP ${SOURCE_DIR}/tools/build
      B2PATH b2path TARGETS tgts
      )
    build_boostlibs(PRO boost${ver2_} B2PATH ${b2path} TARGETS tgts)
    if(DEFINED boost_TARGETS)
      xpListAppendIfDne(${boost_TARGETS} "${tgts}")
    endif()
  endforeach()
  if(DEFINED boost_TARGETS)
    set(${boost_TARGETS} "${${boost_TARGETS}}" PARENT_SCOPE)
  endif()
endfunction()
####################
function(build_boostb2)
  # @param[in] PRO - project id (boost, boostold)
  # @param[in] BOOTSTRAP - path to bootstrap.[bat|sh]
  # @param[out] B2PATH - location of built b2
  # @param[out] TARGETS - external project target name
  set(oneValueArgs PRO BOOTSTRAP B2PATH TARGETS)
  cmake_parse_arguments(bb "" "${oneValueArgs}" "" ${ARGN})
  if(NOT DEFINED bb_PRO OR NOT DEFINED bb_BOOTSTRAP)
    message(FATAL_ERROR "boost.cmake: build_boostb2: required inputs not set")
  endif()
  if(DEFINED bb_TARGETS)
    string(TOUPPER ${bb_PRO} PRO)
    xpGetArgValue(${PRO_${PRO}} ARG SUBPRO VALUES subs)
    list(REMOVE_ITEM subs unknown)
    foreach(sub ${subs})
      xpListAppendIfDne(${bb_TARGETS} ${bb_PRO}_${sub})
    endforeach()
    xpListAppendIfDne(${bb_TARGETS} ${bb_PRO}.build)
    set(${bb_TARGETS} "${${bb_TARGETS}}" PARENT_SCOPE)
  endif()
  get_property(base_DIR DIRECTORY PROPERTY "EP_BASE")
  set(boostbld_DIR ${base_DIR}/bld.${bb_PRO})
  if(DEFINED bb_B2PATH)
    if(MSVC)
      set(${bb_B2PATH} ${boostbld_DIR}/bin/b2.exe PARENT_SCOPE)
    else()
      set(${bb_B2PATH} ${boostbld_DIR}/bin/b2 PARENT_SCOPE)
    endif()
  endif()
  if(TARGET ${bb_PRO}.build)
    return()
  endif()
  if(MSVC)
    set(XP_CONFIGURE <SOURCE_DIR>/bootstrap.bat)
    set(boost_b2 <SOURCE_DIR>/b2.exe toolset=msvc)
  else()
    set(XP_CONFIGURE <SOURCE_DIR>/bootstrap.sh)
    # NOTE: specifying the toolset (clang) here gives output similar to this:
    #   [ 20%] Performing configure step for 'boost.build'
    #   Bootstrapping the build engine with toolset clang... engine/bin.linuxx86_64/b2
    # But there are still warnings:
    #   [ 23%] Performing install step for 'boost.build'
    #   warning: No toolsets are configured.
    #   warning: Configuring default toolset "gcc".
    #   warning: If the default is wrong, your build may not work correctly.
    #   warning: Use the "toolset=xxxxx" option to override our guess.
    #   warning: For more configuration options, please consult
    #   warning: http://boost.org/boost-build2/doc/html/bbv2/advanced/configuration.html
    # So, even though we specify the toolset to be clang, it still uses the default gcc.
    # Apparently, we would also need to have a user-config.jam if we cared that b2 was built
    # with clang instaed of gcc?
    if(CMAKE_COMPILER_IS_GNUCXX)
      list(APPEND XP_CONFIGURE --with-toolset=gcc)
    elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang") # LLVM/Apple Clang
      list(APPEND XP_CONFIGURE --with-toolset=clang)
    else()
      message(FATAL_ERROR "boost.cmake: compiler support lacking: ${CMAKE_CXX_COMPILER_ID}")
    endif()
    set(boost_b2 <SOURCE_DIR>/b2 --ignore-site-config)
  endif()
  ExternalProject_Add(${bb_PRO}.build DEPENDS ${bb_PRO}
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${bb_BOOTSTRAP}
    CONFIGURE_COMMAND ${XP_CONFIGURE}
    BUILD_COMMAND "" BUILD_IN_SOURCE 1 # bootstrap fails if we don't build in source
    # BUILD_IN_SOURCE NOTE: introduces the following files on MSW...
    #       tools/build/bootstrap.log
    #       tools/build/v2/b2.exe
    #       tools/build/v2/bin/
    #       tools/build/v2/bjam.exe
    #       tools/build/v2/engine/bin.ntx86/
    #       tools/build/v2/engine/bootstrap/
    INSTALL_COMMAND ${boost_b2} install --prefix=${boostbld_DIR} INSTALL_DIR ${NULL_DIR}
    )
  set_property(TARGET ${bb_PRO}.build PROPERTY FOLDER ${bld_folder})
endfunction()
####################
function(stringToList stringlist lvalue)
  if(NOT "${stringlist}" STREQUAL "")
    string(STRIP ${stringlist} stringlist) # remove leading and trailing spaces
    string(REPLACE " -" ";-" listlist ${stringlist})
    foreach(item ${listlist})
      list(APPEND templist ${lvalue}="${item}")
    endforeach()
    set(${lvalue} "${templist}" PARENT_SCOPE)
  endif()
endfunction()
####################
function(build_boostlibs)
  # @param[in] PRO - project id (boost, boostold)
  # @param[in] B2PATH - path to b2
  # @param[in/out] TARGETS - input deps, output list of all targets
  set(oneValueArgs PRO B2PATH TARGETS)
  cmake_parse_arguments(bl "" "${oneValueArgs}" "" ${ARGN})
  if(NOT DEFINED bl_PRO OR NOT DEFINED bl_B2PATH)
    message(FATAL_ERROR "boost.cmake: build_boostlibs: required inputs not set")
  endif()
  if(DEFINED bl_TARGETS)
    set(${bl_PRO}_DEPENDS ${${bl_TARGETS}})
  endif()
  if(XP_BUILD_DEBUG_ALL AND XP_BUILD_RELEASE)
    set(boost_VARIANT "debug,release")
  elseif(XP_PRO_BOOST_BUILD_DBG AND XP_BUILD_RELEASE)
    set(boost_VARIANT "debug,release")
  elseif(XP_BUILD_RELEASE)
    set(boost_VARIANT "release")
  # NOTE: currently externpro doesn't support building *only* Debug
  elseif(XP_BUILD_DEBUG) # so this elseif is "just in case..."
    set(boost_VARIANT "debug")
  endif()
  if(MSVC)
    if(MSVC_VERSION GREATER 1910 AND MSVC_VERSION LESS 1919) # VS 15.0 2017
      set(boost_TOOLSET msvc-14.1)
    elseif(MSVC_VERSION EQUAL 1900) # VS 14.0 2015
      set(boost_TOOLSET msvc-14.0)
    elseif(MSVC_VERSION EQUAL 1800) # VS 12.0 2013
      set(boost_TOOLSET msvc-12.0)
    elseif(MSVC_VERSION EQUAL 1700) # VS 11.0 2012
      set(boost_TOOLSET msvc-11.0)
    elseif(MSVC_VERSION EQUAL 1600) # VS 10.0 2010
      set(boost_TOOLSET msvc-10.0)
    elseif(MSVC_VERSION EQUAL 1500) # VS 9.0 2008
      set(boost_TOOLSET msvc-9.0)
    else()
      message(FATAL_ERROR "boost.cmake: MSVC compiler support lacking")
    endif()
    if(XP_BUILD_STATIC)
      set(boost_RUNTIME_LINK static)
    else()
      set(boost_RUNTIME_LINK shared)
    endif()
  else()
    if(CMAKE_COMPILER_IS_GNUCXX)
      set(boost_TOOLSET gcc)
    elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang") # LLVM/Apple Clang
      set(boost_TOOLSET clang)
    else()
      message(FATAL_ERROR "boost.cmake: compiler support lacking: ${CMAKE_CXX_COMPILER_ID}")
    endif()
    include(${MODULES_DIR}/flags.cmake) # populates CMAKE_*_FLAGS
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
      # clang: warning: argument unused during compilation: '-arch x86_64'
      xpStringRemoveIfExists(CMAKE_CXX_FLAGS "-arch x86_64")
      xpStringRemoveIfExists(CMAKE_C_FLAGS "-arch x86_64")
      xpStringRemoveIfExists(CMAKE_EXE_LINKER_FLAGS "-arch x86_64")
    endif()
    stringToList("${CMAKE_CXX_FLAGS}" cxxflags)
    stringToList("${CMAKE_C_FLAGS}" cflags)
    stringToList("${CMAKE_EXE_LINKER_FLAGS}" linkflags)
    set(boost_FLAGS "${cxxflags}" "${cflags}" "${linkflags}")
    set(boost_RUNTIME_LINK static)
  endif()
  set(boost_BUILD ${bl_B2PATH}
    --ignore-site-config --layout=versioned link=static threading=multi
    address-model=${BUILD_PLATFORM} variant=${boost_VARIANT}
    runtime-link=${boost_RUNTIME_LINK} toolset=${boost_TOOLSET} ${boost_FLAGS}
    )
  # libraries with build issues
  set(exclude_libs locale math mpi python)
  # libraries excluded until there's an argument to use them
  list(APPEND exclude_libs context coroutine fiber graph_parallel math type_erasure wave)
  if(ver EQUAL BOOST_OLDVER) # libs specific to old version
    list(APPEND exclude_libs coroutine2)
  elseif(ver EQUAL BOOST_NEWVER) # libs introduced in new version
    list(APPEND exclude_libs contract stacktrace)
  endif()
  foreach(lib ${exclude_libs})
    list(APPEND boost_BUILD --without-${lib})
  endforeach()
  # TRICKY: need zlib, bzip2 include directories at cmake-time (before they're built)
  # so can't use xpGetPkgVar, xpFindPkg, etc - this complicates having multiple versions
  # of zlib and bzip2 (boost will have to choose a version here)
  xpGetArgValue(${PRO_ZLIB} ARG VER VALUE zlibVer)
  xpGetArgValue(${PRO_BZIP2} ARG VER VALUE bzip2Ver)
  set(zlibInc ${STAGE_DIR}/include/zlib_${zlibVer}/zlib)
  set(bzip2Inc ${STAGE_DIR}/include/bzip2_${bzip2Ver}/bzip2)
  list(APPEND boost_BUILD -s ZLIB_INCLUDE=${zlibInc} -s ZLIB_LIBPATH=${STAGE_DIR}/lib)
  list(APPEND boost_BUILD -s BZIP2_INCLUDE=${bzip2Inc} -s BZIP2_LIBPATH=${STAGE_DIR}/lib)
  if(WIN32)
    include(${STAGE_DIR}/share/cmake/xpopts.cmake)
    xpSetPostfix()
    # TRICKY: BINARY (zlibstatic, bz2) needs to be the name of the binary,
    # not including the file extension, or the "lib" prefix on UNIX
    list(APPEND boost_BUILD -s ZLIB_BINARY=zlibstatic_${zlibVer}${CMAKE_RELEASE_POSTFIX})
    list(APPEND boost_BUILD -s BZIP2_BINARY=bz2_${bzip2Ver}${CMAKE_RELEASE_POSTFIX})
  endif()
  set(boost_INSTALL install --libdir=${STAGE_DIR}/lib --includedir=${STAGE_DIR}/include)
  addproject_boost(${bl_PRO}_bld)
  list(APPEND ${bl_PRO}_DEPENDS ${bl_PRO}_bld) # serialize the build
  if(DEFINED bl_TARGETS)
    xpListAppendIfDne(${bl_TARGETS} "${${bl_PRO}_DEPENDS}")
    set(${bl_TARGETS} "${${bl_TARGETS}}" PARENT_SCOPE)
  endif()
endfunction()
####################
function(addproject_boost XP_TARGET)
  if(NOT TARGET ${XP_TARGET})
    get_property(baseDir DIRECTORY PROPERTY "EP_BASE")
    if(UNIX) # TODO hopefully this conditional will be only temporary
      list(APPEND boost_BUILD --build-dir=${baseDir}/Build/${XP_TARGET})
      # non-critical errors on MSW, that cause automated build server to report FAILURE:
      # * libs\regex\build\has_icu_test.cpp(12):
      #   fatal error C1083: Cannot open include file: 'unicode/uversion.h': No such file or directory
      # * libs\math\config\has_gcc_visibility.cpp(7):
      #   fatal error C1189: #error :  "This is a GCC specific test case".
      # reported here: http://permalink.gmane.org/gmane.comp.lib.boost.user/75695
      # if we build boost (on MSW) within source tree, the errors don't happen
    endif()
    set(boost_STAGE stage --stagedir=${baseDir}/Build/${XP_TARGET}/stage)
    ExternalProject_Get_Property(${bl_PRO} SOURCE_DIR)
    ExternalProject_Add(${XP_TARGET} DEPENDS ${${bl_PRO}_DEPENDS}
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      SOURCE_DIR ${SOURCE_DIR} CONFIGURE_COMMAND ""
      BUILD_COMMAND ${boost_BUILD} ${boost_STAGE} BUILD_IN_SOURCE 1 # <BINARY_DIR>==<SOURCE_DIR>
      INSTALL_COMMAND ${boost_BUILD} ${boost_INSTALL} INSTALL_DIR ${NULL_DIR}
      )
    set_property(TARGET ${XP_TARGET} PROPERTY FOLDER ${bld_folder})
    if(XP_BUILD_VERBOSE)
      message(STATUS "target ${XP_TARGET}")
      xpVerboseListing("[BUILD]" "${boost_BUILD}")
      xpVerboseListing("[STAGE]" "${boost_STAGE}")
      xpVerboseListing("[INSTALL]" "${boost_INSTALL}")
      xpVerboseListing("[DEPENDS]" "${${bl_PRO}_DEPENDS}")
    else()
      message(STATUS "target ${XP_TARGET}")
    endif()
  endif()
endfunction()
