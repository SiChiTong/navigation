###########################################################################
# @licence app begin@
# SPDX-License-Identifier: MPL-2.0
#
# Component Name: configuration-server-plugin
#
# Author: Philippe Colliot
#
# Copyright (C) 2015, PCA Peugeot Citroën
#
# License:
# This Source Code Form is subject to the terms of the
# Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with
# this file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# @licence end@
###########################################################################
project(poicam-server-plugin)
cmake_minimum_required(VERSION 2.8)

message(STATUS ${PROJECT_NAME})

set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_CXX_FLAGS "-Wall -std=c++0x")



set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)


# DBus Path
if(DBUS_LIB_PATH)
  set(DBUS_INCLUDE_DIRS ${DBUS_LIB_PATH}/include/dbus-1.0 ${DBUS_LIB_PATH}/lib/dbus-1.0/include)
  set(DBUS_LIBDIR ${DBUS_LIB_PATH}/lib)
  set(DBUS_LIBRARIES ${DBUS_LIB_PATH}/lib/libdbus-1.so)
else()
  message(FATAL_ERROR "Please specify the path to your patched DBus library using -DDBUS_LIB_PATH=yourPath")
endif()

# Packages
find_package(CommonAPI 3.1.5 REQUIRED)
find_package(CommonAPI-DBus 3.1.5 REQUIRED)


#pkg_check_modules(DBUS "dbus-1 >= 1.8.4") // #to be fixed, it doesn't work so the paths are set manually (see above)
pkg_check_modules(COMMONAPI "CommonAPI >= 3.1.5")
pkg_check_modules(COMMONAPI_DBUS "CommonAPI-DBus >= 3.1.5")
pkg_check_modules(GOBJECT gobject-2.0)
pkg_check_modules(GLIB REQUIRED glib-2.0)
pkg_check_modules(DBUS_CPP_GLIB dbus-c++-glib-1)


# Path to the generated files
set(API_VERSION_MAJOR 4)
set(API_VERSION "v${API_VERSION_MAJOR}")
set(PRJ_SRC_GEN_ROOT_PATH ${COMMONAPI_GEN_DIR}/${API_VERSION}/org/genivi) #files shared by all the APIs
set(PRJ_SRC_GEN_NAVIGATION_PATH ${PRJ_SRC_GEN_ROOT_PATH}/navigation) #files shared by the navigation APIs
set(PRJ_SRC_GEN_POISERVICE_PATH ${PRJ_SRC_GEN_NAVIGATION_PATH}/poiservice) #files shared by the poiservice APIs

# Source Files 
FILE(GLOB PRJ_LOCAL_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx)
# Source Files for generating the server stub
set(FRANCA_FILE_SERVER "POIContentAccessModule")
FILE(GLOB PRJ_STUB_GEN_SRCS
    ${PRJ_SRC_GEN_ROOT_PATH}/*DBusStub*.cpp ${PRJ_SRC_GEN_ROOT_PATH}/*Types.cpp ${PRJ_SRC_GEN_ROOT_PATH}/*DBusDeployment.cpp ${PRJ_SRC_GEN_ROOT_PATH}/*StubDefault.cpp
    ${PRJ_SRC_GEN_NAVIGATION_PATH}/*DBusStub*.cpp ${PRJ_SRC_GEN_NAVIGATION_PATH}/*Types.cpp ${PRJ_SRC_GEN_NAVIGATION_PATH}/*DBusDeployment.cpp ${PRJ_SRC_GEN_NAVIGATION_PATH}/*StubDefault.cpp
    ${PRJ_SRC_GEN_POISERVICE_PATH}/${FRANCA_FILE_SERVER}DBusStub*.cpp ${PRJ_SRC_GEN_POISERVICE_PATH}/${FRANCA_FILE_SERVER}Types.cpp ${PRJ_SRC_GEN_POISERVICE_PATH}/${FRANCA_FILE_SERVER}DBusDeployment.cpp ${PRJ_SRC_GEN_POISERVICE_PATH}/${FRANCA_FILE_SERVER}StubDefault.cpp
    )
FILE(GLOB PRJ_STUB_IMPL_SRCS
    ${PRJ_SRC_GEN_ROOT_PATH}/*Stub*.cpp
    ${PRJ_SRC_GEN_NAVIGATION_PATH}/*Stub*.cpp
    ${PRJ_SRC_GEN_POISERVICE_PATH}/${FRANCA_FILE_SERVER}Stub*.cpp
    )
set(FRANCA_FILE_CLIENT "POIContentAccess")
FILE(GLOB PRJ_PROXY_GEN_SRCS
    ${PRJ_SRC_GEN_POISERVICE_PATH}/${FRANCA_FILE_CLIENT}*DBusProxy.cpp
)

set(PRJ_SRCS ${PRJ_LOCAL_SRCS} ${PRJ_STUB_GEN_SRCS} ${PRJ_STUB_IMPL_SRCS} ${PRJ_PROXY_GEN_SRCS})

include_directories(
    ${COMMONAPI_GEN_DIR}
    ${PRJ_SRC_GEN_ROOT_PATH}
    ${PRJ_SRC_GEN_NAVIGATION_PATH}
    ${PRJ_SRC_GEN_POISERVICE_PATH}
    ${DBUS_INCLUDE_DIRS}
    ${COMMONAPI_INCLUDE_DIRS}
    ${COMMONAPI_DBUS_INCLUDE_DIRS}
    ${GOBJECT_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${DBUS_CPP_GLIB_INCLUDE_DIRS}
)

link_directories(
    ${DBUS_LIBDIR}
    ${COMMONAPI_LIBDIR}
    ${COMMONAPI_DBUS_LIBDIR}
    ${GOBJECT_LIBRARY_DIRS}
    ${GLIB_LIBRARY_DIRS}
    ${DBUS_CPP_GLIB_DIRS}
)

set(LIBRARIES
    ${DBUS_LIBRARIES}
    ${COMMONAPI_LIBRARIES}
    ${COMMONAPI_DBUS_LIBRARIES}
    ${GOBJECT_LIBRARIES}
    ${GLIB_LIBRARIES}
    ${DBUS_CPP_GLIB_LIBRARIES}
)

# Build service
module_add_library(genivi_poiservice_cam_server ${PRJ_SRCS})
target_link_libraries(genivi_poiservice_cam_server ${LIBRARIES})
