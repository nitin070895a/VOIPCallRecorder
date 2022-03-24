#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"

%hook CallManager

-(int)startCallWith:(id)with withVideo:(BOOL)video
{
    [Helper showAlert: @"Initiating Call" message: @"You are calling..."];
    return %orig;
}

%end
