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
pkg_check_modules(PKGCFG_LIBRFB QUIET librfb)

find_path(LIBRFB_INCLUDE_DIRS NAMES "librfb.h"
          HINTS $ENV{LIBRFB_HOME}/include ${PKGCFG_LIBRFB_INCLUDE_DIRS})

find_library(LIBRFB_LIBRARIES NAMES rfb "rfb"
             HINTS $ENV{LIBRFB_HOME}/lib ${PKGCFG_LIBRFB_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibRFB
    REQUIRED_VARS LIBRFB_INCLUDE_DIRS LIBRFB_LIBRARIES)

mark_as_advanced(LIBRFB_INCLUDE_DIRS LIBRFB_LIBRARIES)

message(DEBUG "LIBRFB_FOUND        " ${LIBRFB_FOUND})
message(DEBUG "LIBRFB_INCLUDE_DIRS " ${LIBRFB_INCLUDE_DIRS})
message(DEBUG "LIBRFB_LIBRARIES    " ${LIBRFB_LIBRARIES})
