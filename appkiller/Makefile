TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = AppKiller

AppKiller_FILES = main.m
AppKiller_CFLAGS = -fobjc-arc
AppKiller_CODESIGN_FLAGS = -Sentitlements.plist
AppKiller_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
