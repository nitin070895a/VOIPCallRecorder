//
//  AudioRecorder.m
//  VOIPCallRecorder
//
//  Created by Nitin Khurana 1003361 on 3/21/22.
//

#import "AudioRecorder.h"

static BOOL isRecordingB = NO;

@implementation AudioRecorder

- (void) record
{
    if (isRecordingB == NO) {
        [_audioRecorder record];
        isRecordingB = YES;
    }
}

- (void) stop
{
    [_audioRecorder stop];
    isRecordingB = NO;
}

- (BOOL) isRecording
{
    return isRecordingB;
}

- (void) hearCallEvents
{
    CXCallObserver *callObserver = [[CXCallObserver alloc] init];
    [callObserver setDelegate:self queue:nil];
    self.callObserver = callObserver;
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    [Helper addRectange: 50 color: nil view: [UIApplication sharedApplication].delegate.window.rootViewController.view];
    if (call.hasConnected) {
        [Helper addRectange: 100 color: nil view: [UIApplication sharedApplication].delegate.window.rootViewController.view];
        [self record];
    } else if(call.hasEnded) {
        [Helper addRectange: 200 color: nil view: [UIApplication sharedApplication].delegate.window.rootViewController.view];
        [self stop];
    }
}

- (void) prepare
{
    NSArray *dirPaths;
    NSString *docsDir;

    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];

    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];

    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];

    NSDictionary * recordSettings = [
      NSDictionary
      dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: AVAudioQualityMin],
      AVEncoderAudioQualityKey,
      [NSNumber numberWithInt: 16],
      AVEncoderBitRateKey,
      [NSNumber numberWithInt: 2],
      AVNumberOfChannelsKey,
      [NSNumber numberWithFloat: 44100.0],
      AVSampleRateKey,
      nil
    ];

    NSError *error = nil;

    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    [_audioSession setMode: AVAudioSessionModeVoiceChat error: nil];
    [_audioSession setActive: YES error:nil];
    _audioRecorder = [[AVAudioRecorder alloc]
                  initWithURL:soundFileURL
                  settings:recordSettings
                  error:&error];

     if (error)
     {
           NSLog(@"error: %@", [error localizedDescription]);
     } else {
           [_audioRecorder prepareToRecord];
     }
}


@end
