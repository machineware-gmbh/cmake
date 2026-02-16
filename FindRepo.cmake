 ##############################################################################
 #                                                                            #
 # Copyright (C) 2026 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

include(FetchContent)
include(FindPackageHandleStandardArgs)

find_package(Git REQUIRED)

set(_origin_domain "github.com")

execute_process(
    COMMAND ${GIT_EXECUTABLE} config --get remote.origin.url
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE _origin_url
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET)

if(_origin_url)
    if(_origin_url MATCHES "https?://([^/]+)/")
        set(_origin_domain "${CMAKE_MATCH_1}")
    elseif(_origin_url MATCHES "git@([^:]+):")
        set(_origin_domain "${CMAKE_MATCH_1}")
    endif()
endif()

function(find_repo target repo)
    string(TOUPPER ${target} _pfx)
    string(REPLACE "-" "_" _pfx ${_pfx})

    set(${_pfx}_REPO "${repo}" CACHE STRING "${target} repository")
    set(${_pfx}_TAG  "${ARGV2}" CACHE STRING "${target} tag/branch")

    if(NOT DEFINED ${_pfx}_HOME AND DEFINED ENV{${_pfx}_HOME})
        set(${_pfx}_HOME "$ENV{${_pfx}_HOME}")
    endif()

    if(NOT TARGET ${target})
        if(${_pfx}_HOME AND EXISTS "${${_pfx}_HOME}/CMakeLists.txt")
            FetchContent_Declare(${target}
                SOURCE_DIR "${${_pfx}_HOME}")
        else()
            if(NOT MWR_NO_AUTOCLONE)
                set(MWR_NO_AUTOCLONE $ENV{MWR_NO_AUTOCLONE})
            endif()

            if(MWR_NO_AUTOCLONE)
                message(FATAL_ERROR "${_pfx}_HOME invalid and autoclone disabled")
            endif()

            set(_repo "${${_pfx}_REPO}")
            if(NOT _repo MATCHES "\\.git$")
                set(_repo "${_repo}.git")
            endif()

            if(DEFINED ENV{GITHUB_TOKEN})
                set(_url "https://oauth2:$ENV{GITHUB_TOKEN}@${_origin_domain}/${_repo}")
            else()
                set(_url "https://${_origin_domain}/${_repo}")
            endif()

            if(DEFINED ${_pfx}_TAG AND NOT "${${_pfx}_TAG}" STREQUAL "")
                set(_tag "${${_pfx}_TAG}")
                message(STATUS "Fetching ${target} from ${_origin_domain} [${_tag}]")
            else()
                set(_tag "HEAD")
                message(STATUS "Fetching ${target} from ${_origin_domain} [default branch]")
            endif()

            FetchContent_Declare(
                ${target}
                GIT_REPOSITORY ${_url}
                GIT_TAG        ${_tag}
                GIT_SHALLOW    TRUE)
        endif()

        FetchContent_MakeAvailable(${target})
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

    set(${_pfx}_HOME "${${_pfx}_HOME}" CACHE PATH "${target} home directory" FORCE)

    if(NOT ${_pfx}_VERSION)
        set(${_pfx}_VERSION "0.0.0")
    endif()

    if(CMAKE_VERSION GREATER_EQUAL "3.17")
        set(_mismatch NAME_MISMATCHED)
    endif()

    find_package_handle_standard_args(${_pfx}
        REQUIRED_VARS ${_pfx}_LIBRARIES ${_pfx}_INCLUDE_DIRS
        VERSION_VAR   ${_pfx}_VERSION
        ${_mismatch})

    set(${_pfx}_FOUND ${${_pfx}_FOUND} PARENT_SCOPE)
    mark_as_advanced(${_pfx}_LIBRARIES ${_pfx}_INCLUDE_DIRS)

    message(DEBUG "${_pfx}_FOUND         " ${${_pfx}_FOUND})
    message(DEBUG "${_pfx}_HOME          " ${${_pfx}_HOME})
    message(DEBUG "${_pfx}_INCLUDE_DIRS  " ${${_pfx}_INCLUDE_DIRS})
    message(DEBUG "${_pfx}_LIBRARIES     " ${${_pfx}_LIBRARIES})
    message(DEBUG "${_pfx}_VERSION       " ${${_pfx}_VERSION})
endfunction()
