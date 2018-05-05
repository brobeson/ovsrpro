# - Find an ovsrpro installation.
# ovsrpro_DIR
################################################################################
# should match xpGetCompilerPrefix in externpro's xpfunmac.cmake
# NOTE: wanted to use externpro version, but chicken-egg problem
function(getCompilerPrefix _ret)
  set(options GCC_TWO_VER)
  cmake_parse_arguments(x "${options}" "" "" ${ARGN})
  if(MSVC)
    if(MSVC14)
      set(prefix vc140)
    elseif(MSVC12)
      set(prefix vc120)
    elseif(MSVC11)
      set(prefix vc110)
    elseif(MSVC10)
      set(prefix vc100)
    elseif(MSVC90)
      set(prefix vc90)
    elseif(MSVC80)
      set(prefix vc80)
    elseif(MSVC71)
      set(prefix vc71)
    elseif(MSVC70)
      set(prefix vc70)
    elseif(MSVC60)
      set(prefix vc60)
    else()
      message(SEND_ERROR "Findovsrpro.cmake: MSVC compiler support lacking")
    endif()
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    exec_program(${CMAKE_CXX_COMPILER}
      ARGS ${CMAKE_CXX_COMPILER_ARG1} -dumpfullversion -dumpversion
      OUTPUT_VARIABLE GCC_VERSION
      )
    if(X_GCC_TWO_VER)
      set(digits "\\1\\1")
    else()
      set(digits "\\1\\2\\3")
    endif()
    string(REGEX REPLACE "([0-9]+)\\.([0-9]+)\\.([0-9]+)?"
      "gcc${digits}"
      prefix ${GCC_VERSION}
      )
  elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang") # LLVM/Apple Clang (clang.llvm.org)
    if(${CMAKE_SYSTEM_NAME} STREQUAL Darwin)
      exec_program(${CMAKE_CXX_COMPILER}
        ARGS ${CMAKE_CXX_COMPILER_ARG1} -dumpversion
        OUTPUT_VARIABLE CLANG_VERSION
        )
      string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?"
        "clang-darwin\\1\\2" # match boost naming
        prefix ${CLANG_VERSION}
        )
    else()
      string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?"
        "clang\\1\\2" # match boost naming
        prefix ${CMAKE_CXX_COMPILER_VERSION}
        )
    endif()
  else()
    message(SEND_ERROR "Findovsrpro.cmake: compiler support lacking: ${CMAKE_CXX_COMPILER_ID}")
  endif()
  set(${_ret} ${prefix} PARENT_SCOPE)
endfunction()
function(getNumBits _ret)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(numBits 64)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(numBits 32)
  else()
    message(FATAL_ERROR "numBits not 64 or 32")
  endif()
  set(${_ret} ${numBits} PARENT_SCOPE)
endfunction()
################################################################################
# TRICKY: clear cached variables each time we cmake so we can change
# ovsrpro_REV and reuse the same build directory
unset(ovsrpro_DIR CACHE)
################################################################################
# find the path to the ovsrpro directory
getCompilerPrefix(COMPILER)
getNumBits(BITS)
set(ovsrpro_SIG ${ovsrpro_REV}-${COMPILER}-${BITS})
set(PFX86 "ProgramFiles(x86)")
find_path(ovsrpro_DIR
  NAMES
    ovsrpro_${ovsrpro_SIG}.txt
  PATHS
    # build versions
    C:/src/ovsrpro/_bld/ovsrpro_${ovsrpro_SIG}
    ~/src/ovsrpro/_bld/ovsrpro_${ovsrpro_SIG}
    # environment variable
    "$ENV{ovsrpro}/ovsrpro ${ovsrpro_SIG}"
    "$ENV{ovsrpro_DIR}/ovsrpro-${ovsrpro_SIG}-${CMAKE_SYSTEM_NAME}"
    # installed versions
    "$ENV{ProgramW6432}/ovsrpro ${ovsrpro_SIG}"
    "$ENV{${PFX86}}/ovsrpro ${ovsrpro_SIG}"
    "~/ovsrpro/ovsrpro-${ovsrpro_SIG}-${CMAKE_SYSTEM_NAME}"
    "/opt/ovsrpro/ovsrpro-${ovsrpro_SIG}-${CMAKE_SYSTEM_NAME}"
    # symbolic link install option
    "/opt/ovsrpro/ovsrpro"
    # rpm installed location
    "/opt/ovsrpro"
  DOC "ovsrpro directory"
  )
if(NOT ovsrpro_DIR)
  if(DEFINED ovsrpro_INSTALLER_LOCATION)
    message(FATAL_ERROR "ovsrpro ${ovsrpro_SIG} not found.\n${ovsrpro_INSTALLER_LOCATION}")
  else()
    message(FATAL_ERROR "ovsrpro ${ovsrpro_SIG} not found")
  endif()
else()
  set(moduleDir ${ovsrpro_DIR}/share/cmake)
  set(findFile ${moduleDir}/Findovsrpro.cmake)
  execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files ${CMAKE_CURRENT_LIST_FILE} ${findFile}
    RESULT_VARIABLE filesDiff
    OUTPUT_QUIET
    ERROR_QUIET
    )
  if(filesDiff)
    message(STATUS "local: ${CMAKE_CURRENT_LIST_FILE}.")
    message(STATUS "ovsrpro: ${findFile}.")
    message(AUTHOR_WARNING "Find scripts don't match. You may want to update the local with the ovsrpro version.")
  endif()
  message(STATUS "Found ovsrpro: ${ovsrpro_DIR}")
  list(APPEND OP_MODULE_PATH ${moduleDir})
  link_directories(${ovsrpro_DIR}/lib)
  if(EXISTS ${moduleDir}/opfunmac.cmake)
    include(${moduleDir}/opfunmac.cmake)
  endif()
endif()
