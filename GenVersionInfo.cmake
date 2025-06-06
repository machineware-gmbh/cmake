 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

# Including this file will extract version information from the cmake project
# and (if present) surrounding git repository and import the following cmake
# variables into your scope, intended for use with configure_file:
#
#     <PROJECT_NAME>_VERSION_MAJOR
#     <PROJECT_NAME>_VERSION_MINOR
#     <PROJECT_NAME>_VERSION_PATCH
#     <PROJECT_NAME>_GIT_REV
#     <PROJECT_NAME>_GIT_REV_SHORT
#     <PROJECT_NAME>_VERSION
#     <PROJECT_NAME>_VERSION_INT
#     <PROJECT_NAME>_VERSION_STRING

find_package(Git REQUIRED)

string(TOUPPER ${PROJECT_NAME} _pfx)
string(REPLACE "-" "_" _pfx ${_pfx})

# newer versions of cmake retain the leading zero, remove it here, since we
# want to use it as an integer and leading zeros are interpreted as octal.
string(REGEX REPLACE "^0" "" PROJECT_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
string(REGEX REPLACE "^0" "" PROJECT_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

set(${_pfx}_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(${_pfx}_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(${_pfx}_VERSION_PATCH ${PROJECT_VERSION_PATCH})

# <name>_VERSION_MINOR and <name>_VERSION_PATCH should retain the leading zero,
# so add it back here,
if(${_pfx}_VERSION_MINOR LESS 10)
    set(${_pfx}_VERSION_MINOR 0${${_pfx}_VERSION_MINOR})
endif()

if(${_pfx}_VERSION_PATCH LESS 10)
    set(${_pfx}_VERSION_PATCH 0${${_pfx}_VERSION_PATCH})
endif()

execute_process(COMMAND ${GIT_EXECUTABLE} --git-dir=${CMAKE_CURRENT_SOURCE_DIR}/.git rev-parse HEAD
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE ${_pfx}_GIT_REV
                ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(COMMAND ${GIT_EXECUTABLE} --git-dir=${CMAKE_CURRENT_SOURCE_DIR}/.git rev-parse --short HEAD
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE ${_pfx}_GIT_REV_SHORT
                ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(COMMAND ${GIT_EXECUTABLE} --git-dir=${CMAKE_CURRENT_SOURCE_DIR}/.git diff --quiet
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                RESULT_VARIABLE ${_pfx}_GIT_DIRTY
                ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT ${_pfx}_GIT_REV)
    set(${_pfx}_GIT_REV "nogit")
    set(${_pfx}_GIT_REV_SHORT "nogit")
elseif (${_pfx}_GIT_DIRTY)
    string(APPEND ${_pfx}_GIT_REV "-dirty")
    string(APPEND ${_pfx}_GIT_REV_SHORT "-dirty")
endif()

string(CONCAT ${_pfx}_VERSION ${${_pfx}_VERSION_MAJOR} "."
                              ${${_pfx}_VERSION_MINOR} "."
                              ${${_pfx}_VERSION_PATCH})

string(CONCAT ${_pfx}_VERSION_INT ${${_pfx}_VERSION_MAJOR}
                                  ${${_pfx}_VERSION_MINOR}
                                  ${${_pfx}_VERSION_PATCH})

string(CONCAT ${_pfx}_VERSION_STRING ${PROJECT_NAME} "-"
                                     ${${_pfx}_VERSION} "-"
                                     ${${_pfx}_GIT_REV_SHORT})

message(DEBUG "${_pfx}_VERSION_MAJOR  = ${${_pfx}_VERSION_MAJOR}")
message(DEBUG "${_pfx}_VERSION_MINOR  = ${${_pfx}_VERSION_MINOR}")
message(DEBUG "${_pfx}_VERSION_PATCH  = ${${_pfx}_VERSION_PATCH}")
message(DEBUG "${_pfx}_GIT_REV        = ${${_pfx}_GIT_REV}")
message(DEBUG "${_pfx}_GIT_REV_SHORT  = ${${_pfx}_GIT_REV_SHORT}")
message(DEBUG "${_pfx}_VERSION        = ${${_pfx}_VERSION}")
message(DEBUG "${_pfx}_VERSION_INT    = ${${_pfx}_VERSION_INT}")
message(DEBUG "${_pfx}_VERSION_STRING = ${${_pfx}_VERSION_STRING}")

message(STATUS "Writing version ${${_pfx}_VERSION_STRING}")
