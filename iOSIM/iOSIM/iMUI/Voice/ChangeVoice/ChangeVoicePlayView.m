//
//  ChangeVoicePlayView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "ChangeVoicePlayView.h"
#import "ChangeVoicePlayCell.h"
#import "AudioPlayer.h"
#import "RecordModel.h"
#import "VoiceView.h"
#import "Recorder.h"
#import "FileManager.h"
#import "UIView+Layout.h"


@interface ChangeVoicePlayView ()

@property (nonatomic, weak) UIScrollView * bgScroll;
@property (nonatomic, weak) ChangeVoicePlayCell * playingViewCell;
@property (nonatomic, weak) UIButton * cancelButton; // 取消按钮
@property (nonatomic, weak) UIButton * sendButton;   // 发送按钮

@property (nonatomic, strong) CADisplayLink * playTimer;      // 播放时振幅计时器
@property (nonatomic, strong) NSMutableArray * imageNames;

@end


@implementation ChangeVoicePlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self __setupSubviews];
    }
    return self;
}

- (void)__setupSubviews
{
    [self bgScroll];
    [self __setupContentScrollView];
    [self cancelButton];
    [self sendButton];
}

- (void)__setupContentScrollView
{
    NSArray * titles = @[ @"原声", @"萝莉", @"大叔", @"惊悚", @"空灵", @"搞怪"];
    CGFloat width = self.width / 4;
    CGFloat height = width + 10;
    
    WEAK_SELF;
    for (int i = 0; i < self.imageNames.count; i++) {
        STRONG_SELF;
        ChangeVoicePlayCell * cell = [[ChangeVoicePlayCell alloc] initWithFrame:CGRectMake(i%4 * width, i / 4 * height, width, height)];
        cell.center = self.bgScroll.center;
        cell.imageName = self.imageNames[i];
        cell.title = titles[i];
        [_bgScroll addSubview:cell];
        
        [UIView animateWithDuration:0.25 animations:^{
            cell.frame = CGRectMake(i%4 * width, i / 4 * height, width, height);
        } completion:^(BOOL finished) {
            cell.frame = CGRectMake(i%4 * width, i / 4 * height, width, height);
        }];
        cell.playRecordBlock = ^(ChangeVoicePlayCell * aCell) {
            [strongSelf.playTimer invalidate];
            if (strongSelf.playingViewCell != aCell) {
                [strongSelf.playingViewCell endPlay];
            }
            [aCell playingRecord];
            strongSelf.playingViewCell = aCell;
            [strongSelf __startPlayTimer];
        };
        cell.endPlayBlock = ^(ChangeVoicePlayCell * aCell) {
            [strongSelf.playTimer invalidate];
            [aCell endPlay];
        };
        
        if (i == self.imageNames.count - 1) {
            CGFloat h = i / 4 * height;
            if (h < self.height - self.cancelButton.height)
                h = self.height - self.cancelButton.height + 1;
            
            self.bgScroll.contentSize = CGSizeMake(0, h);
        }
    }
}


#pragma mark - CADisplayLink
/**
  *  @brief   启动振幅计时器
  */
- (void)__startPlayTimer
{
    [self.playTimer invalidate];
    self.playTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(__updatePlayMeter)];
    
    if (@available(iOS 10.0, *)) {
        self.playTimer.preferredFramesPerSecond = 10;
    }
    else {
        self.playTimer.frameInterval = 6;
    }
    [self.playTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)__updatePlayMeter
{
    [self.playingViewCell updateLevels];
}

- (void)__stopPlay
{
    [[AudioPlayer sharedInstance] stopPlay];
}


#pragma mark - Touch

- (void)btnClick:(UIButton *)btn
{
    [self __stopPlay];
    
    if (btn == self.sendButton) { // 发送

    }
    // 取消发送并删除录音/删除变声文件
    else {
        [[Recorder sharedInstance] deleteRecord];
        [FileManager removeFile:[FileManager changedVoiceSavePathWithFileName:self.playingViewCell.voicePath.lastPathComponent]];
    }
    
    [(VoiceView *)self.superview.superview.superview setState:VoiceState_Default];
    
    [UIView transitionWithView:self
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
        [self removeFromSuperview];
    } completion:nil];
}


#pragma mark - GET

- (NSMutableArray *)imageNames
{
    if (_imageNames == nil) {
        _imageNames = [NSMutableArray arrayWithCapacity:6];
        for (int i = 0; i < 6; i++) {
            [_imageNames addObject:[NSString stringWithFormat:@"aio_voiceChange_effect_%d",i]];
        }
    }
    return _imageNames;
}

- (UIScrollView *)bgScroll
{
    if (_bgScroll == nil) {
        UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.height = scroll.width - 40;
        scroll.backgroundColor = [UIColor whiteColor];
        scroll.bounces = YES;
        scroll.showsVerticalScrollIndicator = NO;
        [self addSubview:scroll];
        _bgScroll = scroll;
    }
    return _bgScroll;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        UIButton * button = [self __buttonWithFrame:CGRectMake(0, self.height - 45, self.width/2.0, 45)
                                               text:@"取消"
                                          textColor:kSelectTextColor
                                               font:[UIFont systemFontOfSize:18]
                                  normalBgImageName:@"aio_record_cancel_button"
                             highlightedBgImageName:@"aio_record_cancel_button_press"
                                                sel:@selector(btnClick:)];
        [self addSubview:button];
        _cancelButton = button;
    }
    return _cancelButton;
}

- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        UIButton * button = [self __buttonWithFrame:CGRectMake(self.width/2.0, self.height - 45, self.width/2.0, 45)
                                               text:@"发送"
                                          textColor:kSelectTextColor
                                               font:[UIFont systemFontOfSize:18]
                                  normalBgImageName:@"aio_record_send_button"
                             highlightedBgImageName:@"aio_record_send_button_press"
                                                sel:@selector(btnClick:)];
        [self addSubview:button];
        _sendButton = button;
    }
    return _sendButton;
}


#pragma mark - Tool
/**
  *  @brief   生成按钮控件并返回
  */
- (UIButton *)__buttonWithFrame:(CGRect)frame
                           text:(NSString *)text
                      textColor:(UIColor *)textColor
                           font:(UIFont *)font
              normalBgImageName:(NSString *)normalBgImageName
         highlightedBgImageName:(NSString *)highlightedBgImageName
                            sel:(SEL)sel
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.titleLabel.font = font;
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    
    UIImage * nImg = [[UIImage imageNamed:normalBgImageName] stretchableImageWithLeftCapWidth:2
                                                                                 topCapHeight:2];
    UIImage * hlImg = [[UIImage imageNamed:highlightedBgImageName] stretchableImageWithLeftCapWidth:2
                                                                                       topCapHeight:2];
    [button setBackgroundImage:nImg forState:UIControlStateNormal];
    [button setBackgroundImage:hlImg forState:UIControlStateHighlighted];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end
