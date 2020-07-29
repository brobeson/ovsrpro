# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

set(prj boost)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
if(MSVC AND MSVC_VERSION GREATER 1910 AND MSVC_VERSION LESS 1919) # VS 15.0 2017
  set(XP_USE_LATEST_BOOST ON)
endif()
if(NOT DEFINED XP_USE_LATEST_BOOST)
  option(XP_USE_LATEST_BOOST "build with boost @BOOST_NEWVER@ instead of @BOOST_OLDVER@" OFF)
endif()
if(XP_USE_LATEST_BOOST)
  set(BOOST_VER @BOOST_NEWVER@)
else()
  set(BOOST_VER @BOOST_OLDVER@)
endif()
set(BOOST_VERSION "${BOOST_VER} [@PROJECT_NAME@]")
if(NOT DEFINED Boost_LIBS)
  set(Boost_LIBS # dependency order
    log_setup  # ldd:log,regex
    log        # ldd/cmake:filesystem,thread cmake:log_setup,regex
    ######
    thread     # ldd/cmake:system cmake:atomic,chrono,date_time
    timer      # ldd/cmake:chrono
    ######
    chrono     # ldd/cmake:system
    filesystem # ldd/cmake:system
    graph      # ldd:regex
    iostreams  # cmake:regex
    random     # ldd/cmake:system
    wserialization # ldd/cmake:serialization
    ######
    atomic
    container
    date_time
    exception
    #prg_exec_monitor # excluded because of link errors
    program_options
    regex
    serialization
    signals
    system
    test_exec_monitor
    unit_test_framework
    )
  # NOTE: determined boost library dependency order by building boost on linux
  # with link=shared and runtime-link=shared and using ldd
  # cmake dependencies by examining cmake's Modules/FindBoost.cmake
endif()
list(FIND Boost_LIBS iostreams idx)
if(NOT ${idx} EQUAL -1)
  # iostreams depends on zlib bzip2
  xpGetPkgVar(zlib LIBRARIES) # sets ZLIB_LIBRARIES
  xpGetPkgVar(bzip2 LIBRARIES) # sets BZIP2_LIBRARIES
endif()
unset(Boost_INCLUDE_DIR CACHE)
unset(Boost_LIBRARY_DIR CACHE)
foreach(lib ${Boost_LIBS})
  string(TOUPPER ${lib} UPPERLIB)
  unset(Boost_${UPPERLIB}_LIBRARY_DEBUG CACHE)
  unset(Boost_${UPPERLIB}_LIBRARY_RELEASE CACHE)
