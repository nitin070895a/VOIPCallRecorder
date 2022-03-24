TARGET = iphone:clang
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS = armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk

THEOS_DEVICE_IP=localhost
THEOS_DEVICE_PORT=2222

TWEAK_NAME = VOIPCallRecorder

VOIPCallRecorder_FILES = Classes/Helper.m Classes/AudioRecorder.m Main.x
VOIPCallRecorder_CFLAGS = -fobjc-arc -O3
VOIPCallRecorder_FRAMEWORKS = Foundation UIKit CoreTelephony AVFoundation
EXTRA_FRAMEWORKS = AudioToolbox.framework AudioUnit.framework CoreAudio.framework

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
	
