# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost units
set(VER 1.63.0)
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" VER2_ ${VER}) # 1_63
set(REPO https://github.com/smanders/units)
set(PRO_BOOSTUNITS${VER2_}
  NAME boostunits${VER2_}
  SUPERPRO boost
  SUBDIR . # since the patch is all headers, apply to root of boost, not libs/units
  WEB "units" http://boost.org/libs/units "boost units website"
  LICENSE "open" http://www.boost.org/users/license.html "Boost Software License"
  DESC "zero-overhead dimensional analysis and unit/quantity manipulation and conversion"
  REPO "repo" ${REPO} "forked units repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/units.git
  GIT_UPSTREAM git://github.com/boostorg/units.git
  GIT_TRACKING_BRANCH develop
  GIT_TAG xp${VER}
  GIT_REF boost-${VER}
  PATCH ${PATCH_DIR}/boost.units.${VER2_}.patch
  PATCH_STRIP 2 # Strip NUM leading components from file names (defaults to 1)
  DIFF ${REPO}/compare/boostorg:
  )
