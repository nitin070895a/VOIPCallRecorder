#line 1 "Main.x"
#import <UIKit/UIKit.h>
#import "Classes/Helper.h"
#import "Classes/AudioRecorder.h"

@interface WACallViewController : UIViewController
@end


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class WACallViewController; 
static void (*_logos_orig$_ungrouped$WACallViewController$viewDidLoad)(_LOGOS_SELF_TYPE_NORMAL WACallViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$WACallViewController$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL WACallViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$WACallViewController$viewDidDispose)(_LOGOS_SELF_TYPE_NORMAL WACallViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$WACallViewController$viewDidDispose(_LOGOS_SELF_TYPE_NORMAL WACallViewController* _LOGOS_SELF_CONST, SEL); 

#line 8 "Main.x"


AudioRecorder* recorder;

static void _logos_method$_ungrouped$WACallViewController$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL WACallViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {

    _logos_orig$_ungrouped$WACallViewController$viewDidLoad(self, _cmd);
    
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

static void _logos_method$_ungrouped$WACallViewController$viewDidDispose(_LOGOS_SELF_TYPE_NORMAL WACallViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    [Helper addRectange: 200 color: nil view: self.view];
    [recorder stop];
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$WACallViewController = objc_getClass("WACallViewController"); { MSHookMessageEx(_logos_class$_ungrouped$WACallViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$WACallViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$WACallViewController$viewDidLoad);}{ MSHookMessageEx(_logos_class$_ungrouped$WACallViewController, @selector(viewDidDispose), (IMP)&_logos_method$_ungrouped$WACallViewController$viewDidDispose, (IMP*)&_logos_orig$_ungrouped$WACallViewController$viewDidDispose);}} }
#line 38 "Main.x"
