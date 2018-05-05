if(COMMAND xpFindPkg)
  xpFindPkg(PKGS openssl) # dependencies
endif()

# So ${PQSL_LIBS} can be used
opFindPkg(PKGS psql)

# determine OP_BUILD_STATIC
include(${CMAKE_CURRENT_LIST_DIR}/opopts.cmake)

# Get the current link libraries (INTERFACE_LINK_LIBRARIES) and add the given
# additional libraries to the target (sets INTERFACE_LINK_LIBRARIES)
# @param target_name name of the target for which additional link libraries are added
# @param additional_libs the additional link libraries to be added
macro(opAddLinkLibs target_name additional_libs)
  get_target_property(linked_libs ${target_name} INTERFACE_LINK_LIBRARIES)
  set_target_properties(${target_name} PROPERTIES
      INTERFACE_LINK_LIBRARIES "${linked_libs};${additional_libs}")
endmacro()

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)
set(QT5_BASE_PATH ${OP_ROOTDIR}/qt5)
set(QT5_PLUGIN_PATH ${OP_ROOTDIR}/qt5/plugins)
set(QT5_LIBEXEC_PATH ${OP_ROOTDIR}/qt5/libexec)
set(QT5_RESOURCE_PATH ${OP_ROOTDIR}/qt5/resources)

# if the user did not specify components, locate all of them
if (NOT DEFINED Qt5_LIBRARIES)
  set(Qt5_LIBRARIES
    Concurrent
    Core
    DBus
    Gui
    Multimedia
    MultimediaWidgets
    Network
    OpenGL
    Sql
    Svg
    Test
    WebChannel
    WebEngine
    WebEngineCore
    WebEngineWidgets
    WebSockets
    WebView
    Widgets
    Xml
    XmlPatterns)
endif()

# find the Qt5 package
find_package(Qt5
  REQUIRED
  COMPONENTS ${Qt5_LIBRARIES}
  PATHS ${QT5_BASE_PATH}/lib/cmake/Qt5
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_BUILDS_PATH
  NO_CMAKE_PACKAGE_REGISTRY
  NO_CMAKE_SYSTEM_PATH
  NO_CMAKE_SYSTEM_PACKAGE_REGISTRY)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  if(${build_type} STREQUAL debug)
    set(QT5_MAIN_LIB ${QT5_BASE_PATH}/lib/qtmaind.lib)
    set(QT5_PLATFORM_LIB
      ${QT5_BASE_PATH}/plugins/platforms/qwindowsd.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qicod.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qjp2d.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qsvgd.lib
      ${QT5_BASE_PATH}/lib/Qt5PlatformSupportd.lib
      ${QT5_BASE_PATH}/lib/Qt5Svgd.lib
      ${QT5_BASE_PATH}/lib/qtharfbuzzngd.lib
      ${QT5_BASE_PATH}/lib/qtfreetyped.lib
      winmm.lib
      imm32.lib
      opengl32.lib)
  else()
    set(QT5_MAIN_LIB ${QT5_BASE_PATH}/lib/qtmain.lib)
    set(QT5_PLATFORM_LIB
      ${QT5_BASE_PATH}/plugins/platforms/qwindows.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qico.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qjp2.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qsvg.lib
      ${QT5_BASE_PATH}/lib/Qt5PlatformSupport.lib
      ${QT5_BASE_PATH}/lib/Qt5Svg.lib
      ${QT5_BASE_PATH}/lib/qtharfbuzzng.lib
      ${QT5_BASE_PATH}/lib/qtfreetype.lib
      winmm.lib
      imm32.lib
      opengl32.lib)
  endif()

  # define the qtpcre and qtharfbuzzng libraries as dependencies to QtWidgets
  get_target_property(linked_libs
    Qt5::Widgets INTERFACE_LINK_LIBRARIES
  )
  get_target_property(QT5WIDGETS_LOCATION
    Qt5::Widgets LOCATION)
  get_filename_component(QT5_LIB_PATH ${QT5WIDGETS_LOCATION} DIRECTORY)

  set(debugpcre "${QT5_LIB_PATH}/qtpcred.lib")
  set(debugharfbuzzng "${QT5_LIB_PATH}/qtharfbuzzngd.lib")
  set(releasepcre "${QT5_LIB_PATH}/qtpcre.lib")
  set(releaseharfbuzzng "${QT5_LIB_PATH}/qtharfbuzzng.lib")
  set(releaseqwindows "${QT5_BASE_PATH}/plugins/platforms/qwindows.lib")
  set(debugqwindows "${QT5_BASE_PATH}/plugins/platforms/qwindowsd.lib")

  set(debug_gen_expr "$<$<CONFIG:Debug>:${debugpcre}>;$<$<CONFIG:Debug>:${debugharfbuzzng}>;$<$<CONFIG:Debug>:${debugqwindows}>")
  set(nondebug_gen_expr "$<$<NOT:$<CONFIG:Debug>>:${releasepcre}>;$<$<NOT:$<CONFIG:Debug>>:${releaseharfbuzzng}>;$<$<NOT:$<CONFIG:Debug>>:${releaseqwindows}>")
  set(gen_expr "${debug_gen_expr};${nondebug_gen_expr}")
  set(ssl_lib ssl-s$<$<CONFIG:Debug>:d>.lib)
  set(crypto_lib crypto-s$<$<CONFIG:Debug>:d>.lib)

  # TODO these could be cleaned up using the opAddLinkLibs macro
  set_target_properties(
    Qt5::Widgets
    PROPERTIES
    INTERFACE_LINK_LIBRARIES "${gen_expr};${linked_libs}"
  )
  set_target_properties(
    Qt5::Core
    PROPERTIES
    INTERFACE_LINK_LIBRARIES "${gen_expr};${linked_libs}"
  )
  set_target_properties(
    Qt5::Network
    PROPERTIES
    INTERFACE_LINK_LIBRARIES "ws2_32;${ssl_lib};crypt32;msi"
  )
  set_target_properties(
    Qt5::Gui
    PROPERTIES
    INTERFACE_LINK_LIBRARIES "${externpro_DIR}/lib/glew32.lib;glu32;opengl32"
  )
  set_target_properties(
    Qt5::Sql
    PROPERTIES
    INTERFACE_LINK_LIBRARIES "${PSQL_LIBS}"
  )
