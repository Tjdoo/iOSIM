//
//  TalkbackView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "TalkbackView.h"
#import "Recorder.h"
#import "VoiceStateView.h"
#import "VoiceButton.h"
#import "VoicePlayView.h"
#import "UIView+Layout.h"
#import "VoiceView.h"
#import "FileManager.h"


static CGFloat const maxScale = 0.45;

@interface TalkbackView () <RecordPTC>

@property (nonatomic, weak) VoiceStateView * stateView;
@property (nonatomic, weak) VoiceButton * microButton;  // 录音按钮
@property (nonatomic, weak) VoiceButton * playButton;   // 播放按钮
@property (nonatomic, weak) VoiceButton * cancelButton; // 取消按钮
@property (nonatomic, weak) VoicePlayView * playView;   // 播放界面
@property (nonatomic, weak) UIImageView * voiceLine;  // 录音时的曲线

@end


@implementation TalkbackView

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
    [self voiceLine];
    [self microButton];
    [self playButton];
    [self cancelButton];
    
    [Recorder sharedInstance].delegate = self;
}


#pragma mark - Animation
/**
  *  @brief   麦克风按钮动画
  */
- (void)__animationMicroButton:(void(^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.10 animations:^{
        // 放大
        self.microButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.05 animations:^{
            // 还原
            self.microButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }];
}

/**
  *  @brief   播放、取消按钮的动画
  */
- (void)__animationPlayAndCancelButton
{
    [self __animationWithStartPoint:CGPointMake(self.playButton.centerX + 20, self.playButton.centerY)
                           endPoint:self.playButton.center
                               view:self.playButton];
    [self __animationWithStartPoint:CGPointMake(self.cancelButton.centerX - 20, self.cancelButton.centerY)
                           endPoint:self.cancelButton.center
                               view:self.cancelButton];
}

/**
  *  @brief   给视图 view 添加位置动画和透明度动画
  */
- (void)__animationWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint view:(UIView *)view
{
    view.hidden = NO;
    
    CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    positionAnimation.toValue   = [NSValue valueWithCGPoint:endPoint];
    positionAnimation.duration  = 0.15;
    
    CABasicAnimation * opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(0);
    opacityAnimation.toValue   = @(1);
    
    // 动画组
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[ positionAnimation, opacityAnimation ];
    animationGroup.duration   = 0.15;
    [view.layer addAnimation:animationGroup forKey:nil];
}

/**
  *  @brief   进度曲线的动画
  */
- (void)__animationVoiceLine
{
    self.voiceLine.transform = CGAffineTransformMakeScale(0.8, 0.8);
    self.voiceLine.hidden = NO;
    [UIView animateWithDuration:0.15 animations:^{
        self.voiceLine.transform = CGAffineTransformIdentity;
    }];
}

/**
  *  @brief   按钮的形变以及动画
  */
- (void)__transitionButton:(VoiceButton *)button
                 withPoint:(CGPoint)point
              containBlock:(void(^)(BOOL isContain))block
{
    CGFloat distance = [self __distanceBetweenPointA:button.center withPointB:point];
    
    CGFloat d = button.width * 3.0 / 4;
    CGFloat x = distance * maxScale / d;
    CGFloat scale = 1 - x;
    scale = scale > 0 ?  scale > maxScale ? maxScale : scale : 0;
    
    CGPoint p = [self.layer convertPoint:point toLayer:button.backgroundLayer];
    
    if ([button.backgroundLayer containsPoint:p]) {
        button.selected = YES;
        button.backgroundLayer.transform = CATransform3DMakeScale(1 + maxScale, 1 + maxScale, 1);
        
        if (block) {
            block(YES);
        }
    }
    else {
        button.backgroundLayer.transform = CATransform3DMakeScale(1 + scale, 1 + scale, 1);
        button.selected = NO;
        
        if (block) {
            block(NO);
        }
    }
}

/**
  *  @brief  计算两点之间的距离
  */
- (CGFloat)__distanceBetweenPointA:(CGPoint)pointA withPointB:(CGPoint)pointB
{
    return sqrt(pow((pointA.x - pointB.x), 2) + pow((pointA.y - pointB.y), 2));
}


#pragma mark - Touch
/**
  *  @brief   开始录音
  */
- (void)startRecord:(UIButton *)btn
{
    [Recorder sharedInstance].delegate = self;
    
    btn.selected = YES;
    
    // 设置状态：隐藏小圆点和三个标签
    [(VoiceView *)self.superview.superview setState:VoiceState_Record];
    
    [self __animationMicroButton:^(BOOL finished) {
        [[Recorder sharedInstance] beginRecordWithStoreFilePath:[FileManager filePath]];
    }];
}

/**
  *  @brief   发送录音
  */
- (void)sendRecord:(UIButton *)btn
{
    NSTimeInterval ti = 0;
    
    if (![Recorder sharedInstance].isRecording) {
        ti = 0.3;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ti * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        btn.selected = NO;
        self.playButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.voiceLine.hidden = YES;
        self.stateView.soundState = SoundState_Default;
        
        [[Recorder sharedInstance] endRecord];
        [self.stateView endRecord];
        
        // 设置状态：显示小圆点和三个标签
        [(VoiceView *)self.superview.superview setState:VoiceState_Default];
        
        if (ti == 0) {
            NSLog(@"发送录音!");
        }
        else {
            NSLog(@"录音时间太短");
        }
    });
}

