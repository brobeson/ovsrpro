########################################
# glew
########################################
xpProOption(glew)
########################################
set(GLEW_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/glew)
set(VER 1.13.0)
set(PRO_GLEW
  NAME glew
  WEB "GLEW" http://glew.sourceforge.net/ "The OpenGL Extension Wrangler Library"
  LICENSE "open" http://glew.sourceforge.net/credits.html "Modified BSD, Mesa 3-D (MIT), and Khronos (MIT)"
  DESC "The OpenGL Extension Wrangler Library (GLEW) is a cross-platform open-source C/C++ extension loading library."
  REPO "repo" https://github.com/nigels-com/glew "GLEW repo on github"
  VER ${VER}
  DLURL https://downloads.sourceforge.net/project/glew/glew/${VER}/glew-${VER}.tgz
  DLMD5 7cbada3166d2aadfc4169c4283701066
)
########################################
function(patch_glew)
  if(NOT (XP_DEFAULT OR XP_PRO_GLEW))
    return()
  endif()

  xpPatchProject(${PRO_GLEW})

  if(WIN32)
    # fix the static debug build to use /MTd
    ExternalProject_Add_Step(glew glew_updateDebug
      COMMENT "Patching glew's static debug to use /MTd"
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/glew_static.vcxproj ${GLEW_SRC_PATH}/build/vc12/glew_static.vcxproj
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/glew.sln ${GLEW_SRC_PATH}/build/vc12/glew.sln
      DEPENDEES download
    )
  endif()
endfunction()
########################################
function(build_glew)
  if(NOT (XP_DEFAULT OR XP_PRO_GLEW))
    return()
  endif()

  if(NOT TARGET glew)
    patch_glew()
  endif()

  configure_file(${PRO_DIR}/use/useop-glew-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-glew-config.cmake
                 COPYONLY)

  if(WIN32)
    #TODO Still need to convert the Windows build to use ExternalProject...
    add_custom_target(glew_build ALL
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      #COMMAND devenv ${GLEW_SRC_PATH}/build/vc12/glew.sln /build "Release"
      COMMAND msbuild ${GLEW_SRC_PATH}/build/vc12/glew.sln /p:Configuration=Release\;Platform=x64 /t:glew_static:rebuild\;glew_shared:rebuild
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/include/GL ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/lib/Release/x64 ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/bin/Release/x64 ${STAGE_DIR}/bin
      DEPENDS glew
    )
    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET glew_build POST_BUILD
        WORKING_DIRECTORY ${GLEW_SRC_PATH}
        #COMMAND devenv ${GLEW_SRC_PATH}/build/vc12/glew.sln /build "Debug"
        COMMAND msbuild ${GLEW_SRC_PATH}/build/vc12/glew.sln /p:Configuration=Debug\;Platform=x64 /t:glew_static:rebuild\;glew_shared:rebuild
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/lib/Debug/x64 ${STAGE_DIR}/lib
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/bin/Debug/x64 ${STAGE_DIR}/bin
        DEPENDS glew
      )
    endif()
  else()
    ExternalProject_Get_Property(glew SOURCE_DIR)
    ExternalProject_Add(glew_Release DEPENDS glew
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      SOURCE_DIR ${SOURCE_DIR}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND $(MAKE) clean && $(MAKE)
      BUILD_IN_SOURCE 1
      INSTALL_COMMAND $(MAKE) install.lib install.include install.bin LIBDIR=${STAGE_DIR}/lib INCDIR=${STAGE_DIR}/include/GL BINDIR=${STAGE_DIR}/bin
    )

   if(${XP_BUILD_DEBUG})
     #TODO need to make glew add a suffix so debug build can go in lib folder
     ExternalProject_Add(glew_Debug DEPENDS glew_Release
       DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
       SOURCE_DIR ${SOURCE_DIR}
       CONFIGURE_COMMAND ""
       BUILD_COMMAND $(MAKE) clean && $(MAKE) debug
       BUILD_IN_SOURCE 1
       INSTALL_COMMAND $(MAKE) install.lib LIBDIR=${STAGE_DIR}/lib/glewdebug
     )
   endif()
  endif()

  # Copy LICENSE file to STAGE_DIR
  ExternalProject_Add(glew_install_files DEPENDS glew_Release
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${NULL_DIR} CONFIGURE_COMMAND "" BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/glew &&
      ${CMAKE_COMMAND} -E copy ${GLEW_SRC_PATH}/LICENSE.txt ${STAGE_DIR}/share/glew
  )

endfunction()
