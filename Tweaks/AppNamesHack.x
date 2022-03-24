#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"


%hook SBApplication

-(id)displayName {

    return @"Zoom";
}

%end
