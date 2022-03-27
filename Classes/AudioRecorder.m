//
//  AudioRecorder.m
//  VOIPCallRecorder
//
//  Created by Nitin Khurana 1003361 on 3/21/22.
//

#import "AudioRecorder.h"

static BOOL isRec = NO;

@implementation AudioRecorder

- (void) record
{
    if (isRec == NO)
    {
        [_audioRecorder record];
        NSLog(@"NitinLog Recording started");
        isRec = YES;
    }
}

- (void) stop
{
    [_audioRecorder stop];
    NSLog(@"NitinLog Recording stopped");
    isRec = NO;
}

- (BOOL) isRecording
{
    return isRec;
}

- (void) hearCallEvents
{
    CXCallObserver *callObserver = [[CXCallObserver alloc] init];
    [callObserver setDelegate:self queue:nil];
    self.callObserver = callObserver;
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    NSLog(@"NitinLog OnStatusChanged %@", call);
    
    if (call.hasEnded == YES) {
        NSLog(@"NitinLog Disconnected");
        //[Helper addRectange: 100 color: RED view: nil];
        [self stop];
    }
    if (call.isOutgoing == YES && call.hasConnected == NO) {
        NSLog(@"NitinLog Dialing");
    }
    if (call.isOutgoing == NO && call.hasConnected == NO && call.hasEnded == NO) {
        NSLog(@"NitinLog Incoming");
    }
    if (call.hasConnected == YES && call.hasEnded == NO) {
        NSLog(@"NitinLog Connected");
        //[Helper addRectange: 100 color: GREEN view: nil];
        [self prepare];
        [self record];
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
           NSLog(@"NitinLog error: %@", [error localizedDescription]);
     } else {
         [_audioRecorder prepareToRecord];
         NSLog(@"NitinLog Prepared for recording");
     }
}

@end
