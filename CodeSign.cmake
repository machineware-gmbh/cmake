 ##############################################################################
 #                                                                            #
 # Copyright (C) 2023 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

function(target_codesign target)
    if(NOT APPLE)
        return()
    endif()

    cmake_parse_arguments(CODESIGN "" "SIGNATURE" "ENTITLEMENTS" ${ARGN})

    if(CODESIGN_SIGNATURE)
        set(args --sign ${CODESIGN_SIGNATURE} --force $<TARGET_FILE:${target}>)
    else()
        set(args --sign - --force $<TARGET_FILE:${target}>)
    endif()

    if(CODESIGN_ENTITLEMENTS)
        set(args ${args} --entitlements ${CODESIGN_ENTITLEMENTS})
    endif()

    add_custom_command(TARGET ${target} POST_BUILD COMMAND codesign ${args})
endfunction()
