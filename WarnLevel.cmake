 ##############################################################################
 #                                                                            #
 # Copyright (C) 2023 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

if(MSVC)
    set(MWR_COMPILER_WARN_FLAGS /W3 /WX CACHE STRING
        "Specifies the compiler warning flags to be used during builds." FORCE)
else()
    set(MWR_COMPILER_WARN_FLAGS -Wall -Werror CACHE STRING
        "Specifies the compiler warning flags to be used during builds." FORCE)
endif()
