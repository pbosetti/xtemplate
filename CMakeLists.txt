cmake_minimum_required(VERSION 3.10)

# GIT versioning - It requires at leas one git tag e.g. 0.0.1
execute_process(
  COMMAND git describe --long --dirty=§
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND git describe --abbrev=0 --tags
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_VERSION_TAG
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
project(X-Template VERSION ${GIT_VERSION_TAG} LANGUAGES C)
    
# Override build type (Debug or Release)
# set(CMAKE_BUILD_TYPE Debug)
# set(CMAKE_BUILD_TYPE Release)
message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")

# Find out target platform
execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine OUTPUT_VARIABLE TARGET_PLATFORM) #put into TARGET_PLATFORM result of $ gcc -dumpmachine
string(REPLACE "\n" "" TARGET_PLATFORM ${TARGET_PLATFORM})
string(REGEX MATCH mipsel-openwrt-linux-musl IS_MIPSEL ${TARGET_PLATFORM})
string(REGEX MATCH armv7-unknown-linux-gnueabi IS_ARM7 ${TARGET_PLATFORM})
string(REGEX MATCH arm-cortexa8_neon-linux-gnueabihf IS_ARM7A ${TARGET_PLATFORM})
string(REGEX MATCH aarch64-unknown-linux-gnueabi IS_ARM64 ${TARGET_PLATFORM})
if (IS_ARM7 OR IS_ARM7A OR IS_ARM64)
  set(IS_ARM TRUE)
endif()

# SETUP PATHS AND VARIABLES
if(IS_MIPSEL)
  message(STATUS "Cross-building for MIPSEL (cross_root: ${cross_root})")
  set(LUA_LIB lua)
  add_definitions(-D_OPENWRT_LINUX=1)
  include_directories(${ONION_DIR}/usr/include)
  link_directories(${ONION_DIR}/usr/lib)
elseif(IS_ARM)
  message(STATUS "Cross-building for ARM (cross_root: ${cross_root})")
  set(LINUX TRUE)
  set(LUA_LIB lua)
  include_directories(${cross_root}/include)
  link_directories(${cross_root}/lib)
  add_definitions(-D__ARM7__)
elseif(UNIX AND NOT APPLE)
  message(STATUS "Building on Linux")
  set(LINUX TRUE)
  set(NATIVE TRUE)
  set(LUA_LIB lua5.3)
  include_directories(/usr/include/${LUA_LIB} /usr/local/include)
  link_directories(/usr/lib/x86_64-linux-gnu)
elseif(APPLE)
  message(STATUS "Building on Apple OS X")
  set(LUA_LIB lua)
  set(NATIVE TRUE)
  include_directories(/usr/local/include /usr/local/include/lua)
  link_directories(/usr/local/lib)
endif()

# FILES
# expect all sources in /src, except mains
set(SOURCE_DIR ${CMAKE_HOME_DIRECTORY}/src)
file(GLOB LIB_SOURCES "${SOURCE_DIR}/*.c")
# generate defines.h, which also contains version numbers matching git tags
configure_file(
  ${SOURCE_DIR}/defines.h.in
  ${SOURCE_DIR}/defines.h
)

# COMPILE OPTIONS
add_compile_options(-std=gnu11 -fPIC -D_GNU_SOURCE)
if(CMAKE_BUILD_TYPE MATCHES "Debug")
  message(STATUS "Debug mode, enabling all warnings")
  add_compile_options(-Wall -Wno-comment)
endif()

# TARGETS
add_library(xtemplate_static STATIC ${LIB_SOURCES})
add_library(xtemplate_shared SHARED ${LIB_SOURCES})
add_executable(test ${SOURCE_DIR}/main/test.c)


list(APPEND TARGETS_LIST
  test
)
if(IS_ARM)
  list(APPEND TARGETS_LIST xtemplate_shared)
  target_link_libraries(test xtemplate_shared)
elseif(IS_OPENWRT)
  list(APPEND TARGETS_LIST xtemplate_static)
  target_link_libraries(test xtemplate_static)
else()
  list(APPEND TARGETS_LIST xtemplate_static)
  target_link_libraries(test xtemplate_static)
endif()

# INSTALL
if(IS_MIPSEL OR IS_ARM)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_HOME_DIRECTORY}/products)
else()
  set(CMAKE_INSTALL_PREFIX ${CMAKE_HOME_DIRECTORY}/products_host)
endif()
install(TARGETS ${TARGETS_LIST}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib/static
)
if(CMAKE_BUILD_TYPE MATCHES "Debug")
  install(DIRECTORY include/
    DESTINATION include/vodisys_algo
    FILES_MATCHING PATTERN "*.h"
  )
endif()

# PACKAGING
set(CPACK_GENERATOR "STGZ")
set(CPACK_PACKAGE_VERSION ${GIT_COMMIT_HASH})
set(CPACK_PACKAGE_NAME xtemplate-${CMAKE_BUILD_TYPE})
include(CPack)

# if not cross-compiling, create Dockerfile for the target platform
if(NATIVE)
  option(ENABLE_MRUBY "Enable build of mruby in container" OFF)
  if(NOT ENABLE_MRUBY)
    message(WARNING "mruby is NOT compiled in the container")
    set(COMMENT_ENABLE_MRUBY "#")
  endif()
  option(ENABLE_OPENBLAS "Enable build of OpenBLAS in container" OFF)
  if(NOT ENABLE_OPENBLAS)
    message(WARNING "OpenBLAS is NOT compiled in the container")
    set(COMMENT_ENABLE_OPENBLAS "#")
  endif()
  option(KEEP_BUILD_DIR "Do not delete build dir in Docker container" OFF)
  if(KEEP_BUILD_DIR)
    message(WARNING "Build dir is NOT deleted after compilation")
    set(COMMENT_BUILD_DIR "#")
  endif()
  set(TARGET_NAME CACHE STRING "Select TARGET platform")
  if(NOT TARGET_NAME)
    set(TARGET_NAME "armv7")
  endif()
  set_property(CACHE TARGET_NAME PROPERTY STRINGS mipsel armv6 armv7 armv7a arm64)
  configure_file(
    ${CMAKE_HOME_DIRECTORY}/Dockerfile.in
    ${CMAKE_HOME_DIRECTORY}/Dockerfile
    @ONLY
  )
  message(STATUS "Host Dockerfile generated for target ${TARGET_NAME}")
  message(STATUS "Building of mruby (libmruby.a) is: ${ENABLE_MRUBY}")
  message(STATUS "Keep the build root directory: ${KEEP_BUILD_DIR}")
  message(STATUS "Build with: docker build -t ${TARGET_NAME} .")
  message(STATUS "then:       docker run --rm ${TARGET_NAME} > ${TARGET_NAME} && chmod a+x ${TARGET_NAME}")
endif()
