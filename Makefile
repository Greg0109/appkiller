TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppKiller

AppKiller_FILES = Tweak.x
AppKiller_LIBRARIES	= activator
AppKiller_FRAMEWORKS = BackBoardServices
AppKiller_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += appkiller
include $(THEOS_MAKE_PATH)/aggregate.mk
