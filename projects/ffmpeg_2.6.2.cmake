# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

# ffmpeg
set(VER ${FFMPEG_CFGVER})
xpProOption(ffmpeg_${VER})
set(REPO https://github.com/ndrasmussen/FFmpeg)
set(PRO_FFMPEG_${VER}
  NAME ffmpeg_${VER}
  WEB "ffmpeg" https://www.ffmpeg.org/ "ffmpeg website"
  LICENSE "LGPL" https://www.ffmpeg.org/legal.html "Lesser GPL v2.1"
  DESC "complete, cross-platform solution to record, convert and stream audio and video"
  REPO "repo" ${REPO} "forked ffmpeg repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/ndrasmussen/FFmpeg.git
  GIT_UPSTREAM git://github.com/FFmpeg/FFmpeg.git
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF n${VER} # create patch from this tag to 'git checkout'
  DLURL http://ffmpeg.org/releases/ffmpeg-${VER}.tar.bz2
  DLMD5 e75d598921285d6775f20164a91936ac
  PATCH ${PATCH_DIR}/ffmpeg_${VER}.patch
  DIFF ${REPO}/compare/FFmpeg:
  )
