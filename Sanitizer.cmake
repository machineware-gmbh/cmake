 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

# Common Sanitizer flags
set(sani_c_flags "-fno-omit-frame-pointer -g -O1")
set(sani_cxx_flags "-fno-omit-frame-pointer -g -O1")
set(sani_linker_flags "-fno-omit-frame-pointer -g -O1")

if (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND
    CMAKE_C_COMPILER_VERSION VERSION_LESS "12.0.0")
    set(sani_c_flags "${sani_c_flags} -fno-var-tracking-assignments")
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND 
    CMAKE_CXX_COMPILER_VERSION VERSION_LESS "12.0.0")
    set(sani_cxx_flags "${sani_cxx_flags} -fno-var-tracking-assignments")
endif()

# Address Sanitizer
set(CMAKE_C_FLAGS_ASAN
    "-fsanitize=address ${sani_c_flags}" CACHE STRING
    "Flags used by the C++ compiler during ASAN builds." FORCE)
set(CMAKE_CXX_FLAGS_ASAN
    "-fsanitize=address ${sani_cxx_flags}" CACHE STRING
    "Flags used by the C compiler during ASAN builds." FORCE)
set(CMAKE_EXE_LINKER_FLAGS_ASAN
    "-fsanitize=address ${sani_linker_flags}" CACHE STRING
    "Flags used for linking binaries during ASAN builds." FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_ASAN
    "-fsanitize=address ${sani_linker_flags}" CACHE STRING
    "Flags used by the shared libraries linker during ASAN builds." FORCE)

mark_as_advanced(CMAKE_C_FLAGS_ASAN CMAKE_CXX_FLAGS_ASAN
                 CMAKE_EXE_LINKER_FLAGS_ASAN CMAKE_SHARED_LINKER_FLAGS_ASAN)


# Thread Sanitizer
set(CMAKE_C_FLAGS_TSAN
    "-fsanitize=thread ${sani_c_flags}" CACHE STRING
    "Flags used by the C++ compiler during TSAN builds." FORCE)
set(CMAKE_CXX_FLAGS_TSAN
    "-fsanitize=thread ${sani_cxx_flags}" CACHE STRING
    "Flags used by the C compiler during TSAN builds." FORCE)
set(CMAKE_EXE_LINKER_FLAGS_TSAN
    "-fsanitize=thread ${sani_linker_flags}" CACHE STRING
    "Flags used for linking binaries during TSAN builds." FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_TSAN
    "-fsanitize=thread ${sani_linker_flags}" CACHE STRING
    "Flags used by the shared libraries linker during TSAN builds." FORCE)

mark_as_advanced(CMAKE_C_FLAGS_TSAN CMAKE_CXX_FLAGS_TSAN
                 CMAKE_EXE_LINKER_FLAGS_TSAN CMAKE_SHARED_LINKER_FLAGS_TSAN)


# Undefined Behavior Sanitizer
set(CMAKE_C_FLAGS_UBSAN
    "-fsanitize=undefined ${sani_c_flags}" CACHE STRING
    "Flags used by the C++ compiler during UBSAN builds." FORCE)
set(CMAKE_CXX_FLAGS_UBSAN
    "-fsanitize=undefined ${sani_cxx_flags}" CACHE STRING
    "Flags used by the C compiler during UBSAN builds." FORCE)
set(CMAKE_EXE_LINKER_FLAGS_UBSAN
    "-fsanitize=undefined ${sani_linker_flags}" CACHE STRING
    "Flags used for linking binaries during UBSAN builds." FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_UBSAN
    "-fsanitize=undefined ${sani_linker_flags}" CACHE STRING
    "Flags used by the shared libraries linker during UBSAN builds." FORCE)

mark_as_advanced(CMAKE_C_FLAGS_UBSAN CMAKE_CXX_FLAGS_UBSAN
                 CMAKE_EXE_LINKER_FLAGS_UBSAN CMAKE_SHARED_LINKER_FLAGS_UBSAN)


# Update the documentation string of CMAKE_BUILD_TYPE for GUIs
set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: DEBUG RELEASE RELWITHDEBINFO MINSIZEREL ASAN TSAN UBSAN."
    FORCE)
