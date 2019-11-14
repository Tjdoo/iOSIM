//
//  RecordView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "RecordView.h"
#import "VoicePlayView.h"
#import "VoiceStateView.h"
#import "VoiceButton.h"
#import "VoiceView.h"
#import "Recorder.h"
#import "FileManager.h"
#import "UIView+Layout.h"


@interface RecordView () <RecordPTC>

@property (nonatomic, weak) VoiceStateView * stateView;
@property (nonatomic, weak) VoiceButton * recordButton;  // 录音按钮
@property (nonatomic, weak) VoicePlayView * playView;    // 播放界面

@end


@implementation RecordView

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
    [self recordButton];
}


#pragma mark - Touch
/**
  *  @brief   开始录音
  */
- (void)__startRecord:(VoiceButton *)btn
{
    // 设置状态：隐藏小圆点和三个标签
    [(VoiceView *)self.superview.superview setState:VoiceState_Record];
    
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        [Recorder sharedInstance].delegate = self;
        [[Recorder sharedInstance] beginRecordWithStoreFilePath:[FileManager filePath]];
    }
    else {
        [[Recorder sharedInstance] endRecord];
        [self.stateView endRecord];
        self.stateView.soundState = SoundState_ClickRecord;
        self.playView = nil;
        [self playView];
    }
}


#pragma mark - RecorderPTC
/**
  *  @brief  准备录音
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
    self.stateView.soundState = SoundState_ClickRecord;
    NSLog(@"录音失败：%@", failMsg);
}


#pragma mark - GET

- (VoicePlayView *)playView
{
    if (_playView == nil) {
        VoicePlayView * view = [[VoicePlayView alloc] initWithFrame:self.bounds];
        [self addSubview:view];
        _playView = view;
    }
    return _playView;
}

- (VoiceStateView *)stateView
{
    if (_stateView == nil) {
        VoiceStateView * view = [[VoiceStateView alloc] initWithFrame:CGRectMake(0, 10, self.width, 50)];
        view.soundState = SoundState_ClickRecord;
        [self addSubview:view];
        _stateView = view;
    }
    return _stateView;
}

- (VoiceButton *)recordButton
{
    if (_recordButton == nil) {
        VoiceButton * button = [VoiceButton buttonWithFrame:CGRectMake(0, self.stateView.bottom, 0, 0)
                                  normalBackgroundImageName:@"aio_record_being_button"
                                selectedBackgroundImageName:@"aio_record_being_button"
                                            normalImageName:@"aio_record_start_nor"
                                          selectedImageName:@"aio_record_stop_nor"
                                               isMicrophone:YES];
        [button addTarget:self action:@selector(__startRecord:) forControlEvents:UIControlEventTouchUpInside];
        button.centerX = self.width / 2.0;
        [self addSubview:button];
        _recordButton = button;
    }
    return _recordButton;
}

@end
