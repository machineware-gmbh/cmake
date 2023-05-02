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
pkg_check_modules(PKGCFG_VNC QUIET libvncserver)

find_path(LIBVNC_INCLUDE_DIRS NAMES "rfb/rfb.h"
          HINTS $ENV{LIBVNC_HOME}/include ${PKGCFG_VNC_INCLUDE_DIRS})

find_library(LIBVNC_LIBRARIES NAMES "vncserver"
             HINTS $ENV{LIBVNC_HOME}/lib ${PKGCFG_VNC_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibVNC
    REQUIRED_VARS LIBVNC_INCLUDE_DIRS LIBVNC_LIBRARIES
    VERSION_VAR   PKGCFG_VNC_VERSION)
mark_as_advanced(LIBVNC_INCLUDE_DIRS LIBVNC_LIBRARIES)

message(DEBUG "LIBVNC_FOUND        " ${LIBVNC_FOUND})
message(DEBUG "LIBVNC_INCLUDE_DIRS " ${LIBVNC_INCLUDE_DIRS})
message(DEBUG "LIBVNC_LIBRARIES    " ${LIBVNC_LIBRARIES})
