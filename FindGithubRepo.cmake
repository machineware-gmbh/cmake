 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

function(clone_github_repo target repo)
    string(TOUPPER ${target} _pfx)
    string(REPLACE "-" "_" _pfx ${_pfx})

    find_package(Git REQUIRED)
    set(ENV{GIT_TERMINAL_PROMPT} 0) # supress interactive git login prompts
    set(cmd clone --depth 1 --recursive)

    if(${_pfx}_TAG)
        set(cmd ${cmd} --branch ${${_pfx}_TAG})
        message(STATUS "Fetching ${target} from ${${_pfx}_REPO} [${${_pfx}_TAG}]")
    else()
        message(STATUS "Fetching ${target} from ${${_pfx}_REPO} [default branch]")
    endif()

    set(url "https://github.com/${${_pfx}_REPO}")
    execute_process(COMMAND ${GIT_EXECUTABLE} ${cmd} ${url} ${${_pfx}_HOME}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                    ERROR_VARIABLE err RESULT_VARIABLE res OUTPUT_QUIET)
    if(NOT res)
        return()
    endif()

    if(DEFINED ENV{GITHUB_TOKEN})
        set(url "https://oauth2:$ENV{GITHUB_TOKEN}@github.com/${${_pfx}_REPO}")
    else()
        set(url "git@github.com:${${_pfx}_REPO}")
    endif()

    execute_process(COMMAND ${GIT_EXECUTABLE} ${cmd} ${url} ${${_pfx}_HOME}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                    ERROR_VARIABLE err RESULT_VARIABLE res OUTPUT_QUIET)
    if(res)
        message(FATAL_ERROR "${err}")
    endif()
endfunction()

