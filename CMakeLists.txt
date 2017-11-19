cmake_minimum_required (VERSION 2.8)
project (dmx485)

set (LIBS

)

set (SOURCES
	src/dmx485.cpp
	src/dmxObjectD2xx.cpp
)

include_directories(.)
include_directories(./src/)
include_directories(${PROJECT_SOURCE_DIR}/src/)
include_directories(${PROJECT_SOURCE_DIR}/../max-sdk-7.1.0/source/c74support/max-includes)
include_directories(${PROJECT_SOURCE_DIR}/FTDI/)

#add_subdirectory(libftdi)
#add_subdirectory(libusb)

# include(ExternalProject)
# ExternalProject_Add(libusb
#    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libusb
#		INSTALL_DIR ${PROJECT_SOURCE_DIR}/build
#    CONFIGURE_COMMAND cd ${PROJECT_SOURCE_DIR}/libusb/  && ./configure CC=/usr/bin/gcc # CCFLAGS="-arch x86_64" CXXFLAGS="-arch x86_64"
#		PREFIX ${INSTALL_DIR}
#	  BUILD_COMMAND make
#    BUILD_IN_SOURCE 1
#  )

#-arch i386 

set (CMAKE_OSX_ARCHITECTURES "x86_64" ) #"i386"

add_library(dmx485 MODULE ${SOURCES})
#add_dependencies(dmx485 libusb)

# target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx.1.2.2.dylib)
target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx.1.4.4.dylib)
# target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx32.a)
# target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx64.a)

#target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/build/lib/libusb-1.0.a)

target_link_libraries(dmx485 ${LIBS} "-undefined dynamic_lookup")
set_target_properties(dmx485 PROPERTIES PREFIX "")
set_target_properties(dmx485 PROPERTIES SUFFIX ".mxo")
set_target_properties(dmx485 PROPERTIES BUNDLE TRUE)
set_target_properties(dmx485 PROPERTIES BUNDLE_EXTENSION "mxo")

install(TARGETS dmx485 DESTINATION ${PROJECT_SOURCE_DIR}/bin)
configure_file(${PROJECT_SOURCE_DIR}/help/dmx485.maxhelp ${PROJECT_SOURCE_DIR}/bin/dmx485.maxhelp COPYONLY)