/**
  *  @brief   滑动手势
  */
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if (!self.microButton.isSelected)
        return;
    
    CGPoint point = [gesture locationInView:gesture.view.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        WEAK_SELF;
        
        // 触摸点在左边
        if (point.x < self.width /2.0) {
            [self __transitionButton:self.playButton withPoint:point containBlock:^(BOOL isContain) {
                STRONG_SELF;
                // 触摸点落在播放按钮内
                if (isContain) {
                    strongSelf.stateView.soundState = SoundState_Listen;
                }
                else {
                    strongSelf.stateView.soundState = SoundState_Recording;
                }
            }];
        }
        // 触摸点在右边
        else {
            [self __transitionButton:self.cancelButton withPoint:point containBlock:^(BOOL isContain) {
                STRONG_SELF;
                // 触摸点落在取消按钮内
                if (isContain) {
                    strongSelf.stateView.soundState = SoundState_Cancel;
                }
                else {
                    strongSelf.stateView.soundState = SoundState_Recording;
                }
            }];
        }
    }
    // 手势结束或者取消
    else {
        [[Recorder sharedInstance] endRecord];
        [self.stateView endRecord];
        
        if (self.stateView.soundState == SoundState_Listen) {
            self.playView = nil;
            [self playView];
        }
        else if (self.stateView.soundState == SoundState_Cancel) {
            
            [[Recorder sharedInstance] deleteRecord];
            // 设置状态：显示小圆点和三个标签
            [(VoiceView *)self.superview.superview setState:VoiceState_Default];
        }
        else {
            NSLog(@"发送语音");
            // 设置状态：显示小圆点和三个标签
            [(VoiceView *)self.superview.superview setState:VoiceState_Default];
        }
        
        self.microButton.selected = NO;
        self.playButton.selected = NO;
        self.cancelButton.selected = NO;
        
        self.playButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.voiceLine.hidden = YES;
        self.playButton.backgroundLayer.transform = CATransform3DIdentity;
        self.cancelButton.backgroundLayer.transform = CATransform3DIdentity;
        
        self.stateView.soundState = SoundState_Default;
    }
}


#pragma mark - RecorderPTC
/**
  *  @brief   准备录音
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
    
    [self __animationPlayAndCancelButton];
    [self __animationVoiceLine];
    
    // 开始录音
    [self.stateView beginRecord];
}

/**
  *  @brief   录音失败
  */
- (void)recorderRecordFail:(NSString *)failMsg
{
    self.stateView.soundState = SoundState_Default;
    NSLog(@"录音失败：%@", failMsg);
}


#pragma mark - GET

- (UIImageView *)voiceLine
{
    if (_voiceLine == nil) {
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aio_voice_line"]];
        iv.hidden = YES;
        [self addSubview:iv];
        _voiceLine = iv;
    }
    return _voiceLine;
}

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
        [self addSubview:view];
        _stateView = view;
    }
    return _stateView;
}

- (VoiceButton *)cancelButton
{
    if (_cancelButton == nil) {
        VoiceButton * button = [VoiceButton buttonWithFrame:CGRectZero
                                  normalBackgroundImageName:@"aio_voice_operate_nor"
                                selectedBackgroundImageName:@"aio_voice_operate_press"
                                            normalImageName:@"aio_voice_operate_delete_nor"
                                          selectedImageName:@"aio_voice_operate_delete_press"
                                               isMicrophone:NO];
        button.frame = CGRectMake(self.width - 35 - button.normalImage.size.width,
                                  self.stateView.bottom + 10,
                                  button.normalImage.size.width,
                                  button.normalImage.size.height);
        [self addSubview:button];
        button.hidden = YES;
        _cancelButton = button;
    }
    return _cancelButton;
}

- (VoiceButton *)playButton
{
    if (_playButton == nil) {
        VoiceButton * button = [VoiceButton buttonWithFrame:CGRectMake(35, self.stateView.bottom+10, 0, 0)
                                  normalBackgroundImageName:@"aio_voice_operate_nor"
                                selectedBackgroundImageName:@"aio_voice_operate_press"
                                            normalImageName:@"aio_voice_operate_listen_nor"
                                          selectedImageName:@"aio_voice_operate_listen_press"
                                               isMicrophone:NO];
        [self addSubview:button];
        button.hidden = YES;
        _playButton = button;
    }
    return _playButton;
}

- (VoiceButton *)microButton
{
    if (_microButton == nil) {
        VoiceButton * button = [VoiceButton buttonWithFrame:CGRectMake(0, self.stateView.bottom, 0, 0)
                                  normalBackgroundImageName:@"aio_voice_button_nor"
                                selectedBackgroundImageName:@"aio_voice_button_press"
                                            normalImageName:@"aio_voice_button_icon"
                                          selectedImageName:@"aio_voice_button_icon"
                                               isMicrophone:YES];
        // 手指按下
        [button addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
        // 松开手指
        [button addTarget:self action:@selector(sendRecord:) forControlEvents:UIControlEventTouchUpInside];
        // 拖动手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [button addGestureRecognizer:pan];
    
        button.centerX = self.width/2.0;
        self.voiceLine.center = button.center;
        [self addSubview:button];
        _microButton = button;
    }
    return _microButton;
}

@end
