########################################
# librdkafka
########################################
xpProOption(librdkafka)
set(VER v0.9.5)
set(REPO https://github.com/distributePro/librdkafka)
set(REPO_UPSTREAM https://github.com/edenhill/librdkafka)
set(PRO_LIBRDKAFKA
  NAME librdkafka
  WEB "librdkafka" ${REPO_UPSTREAM} "librdkafka on github"
  LICENSE "open" ${REPO_UPSTREAM}/blob/master/LICENSE "2-clause BSD license"
  DESC "librdkafka is a C library implementation of the Apache Kafka protocol, containing both Producer and Consumer support -- [windows-only patch](../patches/librdkafka-windows.patch)"
  REPO "repo" ${REPO} "distributePro fork of librdkafka repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/distributepro/librdkafka.git
  GIT_UPSTREAM git://github.com/edenhill/librdkafka.git
  GIT_TAG xp-${VER} # what to 'git checkout'
  GIT_REF ${VER} # create path from this tag to 'git checkout'
  DLURL ${REPO_UPSTREAM}/archive/${VER}.tar.gz
  DLMD5 8e5685baa01554108ae8c8e9c97dc495
  DLNAME librdkafka-${VER}.tar.gz
  PATCH ${PATCH_DIR}/librdkafka.patch
  DIFF ${REPO}/compare/edenhill:
  )
########################################
# patch
function(patch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpPatchProject(${PRO_LIBRDKAFKA})

  #TODO Verify that this patch is still necessary now that it is being built via Cmake
  if(WIN32)
    # setup the patch file with knowledge of the externpro directory
    set(tmpPatchFile ${CMAKE_BINARY_DIR}/xpbase/tmp/librdkafka_repo/librdkafka-windows.patch)
    configure_file(${PATCH_DIR}/librdkafka-windows.patch
                   ${tmpPatchFile} NEWLINE_STYLE UNIX)

    ExternalProject_Get_Property(librdkafka SOURCE_DIR)
    ExternalProject_Add_Step(librdkafka librdkafka_win_patch
      WORKING_DIRECTORY ${SOURCE_DIR}
      COMMAND ${GIT_EXECUTABLE} apply ${tmpPatchFile}
      DEPENDEES patch
    )
  endif()
endfunction(patch_librdkafka)
########################################
# Add zlib to the desired target
macro(addLibs target)
  if(WIN32)
    message("adding libs to ${target}")
    target_link_libraries(${target}
      ${XP_ROOTDIR}/lib/zlibstatic-s.lib
      ${XP_ROOTDIR}/lib/crypto-s.lib
      ${XP_ROOTDIR}/lib/ssl-s.lib)
  endif()
endmacro()
########################################
# build
function(build_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  configure_file(${PRO_DIR}/use/useop-librdkafka-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
  )

#TODO Need to test this on Windows with the cmake build, leaving this here for reference until that is tested...
#  if(WIN32)
#  ExternalProject_Get_Property(librdkafka SOURCE_DIR)
#    #TODO Still need to convert the Windows build to use ExternalProject...
#    add_custom_target(librdkafka_build ALL
#      WORKING_DIRECTORY ${SOURCE_DIR}/win32
#      COMMAND msbuild librdkafka.sln /p:Configuration=Release\;Platform=x64 /t:librdkafka:rebuild
#      COMMAND msbuild librdkafka.sln /p:Configuration=Release\;Platform=x64 /t:librdkafkacpp:rebuild
#      COMMAND msbuild librdkafka.sln /p:Configuration=Debug\;Platform=x64 /t:librdkafka:rebuild
#      COMMAND msbuild librdkafka.sln /p:Configuration=Debug\;Platform=x64 /t:librdkafkacpp:rebuild
#      COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/win32/x64/Debug/librdkafkad.lib ${STAGE_DIR}/lib/librdkafkad.lib
#      COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/win32/x64/Debug/librdkafka++d.lib ${STAGE_DIR}/lib/librdkafka++d.lib
#      COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/win32/x64/Release/librdkafka.lib ${STAGE_DIR}/lib/librdkafka.lib
#      COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_DIR}/win32/x64/Release/librdkafka++.lib ${STAGE_DIR}/lib/librdkafka++.lib
#      DEPENDS librdkafka
#    )

#    # define the header files
#    set(hdr_files
#      ${SOURCE_DIR}/src/rdkafka.h
#      ${SOURCE_DIR}/src-cpp/rdkafkacpp.h
#    )

#    # copy the header files to the staging area
#    foreach(hdr_file ${hdr_files})
#      get_filename_component(hdr_name ${hdr_file} NAME)
#      add_custom_command(TARGET librdkafka_build POST_BUILD
#        COMMAND ${CMAKE_COMMAND} -E copy ${hdr_file} ${STAGE_DIR}/include/librdkafka/${hdr_name}
#      )
#    endforeach()
#  else()

  xpSetPostfix()
  # Ensure both the C and C++ versions are built with the -fPIC flag
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fPIC")
  xpStringAppendIfDne(CMAKE_C_FLAGS "-fPIC")
  set(XP_CONFIGURE
      -DCMAKE_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
     )
  xpCmakeBuild(librdkafka "" "${XP_CONFIGURE}")

endfunction()
