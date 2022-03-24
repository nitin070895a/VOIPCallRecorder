//
//  AudioRecorder.h
//  VOIPCallRecorder
//
//  Created by Nitin Khurana  on 3/21/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecorder : NSObject

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

- (void) prepare;
- (void) record;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