else() # Not WIN32
  if(OP_BUILD_STATIC)
    # Link libs for using Qt plugins (should cover all of them but not all have been tested)
    # To statically link the plugins should just need to include Q_IMPORT_PLUGIN(thePlugin)
    # to the source file needing the plugin, then add ${QT5_PLUGIN_LIBS} to the executable
    # target_link_libraries list
    # TRICKY The ordering here matters for some libraries, be careful moving them around
    set(QT5_PLUGIN_LIBS
      ${QT5_BASE_PATH}/plugins/audio/libqtaudio_alsa.a
      ${QT5_BASE_PATH}/plugins/audio/libqtmedia_pulse.a
      ${QT5_BASE_PATH}/plugins/bearer/libqconnmanbearer.a
      ${QT5_BASE_PATH}/plugins/bearer/libqgenericbearer.a
      ${QT5_BASE_PATH}/plugins/bearer/libqnmbearer.a
      ${QT5_BASE_PATH}/plugins/designer/libqdeclarativeview.a
      ${QT5_BASE_PATH}/plugins/generic/libqtuiotouchplugin.a
      ${QT5_BASE_PATH}/plugins/geoservices/libqtgeoservices_mapbox.a
      ${QT5_BASE_PATH}/plugins/geoservices/libqtgeoservices_nokia.a
      ${QT5_BASE_PATH}/plugins/geoservices/libqtgeoservices_osm.a
      ${QT5_BASE_PATH}/plugins/iconengines/libqsvgicon.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqdds.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqicns.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqico.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqjp2.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqmng.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqsvg.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqtga.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqtiff.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqwbmp.a
      ${QT5_BASE_PATH}/plugins/imageformats/libqwebp.a
      ${QT5_BASE_PATH}/plugins/mediaservice/libqtmedia_audioengine.a
      ${QT5_BASE_PATH}/plugins/platforminputcontexts/libcomposeplatforminputcontextplugin.a
      ${QT5_BASE_PATH}/plugins/platforminputcontexts/libibusplatforminputcontextplugin.a
      ${QT5_BASE_PATH}/plugins/platforms/libqlinuxfb.a
      ${QT5_BASE_PATH}/plugins/platforms/libqminimal.a
      ${QT5_BASE_PATH}/plugins/platforms/libqoffscreen.a
      ${QT5_BASE_PATH}/plugins/platforms/libqxcb.a
      ${QT5_BASE_PATH}/plugins/platformthemes/libqgtk2.a
      ${QT5_BASE_PATH}/plugins/playlistformats/libqtmultimedia_m3u.a
      ${QT5_BASE_PATH}/plugins/position/libqtposition_positionpoll.a
      ${QT5_BASE_PATH}/plugins/qml1tooling/libqmldbg_inspector.a
      ${QT5_BASE_PATH}/plugins/qml1tooling/libqmldbg_tcp_qtdeclarative.a
      ${QT5_BASE_PATH}/plugins/qmltooling/libqmldbg_qtquick2.a
      ${QT5_BASE_PATH}/plugins/qmltooling/libqmldbg_tcp.a
      ${QT5_BASE_PATH}/plugins/sceneparsers/libgltfsceneparser.a
      ${QT5_BASE_PATH}/plugins/sensorgestures/libqtsensorgestures_plugin.a
      ${QT5_BASE_PATH}/plugins/sensorgestures/libqtsensorgestures_shakeplugin.a
      ${QT5_BASE_PATH}/plugins/sensors/libqtsensors_generic.a
      ${QT5_BASE_PATH}/plugins/sensors/libqtsensors_linuxsys.a
      ${QT5_BASE_PATH}/plugins/sqldrivers/libqsqlite.a
      ${QT5_BASE_PATH}/plugins/xcbglintegrations/libqxcb-glx-integration.a
      ${QT5_BASE_PATH}/lib/libQt5XcbQpa.a
      ${QT5_BASE_PATH}/lib/libxcb-static.a
      ${QT5_BASE_PATH}/lib/libQt5PlatformSupport.a
      Qt5::DBus
      atk-1.0
      asound
      cairo
      fontconfig
      freetype
      ICE
      gdk_pixbuf-2.0
      gdk-x11-2.0
      gio-2.0
      gmodule-2.0
      gtk-x11-2.0
      mng
      pango-1.0
      pangocairo-1.0
      pangoft2-1.0
      SM
      X11-xcb
      xcb
      Xi
      Xrender
      )


    # set path for the qtpcre and qtharfbuzzng libraries
    set(pcre "${QT5_BASE_PATH}/lib/libqtpcre.a")
    set(harfbuzzng "${QT5_BASE_PATH}/lib/libqtharfbuzzng.a")

    # Some of the libraries required to build the modules statically don't get
    # automatically added when using cmake - add them here
    # Note - the commented out ones don't currently have additional dependencies or
    # all the additional dependencies are brought in by other required Qt5 modules
    #opAddLinkLibs(Qt5::Concurrent "")
    opAddLinkLibs(Qt5::Core "${pcre};m;dl;gthread-2.0;rt;glib-2.0")
    #opAddLinkLibs(Qt5::DBus "")
    opAddLinkLibs(Qt5::Gui "${harfbuzzng};GL")
    opAddLinkLibs(Qt5::Multimedia "pulse")
    #opAddLinkLibs(Qt5::MultimediaWidgets "")
    #opAddLinkLibs(Qt5::Network "")
    #opAddLinkLibs(Qt5::OpenGL "")
    opAddLinkLibs(Qt5::Sql ${PSQL_LIBS})
    #opAddLinkLibs(Qt5::Svg "")
    #opAddLinkLibs(Qt5::Test "")
    opAddLinkLibs(Qt5::Widgets "${harfbuzzng};gobject-2.0;Xext;X11")
    #opAddLinkLibs(Qt5::Xml "")
    #opAddLinkLibs(Qt5::XmlPatterns "")
  endif()
