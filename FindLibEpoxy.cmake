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
pkg_check_modules(PKGCFG_LIBEPOXY QUIET epoxy)

find_path(LIBEPOXY_INCLUDE_DIRS NAMES "epoxy/gl.h"
          HINTS $ENV{LIBEPOXY_HOME}/include ${PKGCFG_LIBEPOXY_INCLUDE_DIRS})

find_library(LIBEPOXY_LIBRARIES NAMES "epoxy"
             HINTS $ENV{LIBEPOXY_HOME}/lib ${PKGCFG_LIBEPOXY_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibEpoxy
    REQUIRED_VARS LIBEPOXY_INCLUDE_DIRS LIBEPOXY_LIBRARIES
    VERSION_VAR   PKGCFG_LIBEPOXY_VERSION)
mark_as_advanced(LIBEPOXY_INCLUDE_DIRS LIBEPOXY_LIBRARIES)

message(DEBUG "LIBEPOXY_FOUND        " ${LIBEPOXY_FOUND})
message(DEBUG "LIBEPOXY_INCLUDE_DIRS " ${LIBEPOXY_INCLUDE_DIRS})
message(DEBUG "LIBEPOXY_LIBRARIES    " ${LIBEPOXY_LIBRARIES})
