# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# boost
set(VER 1.67.0)
string(REPLACE "." "_" VER_ ${VER}) # 1_67_0
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1_\\2" VER2_ ${VER}) # 1_67
xpProOption(boost${VER2_})
set(REPO https://github.com/boostorg/boost)
set(PRO_BOOST${VER2_}
  NAME boost${VER2_}
  WEB "boost" http://www.boost.org/ "Boost website"
  LICENSE "open" http://www.boost.org/users/license.html "Boost Software License"
  DESC "libraries that give C++ a boost"
  REPO "repo" ${REPO} "boost repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/boostorg/boost.git
  GIT_TAG boost-${VER} # what to 'git checkout'
  DLURL https://dl.bintray.com/boostorg/release/${VER}/source/boost_${VER_}.tar.bz2
  DLMD5 ced776cb19428ab8488774e1415535ab
  SUBPRO boostgil${VER2_} boostmpl${VER2_} boostunits${VER2_}
  )
