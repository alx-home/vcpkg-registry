# Common Ambient Variables:
# CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
# CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
# CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
# CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
# DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
# PORT                      = current port name (zlib, etc)
# TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
# VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
# VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
# VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
# VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
# VCPKG_TOOLCHAIN           = ON OFF
# TRIPLET_SYSTEM_ARCH       = arm x86 x64
# BUILD_ARCH                = "Win32" "x64" "ARM"
# DEBUG_CONFIG              = "Debug Static" "Debug Dll"
# RELEASE_CONFIG            = "Release Static"" "Release DLL"
# VCPKG_TARGET_IS_WINDOWS
# VCPKG_TARGET_IS_UWP
# VCPKG_TARGET_IS_LINUX
# VCPKG_TARGET_IS_OSX
# VCPKG_TARGET_IS_FREEBSD
# VCPKG_TARGET_IS_ANDROID
# VCPKG_TARGET_IS_MINGW
# VCPKG_TARGET_EXECUTABLE_SUFFIX
# VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
# VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md

# Also consider vcpkg_from_* functions if you can; the generated code here is for any web accessible
# source archive.
# vcpkg_from_github
# vcpkg_from_gitlab
# vcpkg_from_bitbucket
# vcpkg_from_sourceforge

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alx-home/cpp_utils
    REF master
    SHA512 ee7d6a33d438295454c5c6fbaf5fc66d67b75b9faa53b077dd0cba89bc45cc4724bfca300da42fe53b7535af24530e4f9975b5fd42ff7592ba5906e45115122c
)

set(ALX_CPP_UTILS_PROJECT_INCLUDE "${CURRENT_BUILDTREES_DIR}/alx-cpp-utils-project-include.cmake")
file(WRITE "${ALX_CPP_UTILS_PROJECT_INCLUDE}" [=[
set(_alx_bt_candidates
    "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/alx-build-tools/cmake"
    "${_VCPKG_INSTALLED_DIR}/${VCPKG_HOST_TRIPLET}/share/alx-build-tools/cmake"
)

set(_alx_bt_found OFF)
foreach(_alx_bt_dir IN LISTS _alx_bt_candidates)
    if(EXISTS "${_alx_bt_dir}/win32_library.cmake")
        include("${_alx_bt_dir}/win32_library.cmake")
        include("${_alx_bt_dir}/win32_executable.cmake")
        set(_alx_bt_found ON)
        break()
    endif()
endforeach()

if(NOT _alx_bt_found)
    message(FATAL_ERROR "Missing alx-build-tools CMake helpers. Tried: ${_alx_bt_candidates}")
endif()
]=])

set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_PROJECT_INCLUDE=${ALX_CPP_UTILS_PROJECT_INCLUDE}
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_build()

file(INSTALL
    "${SOURCE_PATH}/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/uuid/uuid.h")
    file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/uuid/uuid.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/uuid"
    )
endif()

file(GLOB REL_CPP_UTILS_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
)
file(GLOB DBG_CPP_UTILS_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
)
file(GLOB REL_CPP_UTILS_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
)
file(GLOB DBG_CPP_UTILS_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
)

if(NOT REL_CPP_UTILS_LIBS)
    message(FATAL_ERROR "No release cpp_utils library was produced.")
endif()

if(NOT DBG_CPP_UTILS_LIBS)
    message(FATAL_ERROR "No debug cpp_utils library was produced.")
endif()

file(INSTALL ${REL_CPP_UTILS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL ${DBG_CPP_UTILS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

if(REL_CPP_UTILS_DLLS)
    file(INSTALL ${REL_CPP_UTILS_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

if(DBG_CPP_UTILS_DLLS)
    file(INSTALL ${DBG_CPP_UTILS_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

set(ALX_CPP_UTILS_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(MAKE_DIRECTORY "${ALX_CPP_UTILS_CONFIG_DIR}")
file(WRITE "${ALX_CPP_UTILS_CONFIG_DIR}/${PORT}-config.cmake" [=[
get_filename_component(_alx_cpp_utils_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

if(NOT TARGET alx-home::cpp_utils)
    add_library(alx-home::cpp_utils UNKNOWN IMPORTED)
    set_target_properties(alx-home::cpp_utils PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_alx_cpp_utils_prefix}/include"
    )

    if(EXISTS "${_alx_cpp_utils_prefix}/lib/alx-home_cpp_utils.lib")
        set_property(TARGET alx-home::cpp_utils PROPERTY IMPORTED_LOCATION_RELEASE "${_alx_cpp_utils_prefix}/lib/alx-home_cpp_utils.lib")
    endif()
    if(EXISTS "${_alx_cpp_utils_prefix}/debug/lib/alx-home_cpp_utils.lib")
        set_property(TARGET alx-home::cpp_utils PROPERTY IMPORTED_LOCATION_DEBUG "${_alx_cpp_utils_prefix}/debug/lib/alx-home_cpp_utils.lib")
    endif()
    if(EXISTS "${_alx_cpp_utils_prefix}/lib/alx-home_cpp_utils.lib")
        set_property(TARGET alx-home::cpp_utils PROPERTY IMPORTED_LOCATION "${_alx_cpp_utils_prefix}/lib/alx-home_cpp_utils.lib")
    endif()

    if(WIN32)
        set_property(TARGET alx-home::cpp_utils APPEND PROPERTY INTERFACE_LINK_LIBRARIES crypt32)
    endif()
endif()
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
