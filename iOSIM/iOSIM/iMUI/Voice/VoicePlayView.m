//
//  VoicePlayView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "VoicePlayView.h"
#import "UIView+Layout.h"
#import "VoiceStateView.h"
#import "AudioPlayer.h"
#import "RecordModel.h"
#import "Recorder.h"
#import "VoiceView.h"


@interface VoicePlayView ()

@property (nonatomic, weak) VoiceStateView * stateView;
@property (nonatomic, weak) UIButton * playButton;    // 播放按钮
@property (nonatomic, weak) UIButton * cancelButton;  // 取消按钮
@property (nonatomic, weak) UIButton * sendButton;    // 发送按钮

@end


@implementation VoicePlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self __setupSubviews];
    }
    return self;
}

/**
  *  @brief   绘制圆环进度
  */
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIImage * img = [UIImage imageNamed:@"aio_voice_button_nor"];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextSetStrokeColorWithColor(ctx, UIColorFromRGBA(214, 219, 222, 1.0).CGColor);
    CGContextAddArc(ctx, self.centerX, self.stateView.bottom + img.size.width/2.0, img.size.width/2.0, 0, M_PI * 2, NO);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, kSelectTextColor.CGColor);
    CGFloat startAngle = -M_PI_2;
    CGFloat angle = self.progress * M_PI * 2;
    CGFloat endAngle = startAngle + angle;
    CGContextAddArc(ctx, self.centerX, self.stateView.bottom + img.size.width/2.0, img.size.width/2.0, startAngle, endAngle, NO);
    CGContextStrokePath(ctx);
}

- (void)__setupSubviews
{
    [self stateView];
    [self cancelButton];
    [self sendButton];
    [self playButton];
    
    [self __listenProgress];
}

/**
  *  @brief   监听环形进度条更新
  */
- (void)__listenProgress
{
    WEAK_SELF;
    self.stateView.playProgressBlock = ^(CGFloat progress) {
        STRONG_SELF;
        if (progress == 1) {
            progress = 0;
            [strongSelf stopPlay];
        }
        strongSelf.progress = progress;
        
        [strongSelf setNeedsDisplay];
        [strongSelf layoutIfNeeded];
    };
}


#pragma mark - Touch
/**
  *  @brief   播放
  */
- (void)playRecord
{
    self.playButton.selected = !self.playButton.selected;
    
    if (self.playButton.selected) {
        self.stateView.soundState = SoundState_Play;
        [[AudioPlayer sharedInstance] playAudioWith:[RecordModel sharedInstance].filePath];
    }
    else {
        [self stopPlay];
    }
}

- (void)stopPlay
{
    self.playButton.selected = NO;
    self.stateView.soundState = SoundState_PreparePlay;
    [[AudioPlayer sharedInstance] stopPlay];
    _progress = 0;
    
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

- (void)btnClicked:(UIButton *)button
{
    [self stopPlay];
    
    // 发送
    if (button == self.sendButton) {
        
    }
    // 取消发送并删除录音
    else {
        [[Recorder sharedInstance] deleteRecord];
    }
    
    [(VoiceView *)self.superview.superview.superview setState:VoiceState_Default];
    [self removeFromSuperview];
}


#pragma mark - GET

- (VoiceStateView *)stateView
{
    if (_stateView == nil) {
        VoiceStateView * view = [[VoiceStateView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        [self addSubview:view];
        view.soundState = SoundState_PreparePlay;
        _stateView = view;
    }
    return _stateView;
}

- (UIButton *)playButton
{
    if (_playButton == nil) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * img = [UIImage imageNamed:@"aio_voice_button_nor"];
        button.size = img.size;
        button.center = CGPointMake(self.centerX, self.stateView.bottom + img.size.width / 2.0);
        
        [button setImage:[UIImage imageNamed:@"aio_record_play_nor"]   forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"aio_record_play_press"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"aio_record_stop_nor"]   forState:UIControlStateSelected];
        [button addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        _playButton = button;
    }
    return _playButton;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        UIButton * button = [self buttonWithFrame:CGRectMake(0, self.height - 45, self.width/2.0, 45)
                                             text:@"取消"
                                        textColor:kSelectTextColor
                                             font:[UIFont systemFontOfSize:18]
                                normalBgImageName:@"aio_record_cancel_button"
                           highlightedBgImageName:@"aio_record_cancel_button_press"
                                              sel:@selector(btnClicked:)];
        [self addSubview:button];
        _cancelButton = button;
    }
    return _cancelButton;
}

- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        UIButton * button = [self buttonWithFrame:CGRectMake(self.width/2.0, self.height - 45, self.width/2.0, 45)
                                             text:@"发送"
                                        textColor:kSelectTextColor
                                             font:[UIFont systemFontOfSize:18]
                                normalBgImageName:@"aio_record_send_button"
                           highlightedBgImageName:@"aio_record_send_button_press"
                                              sel:@selector(btnClicked:)];
        [self addSubview:button];
        _sendButton = button;
    }
    return _sendButton;
}


#pragma mark - Tool
/**
  *  @brief   创建按钮对象并返回
  */
- (UIButton *)buttonWithFrame:(CGRect)frame
                         text:(NSString *)text
                    textColor:(UIColor *)textColor
                         font:(UIFont *)font
            normalBgImageName:(NSString *)normalBgImageName
       highlightedBgImageName:(NSString *)highlightedBgImageName
                          sel:(SEL)sel
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.titleLabel.font = font;
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    
    UIImage * nImg = [[UIImage imageNamed:normalBgImageName] stretchableImageWithLeftCapWidth:2
                                                                                 topCapHeight:2];
    UIImage * hlImg = [[UIImage imageNamed:highlightedBgImageName] stretchableImageWithLeftCapWidth:2
                                                                                       topCapHeight:2];
    [btn setBackgroundImage:nImg  forState:UIControlStateNormal];
    [btn setBackgroundImage:hlImg forState:UIControlStateHighlighted];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

@end
