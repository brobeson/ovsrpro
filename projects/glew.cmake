xpProOption(glew)
set(GLEW_VERSION 1.13.0)
set(GLEW_URL http://glew.sourceforge.net)
set(REPO https://github.com/nigels-com/glew)
set(PRO_GLEW
  NAME glew
  WEB "GLEW" ${GLEW_URL} "GLEW on sourceforge.net"
  LICENSE "open" ${GLEW_URL}/credits.html "Modified BSD, Mesa 3-D (MIT), and Khronos (MIT)"
  DESC "The OpenGL Extension Wrangler Library"
  REPO "repo" ${REPO} "GLEW main repo on github"
  VER ${GLEW_VERSION}
  GIT_ORIGIN git://github.com/nigels-com/glew.git
  GIT_TAG glew-${GLEW_VERSION}
  DLURL https://downloads.sourceforge.net/project/glew/glew/${GLEW_VERSION}/glew-${GLEW_VERSION}.tgz
  DLMD5 7cbada3166d2aadfc4169c4283701066
  PATCH ${PATCH_DIR}/glew.patch
)

function(build_glew)
  if(NOT (XP_DEFAULT OR XP_PRO_GLEW))
    return()
  endif()
  set(XP_CONFIGURE -DBUILD_UTILS=OFF -DBUILD_SHARED_LIBS=OFF)
  xpCmakeBuild(glew "" "${XP_CONFIGURE}")
endfunction()
