clear
make package
rm /opt/simject/VOIPCallRecorder.dylib
cp .theos/obj/iphone_simulator/debug/VOIPCallRecorder.dylib /opt/simject
cd /Users/nitinkhurana1003361/simject/bin
./resim
