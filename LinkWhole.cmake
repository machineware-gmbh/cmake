 ##############################################################################
 #                                                                            #
 # Copyright (C) 2023 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

function(do_target_link_whole_archives target visibility lib)
    if(MSVC)
        target_link_libraries(${target} ${visibility} -WHOLEARCHIVE:$<TARGET_FILE:${lib}> ${lib})
    elseif(APPLE)
        target_link_libraries(${target} ${visibility} -Wl,-force_load ${lib})
    else()
        target_link_libraries(${target} ${visibility} -Wl,--whole-archive ${lib} -Wl,--no-whole-archive)
    endif()
endfunction()

function(target_link_whole_archives target)
    cmake_parse_arguments(WHOLE "" "" "PUBLIC;PRIVATE;INTERFACE" ${ARGN})

    foreach(lib IN LISTS WHOLE_PRIVATE)
        do_target_link_whole_archives(${target} PRIVATE ${lib})
    endforeach()
 
    foreach(lib IN LISTS WHOLE_PUBLIC)
        do_target_link_whole_archives(${target} PUBLIC ${lib})
    endforeach()

    foreach(lib IN LISTS WHOLE_INTERFACE)
        do_target_link_whole_archives(${target} INTERFACE ${lib})
    endforeach()

    foreach(lib IN LISTS WHOLE_UNPARSED_ARGUMENTS)
        do_target_link_whole_archives(${target} "" ${lib})
    endforeach()
endfunction()
