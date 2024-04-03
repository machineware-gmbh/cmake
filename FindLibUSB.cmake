 ##############################################################################
 #                                                                            #
 # Copyright (C) 2024 MachineWare GmbH                                        #
 # All Rights Reserved                                                        #
 #                                                                            #
 # This is work is licensed under the terms described in the LICENSE file     #
 # found in the root directory of this source tree.                           #
 #                                                                            #
 ##############################################################################

find_package(PkgConfig QUIET)
pkg_check_modules(PKGCFG_LIBUSB QUIET libusb-1.0)

find_path(LIBUSB_INCLUDE_DIRS NAMES "libusb.h"
          HINTS $ENV{LIBUSB_HOME}/include ${PKGCFG_LIBUSB_INCLUDE_DIRS})

find_library(LIBUSB_LIBRARIES NAMES "usb-1.0"
             HINTS $ENV{LIBUSB_HOME}/lib ${PKGCFG_LIBUSB_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibUSB
    REQUIRED_VARS LIBUSB_INCLUDE_DIRS LIBUSB_LIBRARIES
    VERSION_VAR   PKGCFG_LIBUSB_VERSION)
mark_as_advanced(LIBUSB_INCLUDE_DIRS LIBUSB_LIBRARIES)

message(DEBUG "LIBUSB_FOUND        " ${LIBUSB_FOUND})
message(DEBUG "LIBUSB_INCLUDE_DIRS " ${LIBUSB_INCLUDE_DIRS})
message(DEBUG "LIBUSB_LIBRARIES    " ${LIBUSB_LIBRARIES})
