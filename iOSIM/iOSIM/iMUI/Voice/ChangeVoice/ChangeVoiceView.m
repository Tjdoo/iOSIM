//
//  ChangeVoiceView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "ChangeVoiceView.h"
#import "VoiceStateView.h"
#import "VoiceButton.h"
#import "Recorder.h"
#import "VoiceView.h"
#import "ChangeVoicePlayView.h"
#import "FileManager.h"
#import "UIView+Layout.h"


@interface ChangeVoiceView () <RecordPTC>

@property (nonatomic, weak) VoiceStateView * stateView;
@property (nonatomic, weak) UIButton * changeVoiceButton;  // 录音按钮
@property (nonatomic, weak) ChangeVoicePlayView * playView; // 播放变声

@end


@implementation ChangeVoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self __setupSubviews];
    }
    return self;
}

- (void)__setupSubviews
{
    [self stateView];
    [self changeVoiceButton];
}


#pragma mark - Touch
/**
  *  @brief   开始录音
  */
- (void)__startRecord:(UIButton *)btn
{
    [Recorder sharedInstance].delegate = self;
    
    // 设置状态：隐藏小圆点和三个标签
    [(VoiceView *)self.superview.superview setState:VoiceState_Record];
    
    [self __animationMicroBtn:^(BOOL finished) {
        [[Recorder sharedInstance] beginRecordWithStoreFilePath:[FileManager filePath]];
    }];
}

/**
  *  @brief   结束录音
  */
- (void)__endRecord:(UIButton *)btn
{
    NSTimeInterval ti = 0;
    if (![Recorder sharedInstance].isRecording) {
        ti = 0.3;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ti * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 切换状态为按住变声
        self.stateView.soundState = SoundState_TouchChangeVoice;
        // 停止录音
        [[Recorder sharedInstance] endRecord];
        [self.stateView endRecord];
        
        // 设置状态：显示小圆点和三个标签
        [(VoiceView *)self.superview.superview setState:VoiceState_Default];
        
        if (ti == 0) {
            self.playView = nil;
            [self playView];
        }
        else {
            NSLog(@"录音时间太短");
        }
    });
}


#pragma mark - Animation
/**
  *  @brief   麦克风按钮动画
  */
- (void)__animationMicroBtn:(void(^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.10 animations:^{
        
        self.changeVoiceButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.05 animations:^{
            
            self.changeVoiceButton.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }];
}

#pragma mark - RecorderPTC
/**
  *  @brief   录音准备中
  */
- (void)recorderInPreparation
{
    self.stateView.soundState = SoundState_Prepare;
}

/**
  *  @brief   正在录音
  */
- (void)recorderRecording
{
    self.stateView.soundState = SoundState_Recording;
    // 开始录音
    [self.stateView beginRecord];
}

/**
  *  @brief   录音失败
  */
- (void)recorderRecordFail:(NSString *)failMsg
{
    self.stateView.soundState = SoundState_TouchChangeVoice;
    NSLog(@"录音失败：%@", failMsg);
}


#pragma mark - GET

- (ChangeVoicePlayView *)playView
{
    if (_playView == nil) {
        ChangeVoicePlayView * view = [[ChangeVoicePlayView alloc] initWithFrame:self.bounds];
        [(VoiceView *)self.superview.superview setState:VoiceState_Play];
        WEAK_SELF;
        [UIView transitionWithView:self
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            STRONG_SELF;
                            [strongSelf addSubview:view];
                        } completion:nil];
        self.playView = view;
    }
    return _playView;
}

- (VoiceStateView *)stateView
{
    if (_stateView == nil) {
        VoiceStateView * view = [[VoiceStateView alloc] initWithFrame:CGRectMake(0, 10, self.width, 50)];
        view.soundState = SoundState_TouchChangeVoice;
        [self addSubview:view];
        self.stateView = view;
    }
    return _stateView;
}

- (UIButton *)changeVoiceButton
{
    if (_changeVoiceButton == nil) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"aio_voiceChange_icon"] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, self.stateView.bottom, button.currentImage.size.width, button.currentImage.size.height);
        // 手指按下
        [button addTarget:self action:@selector(__startRecord:) forControlEvents:UIControlEventTouchDown];
        // 松开手指
        [button addTarget:self action:@selector(__endRecord:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(__endRecord:) forControlEvents:UIControlEventTouchUpOutside];
        
        button.centerX = self.width / 2.0;
        [self addSubview:button];
        self.changeVoiceButton = button;
    }
    return _changeVoiceButton;
}

@end
