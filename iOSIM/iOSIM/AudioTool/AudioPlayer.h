//
//  AudioPlayer.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import "Macros.h"

@class AVAudioPlayer;

/**   语音播放器   **/
@interface AudioPlayer : NSObject

@property (nonatomic, assign, readonly) float progress;  // 播放进度

DEF_SINGLETON

/**
  *  @brief   播放音频
  *  @param   audioFilePath   音频的本地路径
  */
- (AVAudioPlayer *)playAudioWith:(NSString *)audioFilePath;

/**
  *  @brief   暂停播放
  */
- (void)pausePlay;
/**
  *  @brief   恢复播放
  */
- (void)resumePlay;
/**
  *  @brief   停止播放
  */
- (void)stopPlay;

@end
