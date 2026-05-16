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
    REPO alx-home/promise
    REF master
    SHA512 3d5bc07613ea6fa9c193b311fc62c7d2aeb8cce05e163838e2278007ee1bfd8bdca32de63c330f9873e5b7f022da2ef4760d0ebe3d232ac30d6ed1a5c3274f04
)

set(ALX_PROMISE_PROJECT_INCLUDE "${CURRENT_BUILDTREES_DIR}/alx-promise-project-include.cmake")
file(WRITE "${ALX_PROMISE_PROJECT_INCLUDE}" [=[
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

if(NOT TARGET alx-home::cpp_utils)
    set(_alx_cpp_utils_root "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
    file(GLOB _alx_cpp_utils_rel "${_alx_cpp_utils_root}/lib/*cpp_utils*.lib")
    file(GLOB _alx_cpp_utils_dbg "${_alx_cpp_utils_root}/debug/lib/*cpp_utils*.lib")

    if(NOT _alx_cpp_utils_rel AND NOT _alx_cpp_utils_dbg)
        message(FATAL_ERROR "Could not locate cpp_utils libraries under ${_alx_cpp_utils_root}")
    endif()

    add_library(alx_home_cpp_utils UNKNOWN IMPORTED)
    set_target_properties(alx_home_cpp_utils PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_alx_cpp_utils_root}/include"
    )

    if(_alx_cpp_utils_rel)
        list(GET _alx_cpp_utils_rel 0 _alx_cpp_utils_rel_first)
        set_property(TARGET alx_home_cpp_utils PROPERTY IMPORTED_LOCATION_RELEASE "${_alx_cpp_utils_rel_first}")
    endif()
    if(_alx_cpp_utils_dbg)
        list(GET _alx_cpp_utils_dbg 0 _alx_cpp_utils_dbg_first)
        set_property(TARGET alx_home_cpp_utils PROPERTY IMPORTED_LOCATION_DEBUG "${_alx_cpp_utils_dbg_first}")
    endif()
    if(NOT _alx_cpp_utils_rel AND _alx_cpp_utils_dbg)
        list(GET _alx_cpp_utils_dbg 0 _alx_cpp_utils_dbg_first)
        set_property(TARGET alx_home_cpp_utils PROPERTY IMPORTED_LOCATION "${_alx_cpp_utils_dbg_first}")
    endif()

    add_library(alx-home::cpp_utils ALIAS alx_home_cpp_utils)
endif()
]=])

set(VCPKG_LIBRARY_LINKAGE static)

# # Check if one or more features are a part of a package installation.
# # See /docs/maintainers/vcpkg_check_features.md for more details
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
# FEATURES
# tbb   WITH_TBB
# INVERTED_FEATURES
# tbb   ROCKSDB_IGNORE_PACKAGE_TBB
# )
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_PROJECT_INCLUDE=${ALX_PROMISE_PROJECT_INCLUDE}
        -DBUILD_SHARED_LIBS=OFF
        -DPROMISE_BUILD_TESTS=OFF
        -DPROMISE_FETCH_BUILD_TOOLS=OFF
        -DPROMISE_FETCH_CPP_UTILS=OFF
)

vcpkg_cmake_build()

file(INSTALL
    "${SOURCE_PATH}/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(GLOB REL_PROMISE_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
)
file(GLOB DBG_PROMISE_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
)
file(GLOB REL_PROMISE_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
)
file(GLOB DBG_PROMISE_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
)

if(NOT REL_PROMISE_LIBS)
    message(FATAL_ERROR "No release promise library was produced.")
endif()

if(NOT DBG_PROMISE_LIBS)
    message(FATAL_ERROR "No debug promise library was produced.")
endif()

file(INSTALL ${REL_PROMISE_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL ${DBG_PROMISE_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

if(REL_PROMISE_DLLS)
    file(INSTALL ${REL_PROMISE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

if(DBG_PROMISE_DLLS)
    file(INSTALL ${DBG_PROMISE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

set(ALX_PROMISE_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(MAKE_DIRECTORY "${ALX_PROMISE_CONFIG_DIR}")
file(WRITE "${ALX_PROMISE_CONFIG_DIR}/${PORT}-config.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(alx-cpp-utils CONFIG REQUIRED)

get_filename_component(_alx_promise_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

if(NOT TARGET alx-home::promise)
    add_library(alx-home::promise UNKNOWN IMPORTED)
    set_target_properties(alx-home::promise PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_alx_promise_prefix}/include"
        INTERFACE_LINK_LIBRARIES alx-home::cpp_utils
    )

    if(EXISTS "${_alx_promise_prefix}/lib/alx-home_promise.lib")
        set_property(TARGET alx-home::promise PROPERTY IMPORTED_LOCATION_RELEASE "${_alx_promise_prefix}/lib/alx-home_promise.lib")
        set_property(TARGET alx-home::promise PROPERTY IMPORTED_LOCATION "${_alx_promise_prefix}/lib/alx-home_promise.lib")
    endif()
    if(EXISTS "${_alx_promise_prefix}/debug/lib/alx-home_promise.lib")
        set_property(TARGET alx-home::promise PROPERTY IMPORTED_LOCATION_DEBUG "${_alx_promise_prefix}/debug/lib/alx-home_promise.lib")
    endif()
endif()
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
