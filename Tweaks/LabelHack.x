#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"

@interface UIInterface : UILabel
@end

%hook UILabel

-(void)setText:(id)arg1 {
    
    %orig(@"Hacked");
}

%end
