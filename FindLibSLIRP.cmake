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
pkg_check_modules(PKGCFG_SLIRP QUIET slirp)

find_path(LIBSLIRP_INCLUDE_DIRS NAMES "libslirp.h"
          HINTS $ENV{LIBSLIRP_HOME}/include/slirp ${PKGCFG_SLIRP_INCLUDE_DIRS})

find_library(LIBSLIRP_LIBRARIES NAMES "slirp"
             HINTS $ENV{LIBSLIRP_HOME}/lib ${PKGCFG_SLIRP_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibSLIRP
    REQUIRED_VARS LIBSLIRP_INCLUDE_DIRS LIBSLIRP_LIBRARIES
    VERSION_VAR   PKGCFG_SLIRP_VERSION)
mark_as_advanced(LIBSLIRP_INCLUDE_DIRS LIBSLIRP_LIBRARIES)

message(DEBUG "LIBSLIRP_FOUND        " ${LIBSLIRP_FOUND})
message(DEBUG "LIBSLIRP_INCLUDE_DIRS " ${LIBSLIRP_INCLUDE_DIRS})
message(DEBUG "LIBSLIRP_LIBRARIES    " ${LIBSLIRP_LIBRARIES})
