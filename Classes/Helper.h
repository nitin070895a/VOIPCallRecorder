//
//  Helper.h
//  VOIPCallRecorder
//
//  Created by Nitin Khurana on 3/20/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RED [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define GREEN [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]
#define BLUE [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@interface Helper : NSObject

+ (void) showAlert:(NSString*)title message: (NSString*) message;
+ (void) addRectange: (int) size color: (nullable UIColor *) color view:(UIView *) view;
+ (void) changeStatusBarColor: (nullable UIColor*) color;

@end

NS_ASSUME_NONNULL_END

