cmake_minimum_required (VERSION 2.8)

set (SOURCES
	src/ftdi_stream.c
	src/ftdi.c
)


include_directories(../libusb/libusb)

add_library(libftdi MODULE ${SOURCES} ${LIBUSB-SRC})