# find_github_repo:
# This macro will try to import the requested target as a dependency. If
# necessary, it will clone the repository from github using the provided URL.
# An optional 3rd argument can be used to specify the branch or tag to clone.
# If no branch/tag has been specified, the default tag (usually main) will
# be cloned. Before cloning, the TARGET_HOME environment variable will be
# checked for a local copy. This is the entire procedure
#
#   1. If $TARGET_HOME exists import the target from there
#   2.1. Otherwise, clone the repo using the provided URL/branch
#   2.2. the local copy will be stored in the current build directory
#   2.3. $TARGET_HOME will set to the cloned repository
#   3. Add $TARGET_HOME as a cmake subdirectory
#   4. Check if the target really was defined, otherwise report an error
#
# Cloning private repositories: if you do not have a local copy in $TARGET_HOME
# we will attempt to clone the repository from github using your SSH key. If
# you cannot use ssh (for whatever reason) you can set the environment variable
# GITHUB_TOKEN to your github token string. If GITHUB_TOKEN is set, ssh will
# not be used.
#
# Variables created by find_github_repo
#   - TARGET_FOUND: true of target was found, otherwise false
#   - TARGET_HOME: if not set, will be set to a local source folder
#   - TARGET_REPO: base url relative to github.com
#   - TARGET_TAG: tag/branch to clone (empty for default branch)
#   - TARGET_INCLUDE_DIRS: include directories of target
#   - TARGET_VERSION: version of the target (or 0.0.0 if nothing was found)
#
# Examples:
#   clone_github_repo(mwr "machineware-gmbh/mwr"): clones the default branch of
#       github.com:machineware-gmbh/mwr.git, unless MWR_HOME is set to a valid
#       local directory holding a CMakeLists.txt that defines mwr.
#
#   clone_github_repo(mwr "machineware-gmbh/mwr" "v2023.01.11"): clones the
#       v2023.01.11 tag of github.com:machineware-gmbh/mwr.git, unless MWR_HOME
#       is set to a valid local directory holding a CMakeLists.txt.
#
#   cmake -DMWR_TAG=my_dev_branch: overrides the tag used for fetching mwr on
#       the command line when runinng cmake the first time.
macro(find_github_repo target repo)
    string(TOUPPER ${target} _pfx)
    string(REPLACE "-" "_" _pfx ${_pfx})

    set(${_pfx}_REPO "${repo}" CACHE STRING "${target} repository url")
    set(${_pfx}_TAG "${ARGV2}" CACHE STRING "${target} repository tag/branch")

    if(NOT TARGET ${target})
        if(NOT DEFINED ${_pfx}_HOME AND DEFINED ENV{${_pfx}_HOME})
            set(${_pfx}_HOME $ENV{${_pfx}_HOME})
        endif()

        if(NOT DEFINED ${_pfx}_HOME)
            if(${_pfx}_TAG)
                set(${_pfx}_HOME "${CMAKE_CURRENT_BINARY_DIR}/${target}-${${_pfx}_TAG}-src")
            else()
                set(${_pfx}_HOME "${CMAKE_CURRENT_BINARY_DIR}/${target}-src")
            endif()
            clone_github_repo(${target} ${repo})
        endif()

        if(NOT EXISTS ${${_pfx}_HOME}/CMakeLists.txt)
            message(FATAL_ERROR "${_pfx}_HOME invalid, no CMakeLists.txt found at ${${_pfx}_HOME}")
        endif()

        set(${_pfx}_HOME "${${_pfx}_HOME}" CACHE STRING "${target} source location")
        add_subdirectory(${${_pfx}_HOME} ${target} EXCLUDE_FROM_ALL)
    endif()

    if(NOT TARGET ${target})
        message(FATAL_ERROR "Cannot find ${target}")
    endif()

    set(${_pfx}_LIBRARIES ${target})
    get_target_property(type ${target} TYPE)
    if ("${type}" STREQUAL "INTERFACE_LIBRARY")
        if (CMAKE_VERSION GREATER_EQUAL "3.19")
            get_target_property(${_pfx}_HOME ${target} SOURCE_DIR)
        elseif(NOT ${_pfx}_HOME)
            set(${_pfx}_HOME "${CMAKE_CURRENT_BINARY_DIR}/${target}")
        endif()
        get_target_property(${_pfx}_INCLUDE_DIRS ${target} INTERFACE_INCLUDE_DIRECTORIES)
        if (CMAKE_VERSION GREATER_EQUAL "3.19")
            get_target_property(${_pfx}_VERSION ${target} VERSION)
        endif()
    else()
        get_target_property(${_pfx}_HOME ${target} SOURCE_DIR)
        get_target_property(${_pfx}_INCLUDE_DIRS ${target} INTERFACE_INCLUDE_DIRECTORIES)
        get_target_property(${_pfx}_VERSION ${target} VERSION)
    endif()

    if(NOT ${_pfx}_VERSION)
        set(${_pfx}_VERSION "0.0.0")
    endif()

    include(FindPackageHandleStandardArgs)
    if(CMAKE_VERSION GREATER_EQUAL "3.17")
        set(_mismatch NAME_MISMATCHED)
    endif()

    find_package_handle_standard_args(${_pfx}
        REQUIRED_VARS ${_pfx}_LIBRARIES ${_pfx}_INCLUDE_DIRS
        VERSION_VAR   ${_pfx}_VERSION
        ${_mismatch})
    mark_as_advanced(${_pfx}_LIBRARIES ${_pfx}_INCLUDE_DIRS)

    message(DEBUG "${_pfx}_FOUND         " ${${_pfx}_FOUND})
    message(DEBUG "${_pfx}_HOME          " ${${_pfx}_HOME})
    message(DEBUG "${_pfx}_INCLUDE_DIRS  " ${${_pfx}_INCLUDE_DIRS})
    message(DEBUG "${_pfx}_LIBRARIES     " ${${_pfx}_LIBRARIES})
    message(DEBUG "${_pfx}_VERSION       " ${${_pfx}_VERSION})
endmacro()
