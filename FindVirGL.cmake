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
pkg_check_modules(PKGCFG_VIRGL QUIET virglrenderer)

find_path(VIRGL_INCLUDE_DIRS NAMES "virglrenderer.h"
          HINTS $ENV{VIRGL_HOME}/include ${PKGCFG_VIRGL_INCLUDE_DIRS})

find_library(VIRGL_LIBRARIES NAMES "virglrenderer"
             HINTS $ENV{VIRGL_HOME}/lib ${PKGCFG_VIRGL_LIBRARY_DIRS})

mark_as_advanced(VIRGL_INCLUDE_DIRS VIRGL_LIBRARIES)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(VirGL
    REQUIRED_VARS VIRGL_INCLUDE_DIRS VIRGL_LIBRARIES
    VERSION_VAR   PKGCFG_VIRGL_VERSION)

message(DEBUG "VIRGL_FOUND        " ${VIRGL_FOUND})
message(DEBUG "VIRGL_INCLUDE_DIRS " ${VIRGL_INCLUDE_DIRS})
message(DEBUG "VIRGL_LIBRARIES    " ${VIRGL_LIBRARIES})
