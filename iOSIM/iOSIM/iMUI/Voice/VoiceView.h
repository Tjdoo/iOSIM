//
//  VoiceView.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VoiceState) {
    VoiceState_Default = 0, // 默认状态
    VoiceState_Record,      // 录音
    VoiceState_Play,        // 播放
};

/**  仿 QQ 的语音输入界面  **/
@interface VoiceView : UIView

@property (nonatomic, assign) VoiceState state;

@end
