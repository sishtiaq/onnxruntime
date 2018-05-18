find_package(PythonInterp REQUIRED)
include(pybind11)

FIND_PACKAGE(PythonLibs)
FIND_PACKAGE(NumPy)

if(NOT PYTHON_INCLUDE_DIR)
  set(PYTHON_NOT_FOUND false)
  exec_program("${PYTHON_EXECUTABLE}"
    ARGS "-c \"import distutils.sysconfig; print(distutils.sysconfig.get_python_inc())\""
    OUTPUT_VARIABLE PYTHON_INCLUDE_DIR
    RETURN_VALUE PYTHON_NOT_FOUND)
  if(${PYTHON_NOT_FOUND})
    message(FATAL_ERROR
            "Cannot get Python include directory. Is distutils installed?")
  endif(${PYTHON_NOT_FOUND})
endif(NOT PYTHON_INCLUDE_DIR)

# 2. Resolve the installed version of NumPy (for numpy/arrayobject.h).
if(NOT NUMPY_INCLUDE_DIR)
  set(NUMPY_NOT_FOUND false)
  exec_program("${PYTHON_EXECUTABLE}"
    ARGS "-c \"import numpy; print(numpy.get_include())\""
    OUTPUT_VARIABLE NUMPY_INCLUDE_DIR
    RETURN_VALUE NUMPY_NOT_FOUND)
  if(${NUMPY_NOT_FOUND})
    message(FATAL_ERROR
            "Cannot get NumPy include directory: Is NumPy installed?")
  endif(${NUMPY_NOT_FOUND})
endif(NOT NUMPY_INCLUDE_DIR)

# ---[ Python + Numpy
include_directories(${PYTHON_INCLUDE_DIR} ${NUMPY_INCLUDE_DIR})
include_directories(${pybind11_INCLUDE_DIRS})

set(lotus_pybind_srcs
    ${LOTUS_ROOT}/python/lotus_pybind_state.cc
)

add_whole_archive_flag(lotus_providers lotus_providers_whole_archive)
add_whole_archive_flag(lotus_framework lotus_framework_whole_archive)
add_whole_archive_flag(onnx onnx_whole_archive)
add_library(lotus_pybind11_state MODULE ${lotus_pybind_srcs})
add_dependencies(lotus_pybind11_state lotus_framework lotus_providers pybind11)
target_link_libraries(lotus_pybind11_state ${lotus_providers_whole_archive} ${lotus_framework_whole_archive} lotusIR_graph ${onnx_whole_archive} lotus_common ${lotus_EXTERNAL_LIBRARIES} ${PYTHON_LIBRARY})

set_target_properties(lotus_pybind11_state PROPERTIES PREFIX "")
set_target_properties(lotus_pybind11_state PROPERTIES FOLDER "Lotus")

if (MSVC)
  set_target_properties(lotus_pybind11_state PROPERTIES SUFFIX ".pyd")
else()
  set_target_properties(lotus_pybind11_state PROPERTIES SUFFIX ".so")
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set_target_properties(lotus_pybind11_state PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
  endif()
endif()

file(GLOB_RECURSE lotus_python_srcs
    "${LOTUS_ROOT}/python/*.py"
)
file(GLOB_RECURSE lotus_python_test_srcs
    "${LOTUS_ROOT}/test/python/*.py"
)

add_custom_command(
  TARGET lotus_pybind11_state POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:lotus_test_ir>/lotus/python
  COMMAND ${CMAKE_COMMAND} -E copy
      ${LOTUS_ROOT}/__init__.py
      $<TARGET_FILE_DIR:lotus_test_ir>/lotus/
  COMMAND ${CMAKE_COMMAND} -E copy
      ${lotus_python_test_srcs}
      $<TARGET_FILE_DIR:lotus_test_ir>
  COMMAND ${CMAKE_COMMAND} -E copy
      ${lotus_python_srcs}
      $<TARGET_FILE_DIR:lotus_test_ir>/lotus/python/
  COMMAND ${CMAKE_COMMAND} -E copy
      $<TARGET_FILE:lotus_pybind11_state>
      $<TARGET_FILE_DIR:lotus_test_ir>/lotus/python/ )
