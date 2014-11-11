ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = PSMS7Settings
PSMS7Settings_FILES = PSMS7Settings.mm
PSMS7Settings_INSTALL_PATH = /Library/PreferenceBundles
PSMS7Settings_FRAMEWORKS = UIKit
PSMS7Settings_PRIVATE_FRAMEWORKS = Preferences
PSMS7Settings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PSMS7Settings.plist$(ECHO_END)
