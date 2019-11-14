//
//  VoiceStateView.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SoundState) {
    SoundState_Default = 0,      // 按住说话
    SoundState_ClickRecord,      // 点击录音
    SoundState_TouchChangeVoice, // 按住变声
    SoundState_Listen,           // 试听
    SoundState_Cancel,           // 取消
    SoundState_Send,             // 发送
    SoundState_Prepare,          // 准备中
    SoundState_Recording,        // 录音中
    SoundState_PreparePlay,      // 准备播放
    SoundState_Play,             // 播放
};


/**  录音状态视图  **/
@interface VoiceStateView : UIView

@property (nonatomic, assign) SoundState soundState;  // 录音状态
@property (nonatomic, copy) void(^ playProgressBlock)(CGFloat progress);

/**
  *  @brief   开始录音
  */
- (void)beginRecord;
/**
  *  @brief   结束录音
  */
- (void)endRecord;

@end
