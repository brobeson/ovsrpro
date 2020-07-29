# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost interprocess
set(VER 1.63.0)
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" VER2_ ${VER}) # 1_63
set(REPO https://github.com/smanders/interprocess)
set(PRO_BOOSTINTERPROCESS${VER2_}
  NAME boostinterprocess${VER2_}
  SUPERPRO boost
  SUBDIR . # since the patch is all headers, apply to root of boost, not libs/interprocess
  WEB "interprocess" http://boost.org/libs/interprocess "boost interprocess website"
  LICENSE "open" http://www.boost.org/users/license.html "Boost Software License"
  DESC "interprocess (shared memory, memory mapped files, process-shared mutexes, condition variables, containers and allocators)"
  REPO "repo" ${REPO} "forked interprocess repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/interprocess.git
  GIT_UPSTREAM git://github.com/boostorg/interprocess.git
  GIT_TRACKING_BRANCH develop
  GIT_TAG xp${VER}
  GIT_REF boost-${VER}
  PATCH ${PATCH_DIR}/boost.interprocess.${VER2_}.patch
  PATCH_STRIP 2 # Strip NUM leading components from file names (defaults to 1)
  DIFF ${REPO}/compare/boostorg:
  )
