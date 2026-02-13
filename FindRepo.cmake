 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

include(FetchContent)
find_package(Git REQUIRED)

execute_process(
    COMMAND ${GIT_EXECUTABLE} config --get remote.origin.url
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE _origin_url
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)

if(_origin_url)
    if(_origin_url MATCHES "https?://([^/]+)/")
        set(_origin_domain "${CMAKE_MATCH_1}")
    elseif(_origin_url MATCHES "git@([^:]+):")
        set(_origin_domain "${CMAKE_MATCH_1}")
    else()
        set(_origin_domain "github.com")
    endif()
endif()

function(find_repo target repo)
    string(TOUPPER ${target} _pfx)
    string(REPLACE "-" "_" _pfx ${_pfx})

    set(${_pfx}_REPO "${repo}" CACHE STRING "${target} repository")
    set(${_pfx}_TAG  "${ARGV2}" CACHE STRING "${target} tag/branch")
    set(${_pfx}_HOME "" CACHE PATH "Local ${target} checkout")

    set(_repo "${${_pfx}_REPO}")
    if(NOT _repo MATCHES "\\.git$")
        set(_repo "${_repo}.git")
    endif()

    if(${_pfx}_HOME AND EXISTS "${${_pfx}_HOME}/CMakeLists.txt")
        message(STATUS "Using local ${target} from ${${_pfx}_HOME}")

        FetchContent_Declare(
            ${target}
            SOURCE_DIR "${${_pfx}_HOME}"
        )
    else()
        if(DEFINED ENV{GITHUB_TOKEN})
            set(_url "https://oauth2:$ENV{GITHUB_TOKEN}@${_origin_domain}/${_repo}")
        else()
            set(_url "https://${_origin_domain}/${_repo}")
        endif()

        if(DEFINED ${_pfx}_TAG AND NOT "${${_pfx}_TAG}" STREQUAL "")
            set(_tag "${${_pfx}_TAG}")
            message(STATUS "Fetching ${target} from ${_origin_domain}/${_repo} (${_tag})")
        else()
            set(_tag "HEAD")
            message(STATUS "Fetching ${target} from ${_origin_domain}/${_repo} (default branch)")
        endif()

        FetchContent_Declare(
            ${target}
            GIT_REPOSITORY ${_url}
            GIT_TAG        ${_tag}
            GIT_SHALLOW    TRUE
        )
    endif()

    FetchContent_MakeAvailable(${target})

    if(NOT TARGET ${target} AND TARGET ${target}::${target})
        set(_tgt ${target}::${target})
    elseif(TARGET ${target})
        set(_tgt ${target})
    else()
        message(FATAL_ERROR "Cannot find CMake target for ${target}")
    endif()

    set(${_pfx}_LIBRARIES ${_tgt} PARENT_SCOPE)

    get_target_property(_inc ${_tgt} INTERFACE_INCLUDE_DIRECTORIES)
    if(NOT _inc)
        set(_inc "")
    endif()
    set(${_pfx}_INCLUDE_DIRS "${_inc}" PARENT_SCOPE)

    get_target_property(_ver ${_tgt} VERSION)
    if(NOT _ver)
        set(_ver "0.0.0")
    endif()
    set(${_pfx}_VERSION "${_ver}" PARENT_SCOPE)
endfunction()
