//
//  AudioRecorder.m
//  VOIPCallRecorder
//
//  Created by Nitin Khurana 1003361 on 3/21/22.
//

#import "AudioRecorder.h"

@implementation AudioRecorder

- (void) record
{
    [_audioRecorder record];
}

- (void) stop
{
    [_audioRecorder stop];
}

- (void) prepare
{
    NSArray *dirPaths;
    NSString *docsDir;

    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];

    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];

    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];

    NSDictionary *recordSettings = [NSDictionary
            dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:AVAudioQualityMin],
            AVEncoderAudioQualityKey,
            [NSNumber numberWithInt:16],
            AVEncoderBitRateKey,
            [NSNumber numberWithInt: 2],
            AVNumberOfChannelsKey,
            [NSNumber numberWithFloat:44100.0],
            AVSampleRateKey,
            nil];

    NSError *error = nil;

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
