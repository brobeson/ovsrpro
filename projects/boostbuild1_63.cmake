# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost build
set(VER 1.63.0)
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" VER2_ ${VER}) # 1_63
set(REPO https://github.com/smanders/build)
set(PRO_BOOSTBUILD${VER2_}
  NAME boostbuild${VER2_}
  SUPERPRO boost
  SUBDIR tools/build
  WEB "build" http://boost.org/tools/build "boost build website"
  LICENSE "open" http://www.boost.org/users/license.html "Boost Software License"
  DESC "boost build"
  REPO "repo" ${REPO} "forked build repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/build.git
  GIT_UPSTREAM git://github.com/boostorg/build.git
  GIT_TRACKING_BRANCH develop
  GIT_TAG xp${VER}
  GIT_REF boost-${VER}
  PATCH ${PATCH_DIR}/boost.build.${VER2_}.patch
  DIFF ${REPO}/compare/boostorg:
  )
