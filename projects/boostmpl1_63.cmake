# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost mpl
set(VER 1.63.0)
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" VER2_ ${VER}) # 1_63
set(REPO https://github.com/smanders/mpl)
set(PRO_BOOSTMPL${VER2_}
  NAME boostmpl${VER2_}
  SUPERPRO boost
  SUBDIR . # since the patch is all headers, apply to root of boost, not libs/mpl
  WEB "mpl" http://boost.org/libs/mpl "boost mpl website"
  LICENSE "open" http://www.boost.org/users/license.html "Boost Software License"
  DESC "mpl (metaprogramming library)"
  REPO "repo" ${REPO} "forked mpl repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/boostorg/mpl.git
  GIT_TAG boost-${VER}
  GIT_ORIGIN git://github.com/smanders/mpl.git
  GIT_UPSTREAM git://github.com/boostorg/mpl.git
  GIT_TRACKING_BRANCH develop
  GIT_TAG xp${VER}
  GIT_REF boost-${VER}
  PATCH ${PATCH_DIR}/boost.mpl.${VER2_}.patch
  PATCH_STRIP 2 # Strip NUM leading components from file names (defaults to 1)
  DIFF ${REPO}/compare/boostorg:
  )
