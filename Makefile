GO_EASY_ON_ME = 1

TARGET = :clang
ARCHS = armv7 armv7s arm64
THEOS_PACKAGE_DIR_NAME = deb

include theos/makefiles/common.mk

TWEAK_NAME = PrivateSMS7
PrivateSMS7_FILES = Tweak.xm
PrivateSMS7_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete
after-install::
	install.exec "killall -9 backboardd"
