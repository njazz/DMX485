cmake_minimum_required (VERSION 2.8)
SET(CMAKE_CXX_FLAGS "-std=c++0x")

project (dmx485)

set (SOURCES
        src/dmx485.cpp
#        src/dmxObjectD2xx.cpp
        src/DMXObjectCore.cpp
)

include_directories(.)
include_directories(./src/)
include_directories(${PROJECT_SOURCE_DIR}/src/)
include_directories(${PROJECT_SOURCE_DIR}/../max-sdk-7.1.0/source/c74support/max-includes)
include_directories(${PROJECT_SOURCE_DIR}/FTDI/)

set (CMAKE_OSX_ARCHITECTURES "x86_64" "i386")

add_library(dmx485 MODULE ${SOURCES})
set_property(TARGET dmx485 PROPERTY CXX_STANDARD 11)

target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx.1.2.2.dylib)

target_link_libraries(dmx485 ${LIBS} "-undefined dynamic_lookup")
set_target_properties(dmx485 PROPERTIES PREFIX "")
set_target_properties(dmx485 PROPERTIES SUFFIX ".mxo")
set_target_properties(dmx485 PROPERTIES BUNDLE TRUE)
set_target_properties(dmx485 PROPERTIES BUNDLE_EXTENSION "mxo")

install(TARGETS dmx485 DESTINATION ${PROJECT_SOURCE_DIR}/bin)
configure_file(${PROJECT_SOURCE_DIR}/help/dmx485.maxhelp ${PROJECT_SOURCE_DIR}/bin/dmx485.maxhelp COPYONLY)

set_target_properties(dmx485 PROPERTIES OUTPUT_NAME "dmx485")

####

project (dmx485pd)

set (SOURCES_PD
        src/dmx485_pd.cpp
#        src/dmxObjectD2xx.cpp

        src/DMXObjectCore.cpp
)

add_definitions(-DPD_BUILD)

#include(ExternalProject)
#ExternalProject_Add(libusb
#    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libusb
#                INSTALL_DIR ${PROJECT_SOURCE_DIR}/build
#    CONFIGURE_COMMAND cd ${PROJECT_SOURCE_DIR}/libusb/  && ./configure CC=/usr/bin/gcc CCFLAGS="-arch i386 -arch x86_64" CXXFLAGS="-arch i386 -arch x86_64"
#                PREFIX ${INSTALL_DIR}
#          BUILD_COMMAND make
#    BUILD_IN_SOURCE 1
#  )

set (CMAKE_OSX_ARCHITECTURES "x86_64" "i386") # "i386")

include_directories(.)
include_directories(./src/)
include_directories(${PROJECT_SOURCE_DIR}/src/)
include_directories(${PROJECT_SOURCE_DIR}/../max-sdk-7.1.0/source/c74support/max-includes)
include_directories(${PROJECT_SOURCE_DIR}/FTDI/)

add_library(dmx485pd MODULE ${SOURCES_PD} )
set_property(TARGET dmx485pd PROPERTY CXX_STANDARD 11)

target_link_libraries(dmx485pd ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx.1.2.2.dylib)
#target_link_libraries(dmx485pd ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx64.a)

target_link_libraries(dmx485pd ${LIBS} "-undefined dynamic_lookup")
set_target_properties(dmx485pd PROPERTIES PREFIX "")
set_target_properties(dmx485pd PROPERTIES SUFFIX ".pd_darwin")

set_target_properties(dmx485pd PROPERTIES OUTPUT_NAME "dmx485")

install(TARGETS dmx485pd DESTINATION ${PROJECT_SOURCE_DIR}/bin)
configure_file(${PROJECT_SOURCE_DIR}/help/dmx485--help.pd ${PROJECT_SOURCE_DIR}/bin/dmx485--help.pd COPYONLY)
