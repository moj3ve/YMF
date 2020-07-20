ARCHS=arm64

DEBUG = 0
FINALPACKAGE = 1

TARGET = iphone::11.2:latest

INSTALL_TARGET_PROCESSES = Twitter Messenger Youtube Facebook Reddit Instagram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YMF

YMF_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += ymfprefs

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
