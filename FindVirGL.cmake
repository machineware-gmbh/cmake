 ##############################################################################
 #                                                                            #
 # Copyright 2022 MachineWare GmbH                                            #
 #                                                                            #
 # Licensed under the Apache License, Version 2.0 (the "License");            #
 # you may not use this file except in compliance with the License.           #
 # You may obtain a copy of the License at                                    #
 #                                                                            #
 #     http://www.apache.org/licenses/LICENSE-2.0                             #
 #                                                                            #
 # Unless required by applicable law or agreed to in writing, software        #
 # distributed under the License is distributed on an "AS IS" BASIS,          #
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
 # See the License for the specific language governing permissions and        #
 # limitations under the License.                                             #
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
