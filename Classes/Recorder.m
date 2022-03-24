//
//  Recorder.m
//  VOIPCallRecorder
//
//  Created by Nitin Khurana 1003361 on 3/20/22.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <libkern/OSAtomic.h>

//CoreTelephony.framework
CFStringRef const kCTCallStatusChangeNotification;
CFStringRef const kCTCallStatus;
id CTTelephonyCenterGetDefault();
void CTTelephonyCenterAddObserver(id ct, void* observer, CFNotificationCallback callBack, CFStringRef name, void *object, CFNotificationSuspensionBehavior sb);
int CTGetCurrentCallCount();
enum
{
    kCTCallStatusActive = 1,
    kCTCallStatusHeld = 2,
    kCTCallStatusOutgoing = 3,
    kCTCallStatusIncoming = 4,
    kCTCallStatusHanged = 5
};

NSString* kMicFilePath = @"/var/mobile/Media/DCIM/mic.caf";
NSString* kSpeakerFilePath = @"/var/mobile/Media/DCIM/speaker.caf";
NSString* kResultFilePath = @"/var/mobile/Media/DCIM/result.m4a";

OSSpinLock phoneCallIsActiveLock = 0;
OSSpinLock speakerLock = 0;
OSSpinLock micLock = 0;

ExtAudioFileRef micFile = NULL;
ExtAudioFileRef speakerFile = NULL;

BOOL phoneCallIsActive = NO;

void Convert()
{
    //File URLs
    CFURLRef micUrl = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)kMicFilePath, kCFURLPOSIXPathStyle, false);
    CFURLRef speakerUrl = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)kSpeakerFilePath, kCFURLPOSIXPathStyle, false);
    CFURLRef mixUrl = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)kResultFilePath, kCFURLPOSIXPathStyle, false);

    ExtAudioFileRef micFile = NULL;
    ExtAudioFileRef speakerFile = NULL;
    ExtAudioFileRef mixFile = NULL;

    //Opening input files (speaker and mic)
    ExtAudioFileOpenURL(micUrl, &micFile);
    ExtAudioFileOpenURL(speakerUrl, &speakerFile);

    //Reading input file audio format (mono LPCM)
    AudioStreamBasicDescription inputFormat, outputFormat;
    UInt32 descSize = sizeof(inputFormat);
    ExtAudioFileGetProperty(micFile, kExtAudioFileProperty_FileDataFormat, &descSize, &inputFormat);
    int sampleSize = inputFormat.mBytesPerFrame;

    //Filling input stream format for output file (stereo LPCM)
    FillOutASBDForLPCM(inputFormat, inputFormat.mSampleRate, 2, inputFormat.mBitsPerChannel, inputFormat.mBitsPerChannel, true, false);

    //Filling output file audio format (AAC)
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mFormatID = kAudioFormatMPEG4AAC;
    outputFormat.mSampleRate = 8000;
    outputFormat.mFormatFlags = kMPEG4Object_AAC_Main;
    outputFormat.mChannelsPerFrame = 2;

    //Opening output file
    ExtAudioFileCreateWithURL(mixUrl, kAudioFileM4AType, &outputFormat, NULL, kAudioFileFlags_EraseFile, &mixFile);
    ExtAudioFileSetProperty(mixFile, kExtAudioFileProperty_ClientDataFormat, sizeof(inputFormat), &inputFormat);

    //Freeing URLs
    CFRelease(micUrl);
    CFRelease(speakerUrl);
    CFRelease(mixUrl);

    //Setting up audio buffers
    int bufferSizeInSamples = 64 * 1024;

    AudioBufferList micBuffer;
    micBuffer.mNumberBuffers = 1;
    micBuffer.mBuffers[0].mNumberChannels = 1;
    micBuffer.mBuffers[0].mDataByteSize = sampleSize * bufferSizeInSamples;
    micBuffer.mBuffers[0].mData = malloc(micBuffer.mBuffers[0].mDataByteSize);

    AudioBufferList speakerBuffer;
    speakerBuffer.mNumberBuffers = 1;
    speakerBuffer.mBuffers[0].mNumberChannels = 1;
    speakerBuffer.mBuffers[0].mDataByteSize = sampleSize * bufferSizeInSamples;
    speakerBuffer.mBuffers[0].mData = malloc(speakerBuffer.mBuffers[0].mDataByteSize);

    AudioBufferList mixBuffer;
    mixBuffer.mNumberBuffers = 1;
    mixBuffer.mBuffers[0].mNumberChannels = 2;
    mixBuffer.mBuffers[0].mDataByteSize = sampleSize * bufferSizeInSamples * 2;
    mixBuffer.mBuffers[0].mData = malloc(mixBuffer.mBuffers[0].mDataByteSize);

    //Converting
    while (true)
    {
        //Reading data from input files
        UInt32 framesToRead = bufferSizeInSamples;
        ExtAudioFileRead(micFile, &framesToRead, &micBuffer);
        ExtAudioFileRead(speakerFile, &framesToRead, &speakerBuffer);
        if (framesToRead == 0)
        {
            break;
        }

        //Building interleaved stereo buffer - left channel is mic, right - speaker
        for (int i = 0; i < framesToRead; i++)
        {
            memcpy((char*)mixBuffer.mBuffers[0].mData + i * sampleSize * 2, (char*)micBuffer.mBuffers[0].mData + i * sampleSize, sampleSize);
            memcpy((char*)mixBuffer.mBuffers[0].mData + i * sampleSize * 2 + sampleSize, (char*)speakerBuffer.mBuffers[0].mData + i * sampleSize, sampleSize);
        }

        //Writing to output file - LPCM will be converted to AAC
        ExtAudioFileWrite(mixFile, framesToRead, &mixBuffer);
    }

    //Closing files
    ExtAudioFileDispose(micFile);
    ExtAudioFileDispose(speakerFile);
    ExtAudioFileDispose(mixFile);

    //Freeing audio buffers
    free(micBuffer.mBuffers[0].mData);
    free(speakerBuffer.mBuffers[0].mData);
    free(mixBuffer.mBuffers[0].mData);
}

