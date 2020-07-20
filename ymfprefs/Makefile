include $(THEOS)/makefiles/common.mk
ARCHS=arm64

BUNDLE_NAME = ymfprefs

ymfprefs_FILES = ymfRootListController.m
ymfprefs_INSTALL_PATH = /Library/PreferenceBundles
ymfprefs_FRAMEWORKS = UIKit
ymfprefs_PRIVATE_FRAMEWORKS = Preferences
ymfprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ymfprefs.plist$(ECHO_END)
