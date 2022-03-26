TARGET = iphone:clang
INSTALL_TARGET_PROCESSES = SpringBoard
export ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

THEOS_DEVICE_IP=localhost
THEOS_DEVICE_PORT=2222

TWEAK_NAME = VOIPCallRecorder

VOIPCallRecorder_FILES = Classes/AudioRecorder.m Classes/Helper.m  Main.x
VOIPCallRecorder_CFLAGS = -fobjc-arc -O3
VOIPCallRecorder_FRAMEWORKS = Foundation UIKit CoreTelephony AVFoundation CoreAudio AudioToolbox
#EXTRA_FRAMEWORKS = AudioToolbox.framework AudioUnit.framework CoreAudio.framework CoreAudioTypes.framework
#VOIPCallRecorder_PRIVATE_FRAMEWORKS = AudioToolbox AudioUnit CoreAudioTypes

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 mediaserverd"
	
