include (ExternalProject)

set(NSYNC_URL https://github.com/google/nsync)
set(NSYNC_TAG 1.20.0)

if(WIN32)
  set(NSYNC_SHARED_LIB libnsync_cpp.dll)
  set(NSYNC_IMPORT_LIB mkldnn.lib)
else()
  if (APPLE)
    set(NSYNC_SHARED_LIB libnsync.0.dylib)
  else()
    set(NSYNC_SHARED_LIB libnsync.so.0)
  endif()
endif()


set(NSYNC_SOURCE ${CMAKE_CURRENT_BINARY_DIR}/nsync/src)
set(NSYNC_INSTALL ${CMAKE_CURRENT_BINARY_DIR}/nsync/install)
set(NSYNC_LIB_DIR ${NSYNC_INSTALL}/lib)
set(NSYNC_INCLUDE_DIR ${NSYNC_INSTALL}/include)

ExternalProject_Add(nsync
  PREFIX nsync
  GIT_TAG ${NSYNC_TAG}
  GIT_REPOSITORY ${NSYNC_URL}
  BUILD_IN_SOURCE 1
  BUILD_BYPRODUCTS ${NSYNC_SHARED_LIB}
  INSTALL_DIR ${NSYNC_INSTALL}
  CMAKE_CACHE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:STRING=${NSYNC_INSTALL}
        -DCMAKE_INSTALL_LIBDIR:STRING=lib
        -DNSYNC_ENABLE_TESTS=0
        -DNSYNC_LANGUAGE:STRING=c++11
)