endforeach()
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1.\\2" BOOST_VER2 ${BOOST_VER})
if(UNIX)
  set(Boost_ADDITIONAL_VERSIONS ${BOOST_VER} ${BOOST_VER2})
  if(DEFINED ZLIB_LIBRARIES AND DEFINED BZIP2_LIBRARIES)
    set(syslibs $<TARGET_FILE:${ZLIB_LIBRARIES}> $<TARGET_FILE:${BZIP2_LIBRARIES}>)
  endif()
  include(CheckLibraryExists)
  function(checkLibraryConcat lib symbol liblist)
    string(TOUPPER ${lib} LIB)
    check_library_exists("${lib}" "${symbol}" "" XP_BOOST_HAS_${LIB})
    if(XP_BOOST_HAS_${LIB})
      list(APPEND ${liblist} ${lib})
      set(${liblist} ${${liblist}} PARENT_SCOPE)
    endif()
  endfunction()
  checkLibraryConcat(m pow syslibs)
  checkLibraryConcat(pthread pthread_create syslibs)
  checkLibraryConcat(rt shm_open syslibs)
  # see FindBoost.cmake for details on the following variables
  set(Boost_FIND_QUIETLY TRUE)
  set(Boost_NO_SYSTEM_PATHS TRUE)
  set(Boost_USE_STATIC_LIBS ON)
  set(Boost_USE_MULTITHREADED ON)
  set(Boost_USE_STATIC_RUNTIME ON)
  #set(Boost_DEBUG TRUE) # enable debugging output of FindBoost.cmake
  #set(Boost_DETAILED_FAILURE_MSG) # output detailed information
  set(BOOST_ROOT ${XP_ROOTDIR})
  # TODO: remove the following once FindBoost.cmake: uses -dumpfullversion, detects clang
  if(TRUE) #"${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    include(${CMAKE_CURRENT_LIST_DIR}/xpfunmac.cmake)
    xpGetCompilerPrefix(Boost_COMPILER GCC_TWO_VER)
    set(Boost_COMPILER "-${Boost_COMPILER}")
  endif()
  # TODO: remove the following once CMAKE_CXX_COMPILER_ARCHITECTURE_ID is defined for all supported compilers
  #   https://gitlab.kitware.com/cmake/cmake/issues/17702
  # boost versions >= 1.66.0 add an additional modifier to the library name and some compilers don't set the
  # cmake variable used in FindBoost.cmake that's used to set _boost_ARCHITECTURE_TAG
  #   https://gitlab.kitware.com/cmake/cmake/issues/17701
  if(BOOST_VER VERSION_GREATER_EQUAL "1.66.0" AND "x${CMAKE_CXX_COMPILER_ARCHITECTURE_ID}" STREQUAL "x")
    execute_process(COMMAND uname --machine
      OUTPUT_VARIABLE unameMachine
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_VARIABLE unameErr
      )
    if(DEFINED unameMachine AND NOT unameErr)
      if(unameMachine STREQUAL x86_64)
        set(CMAKE_CXX_COMPILER_ARCHITECTURE_ID x64)
      endif()
    endif()
  endif()
  find_package(Boost ${BOOST_VER} REQUIRED COMPONENTS ${Boost_LIBS})
  set(${PRJ}_FOUND ${Boost_FOUND})
  set(${PRJ}_INCLUDE_DIR ${Boost_INCLUDE_DIRS})
  function(listPrependToAll var prefix)
    set(listVar)
    foreach(f ${ARGN})
      list(APPEND listVar "${prefix}${f}")
    endforeach()
    set(${var} "${listVar}" PARENT_SCOPE)
  endfunction()
  listPrependToAll(boostLibs "Boost::" ${Boost_LIBS})
  # TRICKY: Boost_LIBRARIES returned from find_package() introduces hard-coded absolute
  # paths and wrecks havoc on cmake-generated targets files, hence boostLibs
  set(${PRJ}_LIBRARIES ${boostLibs} ${syslibs})
  set(reqVars ${PRJ}_VERSION ${PRJ}_INCLUDE_DIR ${PRJ}_LIBRARIES)
else()
  string(REPLACE "." "_" VER_ ${BOOST_VER2})
  set(${PRJ}_INCLUDE_DIR ${XP_ROOTDIR}/include/boost-${VER_})
  if(EXISTS ${${PRJ}_INCLUDE_DIR} AND IS_DIRECTORY ${${PRJ}_INCLUDE_DIR})
    set(${PRJ}_FOUND TRUE)
  else()
    set(${PRJ}_FOUND FALSE)
  endif()
  link_directories(${XP_ROOTDIR}/lib)
  set(reqVars ${PRJ}_VERSION ${PRJ}_INCLUDE_DIR)
  if(DEFINED ZLIB_LIBRARIES AND DEFINED BZIP2_LIBRARIES)
    set(${PRJ}_DEFINITIONS
      -DBOOST_ZLIB_BINARY=$<TARGET_FILE:${ZLIB_LIBRARIES}>
      -DBOOST_BZIP2_BINARY=$<TARGET_FILE:${BZIP2_LIBRARIES}>
      )
    list(APPEND reqVars ${PRJ}_DEFINITIONS)
  endif()
endif()
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
