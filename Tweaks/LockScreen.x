#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"


@interface SBLockScreenViewControllerBase : UIViewController
@end

%hook SBLockScreenViewControllerBase

- (void) viewDidLoad {

    %orig;

    [Helper addRectange: 200 color: nil view: self.view];
}
%end
