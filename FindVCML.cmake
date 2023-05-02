 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

if(NOT TARGET vcml)
    if(NOT EXISTS ${VCML_HOME})
        set(VCML_HOME $ENV{VCML_HOME})
    endif()

    if(NOT EXISTS ${VCML_HOME}/CMakeLists.txt)
        find_package(Git REQUIRED)
        set(VCML_HOME "${CMAKE_CURRENT_BINARY_DIR}/vcml")
        set(VCML_REPO "https://github.com/machineware-gmbh/vcml.git")
        set(VCML_TAG  "main")
        message(STATUS "Fetching VCML from ${VCML_REPO}")
        execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 --branch ${VCML_TAG} ${VCML_REPO} ${VCML_HOME}
                        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                        ERROR_QUIET)
    endif()

    if(EXISTS "${VCML_HOME}/CMakeLists.txt")
        add_subdirectory(${VCML_HOME} vcml EXCLUDE_FROM_ALL)
    endif()
endif()

if(NOT TARGET vcml)
    message(FATAL_ERROR "Cannot find VCML")
endif()

get_target_property(VCML_HOME vcml SOURCE_DIR)
get_target_property(VCML_INCLUDE_DIRS vcml INCLUDE_DIRECTORIES)
get_target_property(VCML_VERSION vcml VERSION)
set(VCML_LIBRARIES vcml)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(VCML
    REQUIRED_VARS VCML_LIBRARIES VCML_INCLUDE_DIRS
    VERSION_VAR   VCML_VERSION)
mark_as_advanced(VCML_LIBRARIES VCML_INCLUDE_DIRS)

message(DEBUG "VCML_FOUND         " ${VCML_FOUND})
message(DEBUG "VCML_HOME          " ${VCML_HOME})
message(DEBUG "VCML_INCLUDE_DIRS  " ${VCML_INCLUDE_DIRS})
message(DEBUG "VCML_LIBRARIES     " ${VCML_LIBRARIES})
message(DEBUG "VCML_VERSION       " ${VCML_VERSION})
