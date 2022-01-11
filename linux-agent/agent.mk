PLUGIN_MODBUS:=1
BUILD:=debug

SRC_DIR:=src
BUILD_DIR:=build
LIB_DIR:=lib
BIN_DIR:=bin
STAGE_DIR:=build/staging
PREFIX:=/usr
PKG_DIR:=$(PREFIX)/share/cumulocity-agent
DATAPATH:=/var/lib/cumulocity-agent

SRC:=$(wildcard $(SRC_DIR)/*.cc) $(wildcard $(SRC_DIR)/module/*.cc)
ifeq ($(PLUGIN_MODBUS),1)
SRC+=$(wildcard $(SRC_DIR)/modbus/*.cc)
endif
OBJ:=$(addprefix $(BUILD_DIR)/, $(SRC:.cc=.o))
BIN:=cumulocity-agent

VNC_SRC:=$(wildcard $(SRC_DIR)/vnc/*.c)
VNC_OBJ:=$(addprefix $(BUILD_DIR)/, $(VNC_SRC:.c=.o))
VNC_BIN:=vncproxy

CPPFLAGS+=-I$(C8Y_LIB_PATH)/include $(shell pkg-config --cflags lua5.3)\
		  -DPKG_DIR='"$(PKG_DIR)"'
CXXFLAGS+=-Wall -pedantic -Wextra -std=c++11 -MMD
LDFLAGS:=-Llib
LDLIBS:=-lsera $(shell pkg-config --libs lua5.3) -pthread

VNC_CPPFLAGS+=$(shell pkg-config --cflags libcurl)
CFLAGS+=-Wall -pedantic -Wextra -MMD
VNC_LDLIBS:=$(shell pkg-config --libs libcurl)

ifeq ($(PLUGIN_MODBUS),1)
CPPFLAGS+=-DPLUGIN_MODBUS $(shell pkg-config --cflags libmodbus)
LDLIBS+=$(shell pkg-config --libs libmodbus)
endif

ifeq ($(BUILD), release)
CPPFLAGS+=-DNDEBUG
CFLAGS+=-O2
CXXFLAGS+=-O2
LDFLAGS+=-O2 -s -flto
else
CPPFLAGS+=-DDEBUG
CFLAGS+=-O0 -g
CXXFLAGS+=-O0 -g
LDFLAGS+=-O0 -g
endif

.PHONY: all release clean

all: $(BIN_DIR)/$(BIN)
	@:

release:
	@make -s "BUILD=release"

vnc: $(BIN_DIR)/$(VNC_BIN)

install:
	@echo -n "Installing to $(PREFIX)/share... "
	@mkdir -p $(PREFIX)/bin
	@cp $(BIN_DIR)/$(BIN) $(BIN_DIR)/srwatchdogd $(PREFIX)/bin
	@cp -rP lib/ $(PREFIX)
	@mkdir -p $(PKG_DIR) $(DATAPATH)
	@cp -rP lua srtemplate.txt COPYRIGHT $(PKG_DIR)
	@sed -e 's#\$$PKG_DIR#$(PKG_DIR)#g' cumulocity-agent.conf | sed -e 's#\$$DATAPATH#$(DATAPATH)#g' > $(PKG_DIR)/cumulocity-agent.conf
	@test -d /lib/systemd/system && sed 's#$$PREFIX#$(PREFIX)#g' utils/cumulocity-agent.service > /lib/systemd/system/cumulocity-agent.service
	@touch /etc/cumulocity-agent.conf
	@echo 'OK!'

debian:
	@mkdir -p $(STAGE_DIR)/$@$(PREFIX)/bin
	@cp $(BIN_DIR)/$(BIN) $(BIN_DIR)/srwatchdogd $(STAGE_DIR)/$@$(PREFIX)/bin
	@mkdir -p $(STAGE_DIR)/$@$(PREFIX)/lib
	@cp -P $(LIB_DIR)/libsera.so.1* $(STAGE_DIR)/$@$(PREFIX)/lib
	@chmod -x $(STAGE_DIR)/$@$(PREFIX)/lib/*
	@mkdir -p $(STAGE_DIR)/$@$(PKG_DIR)
	@cp -rP lua srtemplate.txt $(STAGE_DIR)/$@$(PKG_DIR)
	@sed -e 's#\$$PKG_DIR#$(PKG_DIR)#g' cumulocity-agent.conf | sed -e 's#\$$DATAPATH#$(DATAPATH)#g' > $(STAGE_DIR)/$@$(PKG_DIR)/cumulocity-agent.conf
	@mkdir -p $(STAGE_DIR)/$@$(PREFIX)/share/doc/cumulocity-agent/
	@cp COPYRIGHT $(STAGE_DIR)/$@$(PREFIX)/share/doc/cumulocity-agent/copyright
	@cp -r pkg/$@/DEBIAN $(STAGE_DIR)/$@
	@mkdir -p $(STAGE_DIR)/$@/lib/systemd/system
	@sed 's#$$PREFIX#$(PREFIX)#g' utils/cumulocity-agent.service > $(STAGE_DIR)/$@/lib/systemd/system/cumulocity-agent.service
	@find $(STAGE_DIR)/$@ -type d | xargs chmod 755
	@fakeroot dpkg-deb --build $(STAGE_DIR)/$@ build

snap:
	@mkdir -p $(STAGE_DIR)/$@/bin $(STAGE_DIR)/$@/lib
	@cp $(BIN_DIR)/$(BIN) $(BIN_DIR)/srwatchdogd $(STAGE_DIR)/$@/bin
	@cp -P $(LIB_DIR)/libsera.so.1* $(STAGE_DIR)/$@/lib
	@chmod -x $(STAGE_DIR)/$@/lib/*
	@cp -rP lua srtemplate.txt $(STAGE_DIR)/$@
	@sed -e 's#\$$PKG_DIR#$(PKG_DIR)#g' cumulocity-agent.conf | sed -e 's#\$$DATAPATH#$(DATAPATH)#g' > $(STAGE_DIR)/$@/cumulocity-agent.conf
	@cp pkg/$@/snapcraft.yaml $(STAGE_DIR)/$@
	@cd $(STAGE_DIR)/$@ && snapcraft clean && snapcraft

rpm:
	@pkg/rpm/build_rpm.sh ${args}

$(BIN_DIR)/$(BIN): $(OBJ)
	@mkdir -p $(dir $@)
	@echo "(LD) $@"
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_DIR)/$(VNC_BIN): $(VNC_OBJ)
	@mkdir -p $(dir $@)
	@echo "(LD) $@"
	@$(CC) $(LDFLAGS) $^ $(VNC_LDLIBS) -o $@

$(BUILD_DIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	@echo "(CXX) $@"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -c -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "(CXX) $@"
	@$(CC) $(VNC_CPPFLAGS) $(CFLAGS) $< -c -o $@

uninstall:
	@rm -f $(PREFIX)/bin/srwatchdogd $(PREFIX)/bin/$(BIN)
	@rm -rf $(PREFIX)/lib/libsera* $(PKG_DIR) /etc/cumulocity-agent.conf $(DATAPATH)/cumulocity-agent.conf
	@rm -f /lib/systemd/system/cumulocity-agent.service

clean:
	@rm -rf $(BUILD_DIR)/* $(BIN_DIR)/$(BIN) $(BIN_DIR)/$(VNC_BIN)

clean_all:
	@rm -rf $(BUILD_DIR)/* $(BIN_DIR)/* $(LIB_DIR)/*

-include $(OBJ:.o=.d)