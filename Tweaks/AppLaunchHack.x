#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"

%hook UIApplicationDelegate

-(BOOL)application:(id)arg1 willFinishLaunchingWithOptions:(id)arg2 {

    [Helper showAlert: @"App Open" message: @"App is opened"];

    return %orig;
}

%end
