# Ovsrpro Reference Manual

⚠️ These instructions do not apply to version 19.01.1 or earlier.

⚠️ The only supported method of using ovsrpro is in a
[CMake](https://cmake.org) based project.

⚠️ The examples may not match your exact version, compiler, or architecture.
If yours is different, substitute yours in the examples.

## Installing Ovsrpro

First, download the package for the
[release](https://github.com/distributePro/ovsrpro/releases) that you need.

Install the package using the normal means for your package. If you can
choose the installation prefix, the recommended value is */opt/ovsrpro/*.

After you install ovsrpro, copy
*install_location/share/cmake/Findovsrpro.cmake* to your CMake based project.

### Self Extracting Shell Script Example

```bash
./ovsrpro-20.05.1-gcc921-64-Linux.sh \
  --prefix=/opt/ovsrpro \
  --include-subdir
```

This will install ovsrpro to */opt/ovsrpro/ovsrpro-20.05.1-gcc921-64-Linux/*.

## Finding Ovsrpro in Your Project

All you need to do is tell CMake where to search for *Findovsrpro.cmake*, and
then use CMake's
[`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html)
command.

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
find_package(ovsrpro 20.05.1 MODULE REQUIRED)
```
