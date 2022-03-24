#import <UIKit/UIKit.h>
#import "Classes/Helper.h"
#import "Classes/AudioRecorder.h"

@interface WACallViewController : UIViewController
@end

%hook WACallViewController

AudioRecorder* recorder;

-(void)viewDidLoad {

    %orig();
    
    [Helper addRectange: 100 color: nil view: self.view];
    
    recorder = [AudioRecorder alloc];
    [recorder prepare];
    [recorder record];
    
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    [callCenter setCallEventHandler:^(CTCall *call) {
        if ([[call callState] isEqual:CTCallStateConnected]) {
            [recorder record];
        } else if ([[call callState] isEqual:CTCallStateDisconnected]) {
            [recorder stop];
        }
    }];
}

- (void) viewDidDispose {
    [Helper addRectange: 200 color: nil view: self.view];
    [recorder stop];
}

%end
