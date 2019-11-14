//
//  Recorder.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "Recorder.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#define ALPHA   0.02f    // 音频振幅调解相对值（越小振幅就越高）

@interface Recorder ()
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;
@end


@implementation Recorder

IMP_SINGLETON

- (BOOL)__createAudioRecorder
{
    // ①、设置录音会话
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // ②、确定录音存放的位置
    NSURL * fileURL = [NSURL URLWithString:self.recordFilePath];
    
    // ③、设置录音参数
    NSMutableDictionary * settings = [NSMutableDictionary dictionaryWithCapacity:4];
    // 设置编码格式
    [settings setValue:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    // 采样率
    [settings setValue:@(11025.0) forKey:AVSampleRateKey];
    // 通道数
    [settings setValue:@(1) forKey:AVNumberOfChannelsKey];
    // 音频质量
    [settings setValue:@(AVAudioQualityMin) forKey:AVEncoderAudioQualityKey];
    
    // ④、创建录音对象
    NSError * error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:settings error:&error];
    if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    _audioRecorder.meteringEnabled = YES;
    
    return YES;
}

/**
  *  @brief   开始录音
  */
- (void)beginRecordWithStoreFilePath:(NSString *)recordFilePath
{
    _recording = YES;
    _recordFilePath = recordFilePath;
    
    // 录音准备中
    if (self.delegate && [self.delegate respondsToSelector:@selector(recorderInPreparation)]) {
        [self.delegate recorderInPreparation];
    }
    
    // 创建录音器失败
    if (![self __createAudioRecorder]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(recorderRecordFail:)]) {
            [self.delegate recorderRecordFail:@"录音器创建失败"];
        }
        return;
    }
    
    [self __checkMicrophonePermissions:^(BOOL available) {
        if (available) {
            [self __startRecording];
        }
        else {
            [self __showAlert];
        }
    }];
}

/**
  *  @brief   开始录音
  */
- (void)__startRecording
{
    if (!_recording) {
        return;
    }
    
    if (![self.audioRecorder prepareToRecord]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(recorderRecordFail:)]) {
            [self.delegate recorderRecordFail:@"录音器准备录制失败"];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recorderRecording)]) {
        [self.delegate recorderRecording];
    }
    
    // 开始录音
    [self.audioRecorder record];
}

/**
  *  @brief   停止录音
  */
- (void)endRecord
{
    _recording = NO;
    if (self.audioRecorder) {
        [self.audioRecorder stop];
    }
}

/**
  *  @brief   暂停录音
  */
- (void)pauseRecord
{
    if (self.audioRecorder) {
        [self.audioRecorder pause];
    }
}

/**
  *  @brief   删除录音
  */
- (void)deleteRecord
{
    _recording = NO;
    if (self.audioRecorder) {
        [self.audioRecorder stop];
        [self.audioRecorder deleteRecording];
    }
}

/**
  *  @brief   分贝值。限制在 0.05 ~ 1.0 之间
  */
- (float)levels
{
    [self.audioRecorder updateMeters];
    
    double aveChannel = pow(10, (ALPHA * [self.audioRecorder averagePowerForChannel:0]));
    
    return MIN(1.0, MAX(aveChannel, 0.05));
}


#pragma mark - Tool
/**
  *  @brief   检查麦克风权限
  */
- (void)__checkMicrophonePermissions:(void (^)(BOOL available))block
{
    AVAudioSession * session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(granted);
                }
            });
        }];
    }
}

/**
  *  @brief   录音权限提示
  */
- (void)__showAlert
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"无法录音"
                                                            message:@"请在“设置-隐私-麦克风”中允许访问麦克风。"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC
                                                                                 animated:YES
                                                                               completion:nil];
}

@end
