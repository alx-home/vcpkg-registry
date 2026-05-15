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
    REPO alx-home/build_tools
    REF 1.1.0
    SHA512 e794af2dc2f595667b396eebb4557cf6b367a6bc30fb7ac83c8dac80bdc8eb91b262333b61b25569b90aacb60bcde6f295daf375e284d064497e959474b18b93
)

file(INSTALL
    "${SOURCE_PATH}/cmake/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake"
    FILES_MATCHING PATTERN "*.cmake"
)

file(INSTALL
    "${SOURCE_PATH}/README.md"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
