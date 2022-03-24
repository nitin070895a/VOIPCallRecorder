#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"

%hook SBStatusBarManager

- (void) handleStatusBarTapWithEvent: (id) arg1 {

    [Helper showAlert: @"Haha" message: @"You just clicked the status bar"];

}

%end
