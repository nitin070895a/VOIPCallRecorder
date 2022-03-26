//
//  AudioRecorder.h
//  VOIPCallRecorder
//
//  Created by Nitin Khurana  on 3/21/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CallKit/CXCallObserver.h>
#import <CallKit/CXCall.h>
#import "Helper.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecorder : NSObject<CXCallObserverDelegate>

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioSession *audioSession;
@property (nonatomic, strong) CXCallObserver *callObserver;

- (void) prepare;
- (void) record;
- (void) stop;
- (BOOL) isRecording;
- (void) hearCallEvents;

@end

NS_ASSUME_NONNULL_END