void Cleanup()
{
    [[NSFileManager defaultManager] removeItemAtPath:kMicFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:kSpeakerFilePath error:NULL];
}

void CoreTelephonyNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSDictionary* data = (__bridge NSDictionary*)userInfo;

    if ([(__bridge NSString*)name isEqualToString:(__bridge NSString*)kCTCallStatusChangeNotification])
    {
        int currentCallStatus = [data[(__bridge NSString*)kCTCallStatus] integerValue];

        if (currentCallStatus == kCTCallStatusActive)
        {
            OSSpinLockLock(&phoneCallIsActiveLock);
            phoneCallIsActive = YES;
            OSSpinLockUnlock(&phoneCallIsActiveLock);
        }
        else if (currentCallStatus == kCTCallStatusHanged)
        {
            if (CTGetCurrentCallCount() > 0)
            {
                return;
            }

            OSSpinLockLock(&phoneCallIsActiveLock);
            phoneCallIsActive = NO;
            OSSpinLockUnlock(&phoneCallIsActiveLock);

            //Closing mic file
            OSSpinLockLock(&micLock);
            if (micFile != NULL)
            {
                ExtAudioFileDispose(micFile);
            }
            micFile = NULL;
            OSSpinLockUnlock(&micLock);

            //Closing speaker file
            OSSpinLockLock(&speakerLock);
            if (speakerFile != NULL)
            {
                ExtAudioFileDispose(speakerFile);
            }
            speakerFile = NULL;
            OSSpinLockUnlock(&speakerLock);

            Convert();
            Cleanup();
        }
    }
}

OSStatus(*AudioUnitProcess_orig)(AudioUnit unit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, AudioBufferList *ioData);
OSStatus AudioUnitProcess_hook(AudioUnit unit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    OSSpinLockLock(&phoneCallIsActiveLock);
    if (phoneCallIsActive == NO)
    {
        OSSpinLockUnlock(&phoneCallIsActiveLock);
        return AudioUnitProcess_orig(unit, ioActionFlags, inTimeStamp, inNumberFrames, ioData);
    }
    OSSpinLockUnlock(&phoneCallIsActiveLock);

    ExtAudioFileRef* currentFile = NULL;
    OSSpinLock* currentLock = NULL;

    AudioComponentDescription unitDescription = {0};
    AudioComponentGetDescription(AudioComponentInstanceGetComponent(unit), &unitDescription);
    //'agcc', 'mbdp' - iPhone 4S, iPhone 5
    //'agc2', 'vrq2' - iPhone 5C, iPhone 5S
    if (unitDescription.componentSubType == 'agcc' || unitDescription.componentSubType == 'agc2')
    {
        currentFile = &micFile;
        currentLock = &micLock;
    }
    else if (unitDescription.componentSubType == 'mbdp' || unitDescription.componentSubType == 'vrq2')
    {
        currentFile = &speakerFile;
        currentLock = &speakerLock;
    }
    if (currentFile != NULL)
    {
        OSSpinLockLock(currentLock);

        //Opening file
        if (*currentFile == NULL)
        {
            //Obtaining input audio format
            AudioStreamBasicDescription desc;
            UInt32 descSize = sizeof(desc);
            AudioUnitGetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &desc, &descSize);

            //Opening audio file
            CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)((currentFile == &micFile) ? kMicFilePath : kSpeakerFilePath), kCFURLPOSIXPathStyle, false);
            ExtAudioFileRef audioFile = NULL;
            OSStatus result = ExtAudioFileCreateWithURL(url, kAudioFileCAFType, &desc, NULL, kAudioFileFlags_EraseFile, &audioFile);
            if (result != 0)
            {
                *currentFile = NULL;
            }
            else
            {
                *currentFile = audioFile;

                //Writing audio format
                ExtAudioFileSetProperty(*currentFile, kExtAudioFileProperty_ClientDataFormat, sizeof(desc), &desc);
            }
            CFRelease(url);
        }
        else
        {
            //Writing audio buffer
            ExtAudioFileWrite(*currentFile, inNumberFrames, ioData);
        }

        OSSpinLockUnlock(currentLock);
    }

    return AudioUnitProcess_orig(unit, ioActionFlags, inTimeStamp, inNumberFrames, ioData);
}

__attribute__((constructor))
static void initialize()
{
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, CoreTelephonyNotificationCallback, NULL, NULL, CFNotificationSuspensionBehaviorHold);

    //MSHookFunction(AudioUnitProcess, AudioUnitProcess_hook, &AudioUnitProcess_orig);
}

