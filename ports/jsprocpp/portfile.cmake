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
    REPO alx-home/JSProCpp
    REF master
    SHA512 218e4a7b374d2cacca50496fe134a084b72ba063679f0b90bade25e16b405999644a456372fafecf2ef768bc96b7ac33c3d48be73c6adc975d56200943e71ec8
)

set(JS_PRO_CPP_PROJECT_INCLUDE "${CURRENT_BUILDTREES_DIR}/JSProCpp-project-include.cmake")
file(WRITE "${JS_PRO_CPP_PROJECT_INCLUDE}" [=[
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
        -DCMAKE_PROJECT_INCLUDE=${JSPROCPP_PROJECT_INCLUDE}
        -DBUILD_SHARED_LIBS=OFF
        -DJSPROCPP_BUILD_TESTS=OFF
        -DJSPROCPP_FETCH_BUILD_TOOLS=OFF
        -DJSPROCPP_FETCH_CPP_UTILS=OFF
)

vcpkg_cmake_build()

file(INSTALL
    "${SOURCE_PATH}/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(GLOB REL_JSPROCPP_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
)
file(GLOB DBG_JSPROCPP_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
)
file(GLOB REL_JSPROCPP_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
)
file(GLOB DBG_JSPROCPP_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
)

if(NOT REL_JSPROCPP_LIBS)
    message(FATAL_ERROR "No release JSProCpp library was produced.")
endif()

if(NOT DBG_JSPROCPP_LIBS)
    message(FATAL_ERROR "No debug JSProCpp library was produced.")
endif()

file(INSTALL ${REL_JSPROCPP_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL ${DBG_JSPROCPP_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

if(REL_JSPROCPP_DLLS)
    file(INSTALL ${REL_JSPROCPP_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

if(DBG_JSPROCPP_DLLS)
    file(INSTALL ${DBG_JSPROCPP_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

set(JSPROCPP_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(MAKE_DIRECTORY "${JSPROCPP_CONFIG_DIR}")
file(WRITE "${JSPROCPP_CONFIG_DIR}/${PORT}-config.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(alx-cpp-utils CONFIG REQUIRED)

get_filename_component(_jsprocpp_prefix "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

if(NOT TARGET alx-home::JSProCpp)
    add_library(alx-home::JSProCpp UNKNOWN IMPORTED)
    set_target_properties(alx-home::JSProCpp PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_jsprocpp_prefix}/include"
        INTERFACE_LINK_LIBRARIES alx-home::cpp_utils
    )

    if(EXISTS "${_jsprocpp_prefix}/lib/JSProCpp.lib")
        set_property(TARGET alx-home::JSProCpp PROPERTY IMPORTED_LOCATION_RELEASE "${_jsprocpp_prefix}/lib/JSProCpp.lib")
        set_property(TARGET alx-home::JSProCpp PROPERTY IMPORTED_LOCATION "${_jsprocpp_prefix}/lib/JSProCpp.lib")
    endif()
    if(EXISTS "${_jsprocpp_prefix}/debug/lib/JSProCpp.lib")
        set_property(TARGET alx-home::JSProCpp PROPERTY IMPORTED_LOCATION_DEBUG "${_jsprocpp_prefix}/debug/lib/JSProCpp.lib")
    endif()
endif()
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
