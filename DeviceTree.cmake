 ##############################################################################
 #                                                                            #
 # Copyright (C) 2024 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

# This will preprocess and compile a devicetree using cmake, syntax is:
#
# compile_dts(<name> SOURCE <source> [INCLUDES <dirs>] [DEFINES <defines>])
#
# Example:
#   compile_dts(mytree.dtb SOURCE src/mytree.dts INCLUDES kernel/headers DEFINES FOO=BAR)
#   install(${CMAKE_CURRENT_BINARY_DIR}/mytree.dtb DESTINATION firmware/)

function(compile_dts output)
    cmake_parse_arguments(DTS "" "SOURCE" "INCLUDES;DEFINES" ${ARGN})
    if(NOT output)
        message(FATAL_ERROR "OUTPUT argument is required")
    endif()

    if(NOT DTS_SOURCE)
        message(FATAL_ERROR "SOURCE argument is required")
    endif()

    if(NOT IS_ABSOLUTE DTS_SOURCE)
        set(DTS_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/${DTS_SOURCE})
    endif()

    find_program(DTC_COMPILER NAMES dtc dtc.exe)
    if(NOT DTC_COMPILER)
        message(FATAL_ERROR "DTC compiler not found. Please install dtc.")
    endif()

    # collect define flags
    set(define_flags "")
    foreach(def IN LISTS DTS_DEFINES)
        list(APPEND define_flags -D${def})
    endforeach()

    # collect include directories
    set(include_flags "")
    foreach(dir IN LISTS DTS_INCLUDES)
        if(NOT IS_ABSOLUTE dir)
            set(dir "${CMAKE_CURRENT_SOURCE_DIR}/${dir}")
        endif()
        list(APPEND include_flags -I${dir})
    endforeach()

    # collect all device tree includes
    set(include_files "")
    foreach(dir IN LISTS DTS_INCLUDES)
        file(GLOB_RECURSE headers "${dir}/*.dtsi")
        list(APPEND include_files ${headers})
    endforeach()

    # find a compiler we can use for preprocessing
    if(MSVC)
        set(preprocessor ${CMAKE_C_COMPILER})
        set(preprocessor_flags /P /EP /TC /D__DTS__ ${include_flags} ${define_flags})
        set(preprocessor_output "${output}.i")
    else()
        set(preprocessor ${CMAKE_C_COMPILER})
        set(preprocessor_flags -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp ${include_flags} ${define_flags})
        set(preprocessor_output "${output}.pp")
    endif()

    add_custom_command(
        OUTPUT ${output}
        COMMAND ${preprocessor} ${preprocessor_flags} ${DTS_SOURCE} -o ${preprocessor_output}
        COMMAND ${DTC_COMPILER} -I dts -O dtb -o ${output} ${preprocessor_output}
        DEPENDS ${DTS_SOURCE} ${include_files}
        COMMENT "Compiling devicetree ${output}"
        VERBATIM
    )

    add_custom_target(${output}_target ALL DEPENDS ${output})
endfunction()
