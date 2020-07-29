# WARNING
# This file is downloaded and modified by CMake.
# Manual edits will be overwritten.

file(GLOB files ${src})
foreach(f ${files})
  get_filename_component(pth ${f} PATH)
  get_filename_component(ext ${f} EXT)
  get_filename_component(nam ${f} NAME_WE)
  execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${f} ${pth}/${nam}${suffix}${ext})
endforeach()