endif()

# copy the qt5 plugins to the output directory (not needed if statically linking)
# @param destination is the destination path for the copy
# @param plugin_dirs a list of plugin directories to copy
macro(opDeployQt5Plugins destination plugin_dirs)
  foreach(plugindir IN LISTS plugin_dirs)
    get_filename_component(plugindirname ${plugindir} NAME)

    file(GLOB pluginfiles ${QT5_BASE_PATH}/plugins/${plugindir}/*)
    foreach(pluginfile ${pluginfiles})
      get_filename_component(pluginfilename ${pluginfile} NAME)
      file(COPY ${pluginfile}
           DESTINATION ${destination}/${plugindirname}
      )
    endforeach()
  endforeach()
endmacro()

# Add commands to the given target name to deploy the Qt5 WebEngine
# @param target_name the target to which the WebEngine should be deployed
macro(opDeployQtWebEngine target_name)
  add_custom_command(TARGET ${target_name} POST_BUILD
   COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${QT5_LIBEXEC_PATH}/QtWebEngineProcess
    $<TARGET_FILE_DIR:${target_name}>
  )
  add_custom_command(TARGET ${target_name} POST_BUILD
   COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${QT5_RESOURCE_PATH}
    $<TARGET_FILE_DIR:${target_name}>
  )
endmacro()

