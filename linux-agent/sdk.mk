SR_PLUGIN_LUA:=1
CPPFLAGS:=$(shell pkg-config --cflags libcurl lua)
CXXFLAGS:=-Wall -pedantic -Wextra
LDLIBS:=$(shell pkg-config --libs libcurl lua)