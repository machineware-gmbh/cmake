 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

if(NOT DEFINED SYSTEMC_TARGET_ARCH)
    if(DEFINED ENV{TARGET_ARCH})
        set(SYSTEMC_TARGET_ARCH $ENV{TARGET_ARCH})
    elseif(DEFINED TARGET_ARCH)
        set(SYSTEMC_TARGET_ARCH ${TARGET_ARCH})
    elseif(UNIX AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
        if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
            set(SYSTEMC_TARGET_ARCH "linux")
        elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
            set(SYSTEMC_TARGET_ARCH "linux64")
        elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
            set(SYSTEMC_TARGET_ARCH "linuxaarch64")
        endif()
    elseif(MSVC)
        set(SYSTEMC_TARGET_ARCH "msvc64")
    elseif(APPLE)
        if (CMAKE_SYSTEM_PROCESSOR MATCHES aarch64|arm64)
            set(SYSTEMC_TARGET_ARCH "macosxarm64")
        elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
            set(SYSTEMC_TARGET_ARCH "macosx64")
        endif()
    endif()
endif()

if(NOT DEFINED SYSTEMC_TARGET_ARCH)
    message(FATAL_ERROR "Cannot determine SystemC TARGET_ARCH")
endif()

if(NOT TARGET systemc)
    if(NOT DEFINED SYSTEMC_HOME AND DEFINED ENV{SYSTEMC_HOME})
        set(SYSTEMC_HOME $ENV{SYSTEMC_HOME})
    endif()

    if(NOT DEFINED SYSTEMC_HOME)
        find_package(Git REQUIRED)
        set(SYSTEMC_HOME "${CMAKE_CURRENT_BINARY_DIR}/systemc-src")
        set(SYSTEMC_REPO "https://github.com/machineware-gmbh/systemc")
        set(SYSTEMC_TAG  "2.3.3-mwr")
        message(STATUS "Fetching SystemC from ${SYSTEMC_REPO}")
        execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 --branch ${SYSTEMC_TAG} ${SYSTEMC_REPO} ${SYSTEMC_HOME}
                        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                        ERROR_QUIET)
    endif()

    if(EXISTS "${SYSTEMC_HOME}/CMakeLists.txt")
        set(ENABLE_PHASE_CALLBACKS ON CACHE STRING
            "Enable the simulation phase callbacks" FORCE)
        set(ENABLE_PHASE_CALLBACKS_TRACING ON CACHE STRING
            "Enable using simulation phase callbacks for sc_trace" FORCE)
        add_subdirectory(${SYSTEMC_HOME} systemc EXCLUDE_FROM_ALL)
    endif()
endif()

if(TARGET systemc)
    set(SYSTEMC_LIBRARIES systemc)
    get_target_property(SYSTEMC_INCLUDE_DIRS systemc INCLUDE_DIRECTORIES)
    get_target_property(SYSTEMC_HOME systemc SOURCE_DIR)
    get_filename_component(SYSTEMC_HOME "${SYSTEMC_HOME}" DIRECTORY)
else()
    find_path(SYSTEMC_INCLUDE_DIRS NAMES systemc
              HINTS ${SYSTEMC_HOME}/include)

    find_library(SYSTEMC_LIBRARIES NAMES libsystemc.a systemc
                 HINTS "${SYSTEMC_HOME}/lib-${SYSTEMC_TARGET_ARCH}"
                       "${SYSTEMC_HOME}/lib")

    if(EXISTS ${SYSTEMC_INCLUDE_DIRS}/tlm/)
        list(APPEND SYSTEMC_INCLUDE_DIRS ${SYSTEMC_INCLUDE_DIRS}/tlm)
    endif()
endif()

set(SYSTEMC_VERSION "")
file(GLOB_RECURSE _sysc_ver_file ${SYSTEMC_HOME}/*/sysc/kernel/sc_ver.h)
if(NOT EXISTS ${_sysc_ver_file})
    message(FATAL_ERROR "Cannot find sc_ver.h")
endif()

file(STRINGS ${_sysc_ver_file} _systemc_ver REGEX
     "^#[\t ]*define[\t ]+SC_VERSION_(MAJOR|MINOR|PATCH)[\t ]+([0-9]+)$")
foreach(VPART MAJOR MINOR PATCH)
    foreach(VLINE ${_systemc_ver})
        if(VLINE MATCHES 
           "^#[\t ]*define[\t ]+SC_VERSION_${VPART}[\t ]+([0-9]+)$")
            set(SYSTEMC_VERSION_${VPART} ${CMAKE_MATCH_1})
            if(SYSTEMC_VERSION)
                string(APPEND SYSTEMC_VERSION .${CMAKE_MATCH_1})
            else()
                set(SYSTEMC_VERSION ${CMAKE_MATCH_1})
            endif()
        endif()
    endforeach()
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SystemC
    REQUIRED_VARS SYSTEMC_LIBRARIES SYSTEMC_INCLUDE_DIRS
    VERSION_VAR   SYSTEMC_VERSION)
mark_as_advanced(SYSTEMC_LIBRARIES SYSTEMC_INCLUDE_DIRS)

set(SYSTEMC_TARGET_ARCH ${SYSTEMC_TARGET_ARCH} CACHE STRING "SystemC target architecture")
set(SYSTEMC_HOME ${SYSTEMC_HOME} CACHE STRING "SystemC home directory")
set(SYSTEMC_VERSION ${SYSTEMC_VERSION} CACHE STRING "SystemC version")

message(DEBUG "SYSTEMC_FOUND         " ${SYSTEMC_FOUND})
message(DEBUG "SYSTEMC_HOME          " ${SYSTEMC_HOME})
message(DEBUG "SYSTEMC_TARGET_ARCH   " ${SYSTEMC_TARGET_ARCH})
message(DEBUG "SYSTEMC_INCLUDE_DIRS  " ${SYSTEMC_INCLUDE_DIRS})
message(DEBUG "SYSTEMC_LIBRARIES     " ${SYSTEMC_LIBRARIES})
message(DEBUG "SYSTEMC_VERSION_MAJOR " ${SYSTEMC_VERSION_MAJOR})
message(DEBUG "SYSTEMC_VERSION_MINOR " ${SYSTEMC_VERSION_MINOR})
message(DEBUG "SYSTEMC_VERSION_PATCH " ${SYSTEMC_VERSION_PATCH})
message(DEBUG "SYSTEMC_VERSION       " ${SYSTEMC_VERSION})
