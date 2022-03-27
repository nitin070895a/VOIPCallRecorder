#import <UIKit/UIKit.h>
#import "Classes/Helper.h"
#import "Classes/AudioRecorder.h"
#import <CallKit/CXCallObserver.h>
#import <CallKit/CXCall.h>

@interface WACallViewController : UIViewController
@end

%hook WACallViewController

AudioRecorder* recorder;

-(void)viewDidLoad {
            
    recorder = [AudioRecorder alloc];
    if ([recorder isRecording] == YES) {
        %orig();
        return;
    }
    
    
    %orig();
        
    //[recorder prepare];
    [recorder hearCallEvents];
    //[Helper addRectange: 50 color: nil view: self.view];
}


//- (void) viewDidDisappear {
    //[Helper addRectange: 200 color: nil view: self.view];
    //[recorder stop];
    //%orig();
//}

%end
