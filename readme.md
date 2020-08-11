# ovsrpro

Build Overseer [dependencies](projects/README.md) by leveraging
[externpro](https://github.com/smanders/externpro).

## Installing ovsrpro

1. Download the installer for the release you need, for the your development
   environment (OS, compiler, etc). See
   <https://github.com/distributePro/ovsrpro/releases>.
1. Download the SHA256 checksum file for your release.
1. Validate the checksum.
   ```bash
   sha256sum --check ovsrpro-18.10.1-gcc631-64-Linux.sh.sha256
   ```
1. Run the installer.
   ```bash
   sudo ./ovsrpro-18.10.1-gcc631-64-Linux.sh --prefix=/opt/ovsrpro/ --include-subdir
   ```
   The recommended location for installation is */opt/ovsrpro/*. We also
   recommend using the subdirectory. Both these options are in this example.

## Using ovsrpro

Copy the file *share/cmake/Findovsrpro.cmake* from your installation to your
project's root directory. In your *CMakeLists.txt* add these lines:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
find_package(ovsrpro 18.10.1 EXACT REQUIRED)
```

A few notes about the `find_package()` command:

1. The version is required in the command.
1. `EXACT` is required. If it's omitted, it is forced by *Findovsrpro.cmake*
   and a warning is issued.

If ovsrpro is found, the following variables are set:

<!-- markdownlint-disable MD013 -->
| Variable | Description |
|:---|:---|
| `ovsrpro_FOUND` | This is set to `true` if ovsrpro is found, and `false` if it not. |
| `ovsrpro_ROOT_DIR` | This is set to the root path where ovsrpro is installed. An example is */opt/ovsrpro/ovsrpro-20.04.1-gcc921-64-Linux/* |
| `ovsrpro_INCLUDE_DIR` | This is the root path to the project headers files. Each project will have a separate subdirectory within this path. An example is */opt/ovsrpro/ovsrpro-20.04.1-gcc921-64-Linux/include/*. Ovsrpro users typically should not need to use this. |
| `ovsrpro_LIBRARY_DIR` | This is the path to the project library files. An example is */opt/ovsrpro/ovsrpro-20.04.1-gcc921-64-Linux/lib/*. Ovsrpro users typically should not need to use this. |
| `ovsrpro_CONFIG_PATH` | This is the path to find the Qt5 CMake find scripts. This is needed to find Qt5 using `find_package()`. |
<!-- markdownlint-disable MD013 -->

`${ovsrpro_ROOT_DIR}`*/share/cmake* is appended to `CMAKE_MODULE_PATH`
automatically. To find ovsrpro projects, except for Qt5, add `find_package()`
commands.

```cmake
find_package(librdkafka)
find_package(zookeeper)
```

See each Find module's documentation for accepted components, define variables,
and imported targets.

To use Qt5, you must specify `HINTS` and `NO_DEFAULT_PATH` in `find_package()`.
This uses the CMake configuration scripts shipped with Qt5.

```cmake
find_package(
   Qt5
   HINTS "${ovsrpro_CONFIG_PATH}"
   NO_DEFAULT_PATH
   COMPONENTS Core
)
```

Here is a full example:

```cmake
find_package(ovsrpro 20.04.1 REQUIRED EXACT)
find_package(librdkafka COMPONENTS CPP)
find_package(zookeeper COMPONENTS CPP)
find_package(
   Qt5
   HINTS "${ovsrpro_CONFIG_PATH}"
   NO_DEFAULT_PATH
   COMPONENTS Core Gui
)
add_executable(AnApplication AnApplication.cpp)
target_link_libraries(
   AnApplication
   PRIVATE
      librdkafka::cpp
      Qt5::Core
      Qt5::Gui
      zookeeper::cpp
)
```

## Building ovsrpro

Developers should install an available package. If a package does not exist for
your system, use these instructions to build your own package.

### externpro

First, install [externpro](https://github.com/smanders/externpro). You must
install [version 18.8.4](https://github.com/smanders/externpro/releases/tag/18.08.4)
Use the same installation instructions as for ovsrpro, just substitute externpro
for ovsrpro.

### Building the Projects

1. Clone the repository.
1. In the repository, checkout the version you wish to build.
1. Create a build directory.
1. In the build directory, run CMake.
1. In the build directory, build the projects.
1. In the build directory, create an installation package.

```bash
cd ~/repositories/ovsrpro
git clone git://github.com/distributePro/ovsrpro.git
cd ovsrpro
git checkout 20.04.1
mkdir -p ~/repositories/ovsrpro/release
cd ../release
cmake -D XP_STEP=build ../ovsrpro
cmake --build .
cpack
```

Now, you can install your package, using the instructions above.

### CMake Options

For custom builds, the following CMake options are available:

<!-- markdownlint-disable MD013 -->
| Option | Default | Description |
|:---|:---|:---|
| `XP_BUILD_DEBUG` | `on` | Build debug versions of the projects. Note that release versions are always built. |
| `XP_DEFAULT` | `on` | Compiles all of the available packages. To only compile a subset of the packages, set `XP_DEFAULT=off` and specify the individual packages desired. This is easier to do using cmake-gui or ccmake. |
| `XP_STEP` | `patch` | Specify which steps to complete of the build process. See the [externpro documentation](https://github.com/smanders/externpro/blob/master/README.md) for available options. |
<!-- markdownlint-enable MD013 -->

The `XP_STEP` option must be set to a value from a set. Here are the possible values:

- `download_externpro` - This step downloads necessary files from externpro
  and modifies them for use by ovsrpro. The files are committed to the
  repository, so this is only needed when upgrading externpro or projects used
  in externpro.
  - This exposes an additional boolean option, `verbose`. If `verbose` is
    enabled, the download progress is displaed. `verbose` is off by default.
- `mkpatch` - This creates targets that will clone project repositories and
  checkout the necessary commit. This is useful to create modify the source
  code and use Git to create patch files.
- `download` - This step creates targets to download the project source archives.
- `patch` - This step implies `download`. It also unpacks the source archives
  and applies patch files located in [*patches/*](patches/).
- `build` - This step implies `download` and `patch`. In addition, it creates
  targets to actually build the projects.
