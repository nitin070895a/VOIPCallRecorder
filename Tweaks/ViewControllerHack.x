#import <UIKit/UIKit.h>
#import "../Classes/Helper.h"

%hook UIViewController

-(void)viewDidLoad {

    %orig();
    [Helper addRectange: 100 color: nil view: self.view];
}

-(BOOL)presentViewController:(id)arg1 inOverlayWithConfiguration:(id)arg2 {

    [Helper changeStatusBarColor :nil];
    return false;
}

%end
