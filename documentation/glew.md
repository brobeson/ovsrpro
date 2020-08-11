# Using GLEW

## Finding GLEW

In your CMake-based project, use
[`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode)
in config mode. You need to specify the search path; see the `find_package()`
[search
procedure](https://cmake.org/cmake/help/v3.13/command/find_package.html#search-procedure)
documentation for details.

Here is an example:

```cmake
find_package(glew 1.13.0 CONFIG HINTS "${ovsrpro_LIBRARY_DIR}")
```

## Imported Targets

The GLEW config module imports the following targets.

* `GLEW::glew_s` - This is the basic single-context GLEW static library.
* `GLEW::glewmx_s` - This is the multi-context GLEW static library.

Use
[`target_link_libraries()`](https://cmake.org/cmake/help/latest/command/target_link_libraries.html)
as you normally would.

```cmake
target_link_libraries(application PRIVATE GLEW::glew_s)
```

## Including GLEW Headers

The GLEW targets set the header search path appropriately. Just include the
file `GL/glew.h`.

## Full Example

### CMakeLists.txt

```cmake
project(gl-application)
find_package(ovsrpro REQUIRED)
find_package(glew 1.13.0 CONFIG REQUIRED HINTS "${ovsrpro_LIBRARY_DIR}")
add_executable(gl-application main.cpp)
target_link_libraries(gl-application PRIVATE GLEW::glew_s)
```

### main.cpp

```c++
#include <GL/glew.h>
// Include other headers.

int main(int argc, char* argv[])
{
  // Do some OpenGL stuff.
  return EXIT_SUCCESS;
}
```
