# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.6

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/3.6.1/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/3.6.1/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/njazz/Documents/github/DMX485_0.62

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/njazz/Documents/github/DMX485_0.62/build

# Include any dependencies generated for this target.
include CMakeFiles/dmx485.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/dmx485.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/dmx485.dir/flags.make

CMakeFiles/dmx485.dir/src/dmx485.cpp.o: CMakeFiles/dmx485.dir/flags.make
CMakeFiles/dmx485.dir/src/dmx485.cpp.o: ../src/dmx485.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/njazz/Documents/github/DMX485_0.62/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/dmx485.dir/src/dmx485.cpp.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/dmx485.dir/src/dmx485.cpp.o -c /Users/njazz/Documents/github/DMX485_0.62/src/dmx485.cpp

CMakeFiles/dmx485.dir/src/dmx485.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/dmx485.dir/src/dmx485.cpp.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/njazz/Documents/github/DMX485_0.62/src/dmx485.cpp > CMakeFiles/dmx485.dir/src/dmx485.cpp.i

CMakeFiles/dmx485.dir/src/dmx485.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/dmx485.dir/src/dmx485.cpp.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/njazz/Documents/github/DMX485_0.62/src/dmx485.cpp -o CMakeFiles/dmx485.dir/src/dmx485.cpp.s

CMakeFiles/dmx485.dir/src/dmx485.cpp.o.requires:

.PHONY : CMakeFiles/dmx485.dir/src/dmx485.cpp.o.requires

CMakeFiles/dmx485.dir/src/dmx485.cpp.o.provides: CMakeFiles/dmx485.dir/src/dmx485.cpp.o.requires
	$(MAKE) -f CMakeFiles/dmx485.dir/build.make CMakeFiles/dmx485.dir/src/dmx485.cpp.o.provides.build
.PHONY : CMakeFiles/dmx485.dir/src/dmx485.cpp.o.provides

CMakeFiles/dmx485.dir/src/dmx485.cpp.o.provides.build: CMakeFiles/dmx485.dir/src/dmx485.cpp.o


CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o: CMakeFiles/dmx485.dir/flags.make
CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o: ../src/dmxObjectD2xx.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/njazz/Documents/github/DMX485_0.62/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o -c /Users/njazz/Documents/github/DMX485_0.62/src/dmxObjectD2xx.cpp

CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/njazz/Documents/github/DMX485_0.62/src/dmxObjectD2xx.cpp > CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.i

CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/njazz/Documents/github/DMX485_0.62/src/dmxObjectD2xx.cpp -o CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.s

CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.requires:

.PHONY : CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.requires

CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.provides: CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.requires
	$(MAKE) -f CMakeFiles/dmx485.dir/build.make CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.provides.build
.PHONY : CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.provides

CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.provides.build: CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o


# Object files for target dmx485
dmx485_OBJECTS = \
"CMakeFiles/dmx485.dir/src/dmx485.cpp.o" \
"CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o"

# External object files for target dmx485
dmx485_EXTERNAL_OBJECTS =

dmx485.mxo/Contents/MacOS/dmx485: CMakeFiles/dmx485.dir/src/dmx485.cpp.o
dmx485.mxo/Contents/MacOS/dmx485: CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o
dmx485.mxo/Contents/MacOS/dmx485: CMakeFiles/dmx485.dir/build.make
dmx485.mxo/Contents/MacOS/dmx485: ../FTDI/libftd2xx.a
dmx485.mxo/Contents/MacOS/dmx485: CMakeFiles/dmx485.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/njazz/Documents/github/DMX485_0.62/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking CXX CFBundle shared module dmx485.mxo/Contents/MacOS/dmx485"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/dmx485.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/dmx485.dir/build: dmx485.mxo/Contents/MacOS/dmx485

.PHONY : CMakeFiles/dmx485.dir/build

CMakeFiles/dmx485.dir/requires: CMakeFiles/dmx485.dir/src/dmx485.cpp.o.requires
CMakeFiles/dmx485.dir/requires: CMakeFiles/dmx485.dir/src/dmxObjectD2xx.cpp.o.requires

.PHONY : CMakeFiles/dmx485.dir/requires

CMakeFiles/dmx485.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/dmx485.dir/cmake_clean.cmake
.PHONY : CMakeFiles/dmx485.dir/clean

CMakeFiles/dmx485.dir/depend:
	cd /Users/njazz/Documents/github/DMX485_0.62/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/njazz/Documents/github/DMX485_0.62 /Users/njazz/Documents/github/DMX485_0.62 /Users/njazz/Documents/github/DMX485_0.62/build /Users/njazz/Documents/github/DMX485_0.62/build /Users/njazz/Documents/github/DMX485_0.62/build/CMakeFiles/dmx485.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/dmx485.dir/depend

