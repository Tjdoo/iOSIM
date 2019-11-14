//
//  AudioPlayer.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "AudioPlayer.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface AudioPlayer ()
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;  // 音频播放器
@end


@implementation AudioPlayer

IMP_SINGLETON

- (AVAudioPlayer *)playAudioWith:(NSString *)audioFilePath
{
    [self stopPlay];
    
    // 设置为扬声器播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL * url = [NSURL URLWithString:audioFilePath];
    if (!url) {
        url = [[NSBundle mainBundle] URLForResource:audioFilePath.lastPathComponent withExtension:nil];
    }
    
    NSError * error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"播放器创建失败");
        return nil;
    }
    
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
    return self.audioPlayer;
}

- (void)pausePlay
{
    if (self.audioPlayer) {
        [self.audioPlayer pause];
    }
}

- (void)resumePlay
{
    if (self.audioPlayer) {
        [self.audioPlayer play];
    }
}

- (void)stopPlay
{
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}


#pragma mark - GET

- (float)progress
{
    // 当前时间 / 时长
    return self.audioPlayer.currentTime / self.audioPlayer.duration;
}

@end
