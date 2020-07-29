# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost gil
set(VER 1.63.0)
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" VER2_ ${VER}) # 1_63
set(REPO https://github.com/smanders/gil)
set(PRO_BOOSTGIL${VER2_}
  NAME boostgil${VER2_}
  SUPERPRO boost
  SUBDIR . # since the patch is all headers, apply to root of boost, not libs/gil
  WEB "gil" http://boost.org/libs/gil "boost gil website"
  LICENSE "open" http://www.boost.org/users/license.html "Boost Software License"
  DESC "gil (generic image library)"
  REPO "repo" ${REPO} "forked gil repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/gil.git
  GIT_UPSTREAM git://github.com/boostorg/gil.git
  GIT_TRACKING_BRANCH develop
  GIT_TAG xp${VER}
  GIT_REF boost-${VER}
  PATCH ${PATCH_DIR}/boost.gil.${VER2_}.patch
  PATCH_STRIP 2 # Strip NUM leading components from file names (defaults to 1)
  DIFF ${REPO}/compare/boostorg:
  )
