########################################
# zeromq 
########################################
xpProOption(zeromq)
set(ZEROMQ_VERSION 4.2.2)
set(ZEROMQ_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/zeromq)
set(REPO https://github.com/zeromq/libzmq)
set(PRO_ZEROMQ
  NAME zeromq
  WEB "ZeroMQ" https://zeromq.org "ZeroMQ - Home"
  LICENSE "LGPL" ${REPO}/blob/master/README.md "LGPL v3 (See License Section)"
  DESC "ZeroMQ is a lightweight messaging kernel that extends standard socket interfaces with more powerful features."
  REPO "repo" ${REPO} "ZeroMQ repo on github"
  VER ${ZEROMQ_VERSION}
  DLURL ${REPO}/archive/v${ZEROMQ_VERSION}.tar.gz
  DLMD5 18599afc000dacd4d5715abbb18bfe6b
  DLNAME libzmq-${ZEROMQ_VERSION}.tar.gz
)

function(build_zeromq)
  if (NOT (XP_DEFAULT OR XP_PRO_ZEROMQ))
    return()
  endif()
  configure_file(${PRO_DIR}/use/useop-zeromq-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
  )

  xpSetPostfix()
  set(XP_CONFIGURE
    -DCMAKE_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_INCLUDEDIR=include/zeromq
    )
  xpCmakeBuild(zeromq "" "${XP_CONFIGURE}")

endfunction()
