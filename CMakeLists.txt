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

set (CMAKE_OSX_ARCHITECTURES "x86_64" "i386")

add_library(dmx485 MODULE ${SOURCES})

target_link_libraries(dmx485 ${PROJECT_SOURCE_DIR}/FTDI/libftd2xx.a)

target_link_libraries(dmx485 ${LIBS} "-undefined dynamic_lookup")
set_target_properties(dmx485 PROPERTIES PREFIX "")
set_target_properties(dmx485 PROPERTIES SUFFIX ".mxo")
set_target_properties(dmx485 PROPERTIES BUNDLE TRUE)
set_target_properties(dmx485 PROPERTIES BUNDLE_EXTENSION "mxo")

install(TARGETS dmx485 DESTINATION ${PROJECT_SOURCE_DIR}/bin)
configure_file(${PROJECT_SOURCE_DIR}/help/dmx485.maxhelp ${PROJECT_SOURCE_DIR}/bin/dmx485.maxhelp COPYONLY)
