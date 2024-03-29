//
//  Helper.m
//  VOIPCallRecorder
//
//  Created by Nitin Khurana 1003361 on 3/20/22.
//

#import "Helper.h"

@implementation Helper

+ (void) showAlert:(NSString*)title message: (NSString*) message
{
 
//    UIAlertView *lookWhatWorks = [[UIAlertView alloc] initWithTitle:title
//        message:message
//        delegate:self
//        cancelButtonTitle:@"OK"
//        otherButtonTitles:nil];
//    [lookWhatWorks show];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleAlert
    ];

    UIAlertAction* defaultAction = [UIAlertAction
        actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {}
    ];

    [alert addAction:defaultAction];
       
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];

}

+ (void) addRectange: (int) size color: (nullable UIColor *) color view:(nullable UIView *) view;
{
    UIVisualEffectView *rectangle = [[UIVisualEffectView alloc] initWithFrame: CGRectMake(0, 0, size, size)];
    if (color == nil)
        [rectangle setBackgroundColor: RED];
    else
        [rectangle setBackgroundColor: color];
    
    if (view == nil) {
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController.view addSubview:rectangle];

    }
    else
        [view addSubview:rectangle];
}

+ (void) changeStatusBarColor: (nullable UIColor*) color
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if (color == nil)
        statusBar.backgroundColor = RED;
    else
        statusBar.backgroundColor = color;
}

@end
