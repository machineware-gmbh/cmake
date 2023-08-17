 ##############################################################################
 #                                                                            #
 # Copyright (C) 2023 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

function(target_compile_warnings target)
    if(MSVC)
        target_compile_options(${target} PRIVATE /W3 /WX)
    else()
        target_compile_options(${target} PRIVATE -Wall -Werror)
    endif()
endfunction()
