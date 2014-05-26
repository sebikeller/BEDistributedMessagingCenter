TARGET := iphone:clang
SDKVERSION = 7.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
ARCHS = armv7 armv7s arm64
ADDITIONAL_OBJCFLAGS = -fobjc-arc
TARGET_CODESIGN_FLAGS = -S 
#SCHEMA=debug

include theos/makefiles/common.mk

LIBRARY_NAME = libbedistributedmessagingcenter
libbedistributedmessagingcenter_FILES = BEDistributedMessagingCenter.m
libbedistributedmessagingcenter_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/library.mk

prepare::
	$(ECHO_NOTHING)cp -a "$(THEOS_OBJ_DIR_NAME)/$(LIBRARY_NAME)$(TARGET_LIB_EXT)" "$(THEOS)/lib/"$(ECHO_END);

internal-stage::
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)/usr/include"$(ECHO_END)
	$(ECHO_NOTHING)cp -a BEDistributedMessagingCenter.h "$(THEOS_STAGING_DIR)/usr/include"$(ECHO_END)