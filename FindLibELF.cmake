 ##############################################################################
 #                                                                            #
 # Copyright (C) 2022 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

find_package(PkgConfig QUIET)
pkg_check_modules(PKGCFG_LIBELF QUIET libelf)

find_path(LIBELF_INCLUDE_DIRS NAMES "libelf.h"
          HINTS $ENV{LIBELF_HOME}/include ${PKGCFG_LIBELF_INCLUDE_DIRS})

find_library(LIBELF_LIBRARIES NAMES elf "elf"
             HINTS $ENV{LIBELF_HOME}/lib ${PKGCFG_LIBELF_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibELF
    REQUIRED_VARS LIBELF_INCLUDE_DIRS LIBELF_LIBRARIES
    VERSION_VAR   PKGCFG_LIBELF_VERSION)
mark_as_advanced(LIBELF_INCLUDE_DIRS LIBELF_LIBRARIES)

message(DEBUG "LIBELF_FOUND        " ${LIBELF_FOUND})
message(DEBUG "LIBELF_INCLUDE_DIRS " ${LIBELF_INCLUDE_DIRS})
message(DEBUG "LIBELF_LIBRARIES    " ${LIBELF_LIBRARIES})
