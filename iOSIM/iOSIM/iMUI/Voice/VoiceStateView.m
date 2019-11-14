//
//  VoiceStateView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "VoiceStateView.h"
#import "Recorder.h"
#import "UIView+Layout.h"
#import "RecordModel.h"


static CGFloat const levelWidth = 3.0;   // 振幅视图每个竖线的宽度
static CGFloat const levelSpace = 2.0;   // 振幅视图每个竖线间的距离

@interface VoiceStateView ()
{
    NSInteger __allLevelCount;  //
}
/**   顶部文本相关   **/
@property (nonatomic, weak) UILabel * textLabel;                    // 不同录音状态下的文本标签
@property (nonatomic, weak) UIActivityIndicatorView * activityView; // 准备录音状态下的菊花

/**   振幅界面相关  **/
@property (nonatomic, weak) UIView * amplitudeContentView;       // 振幅所有视图的载体
@property (nonatomic, weak) UILabel * timeLabel;                 // 录音时长标签
@property (nonatomic, weak) CAReplicatorLayer * replicatorLayer; // 复制图层
@property (nonatomic, weak) CAShapeLayer * amplitudeLayer;       // 振幅 layer

@property (nonatomic, strong) NSMutableArray * currentAmplitudes;// 当前振幅数组
@property (nonatomic, strong) NSMutableArray * allAmplitudes;    // 所有收集到的振幅，预先保存，用于播放
@property (nonatomic, strong) UIBezierPath * amplitudePath;      // 画振幅的 path

@property (nonatomic, strong) NSTimer * audioTimer;              // 录音时长/播放录音的计时器
@property (nonatomic, strong) CADisplayLink * amplitudeDisplayLink;  // 振幅计时器
@property (nonatomic, assign) NSUInteger recordDuration;         // 录音时长
@property (nonatomic, strong) CADisplayLink * playDisplayLink;   // 播放时的振幅计时器

@end


@implementation VoiceStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self __setupSubviews];
    }
    return self;
}

/**
  *  @brief   添加子视图
  */
- (void)__setupSubviews
{
    [self textLabel];
    [self activityView];
    [self __updateSubviewsFrame];
    [self amplitudeContentView];
}

/**
  *  @brief   开始录音
  */
- (void)beginRecord
{
    self.amplitudeContentView.hidden = NO;
    
    // 开始录音前，把上一次录音的振幅删掉
    [self.allAmplitudes removeAllObjects];
    self.currentAmplitudes = nil;
    [self __startMeterTimer];
    [self __startAudioTimer];
}

/**
  *  @brief   结束录音
  */
- (void)endRecord
{
    RecordModel * rm = [RecordModel sharedInstance];
    rm.filePath = [Recorder sharedInstance].recordFilePath;
    rm.levels = [NSArray arrayWithArray:self.allAmplitudes];
    rm.duration = (NSTimeInterval)_recordDuration;
    
    _recordDuration = 0;
    [self __updateTimeLabel];
    
    [self __stopMeterTimer];
    [self __startAudioTimer];
    
    self.currentAmplitudes = nil;
    self.amplitudeContentView.hidden = YES;
}

/**
  *  @brief   准备播放
  */
- (void)__prepareToPlay
{
    [self __stopMeterTimer];
    [self __stopAudioTimer];
    
    self.allAmplitudes = [[RecordModel sharedInstance].levels mutableCopy];
    [self.currentAmplitudes removeAllObjects];
    
    for (NSInteger i = self.allAmplitudes.count - 1; i >= self.allAmplitudes.count - 10; i--) {
        CGFloat level = 0.05;
        if (i >= 0) {
            level = [self.allAmplitudes[i] floatValue];
        }
        [self.currentAmplitudes addObject:@(level)];
    }
    
    _recordDuration = [RecordModel sharedInstance].duration;
    
    [self __updateLevelLayer];
    [self __updateTimeLabel];
}

/**
  *  @brief   播放录音
  */
- (void)__playAndMertering
{
    [self __prepareToPlay];
    
    _recordDuration = 0;
    
    [self __updateTimeLabel];
    [self __startPlayTimer];
    [self __startAudioTimer];
}

/**
  *  @brief   更新子视图的位置
  */
- (void)__updateSubviewsFrame
{
    self.textLabel.hidden = NO;
    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(self.width/2.0, self.height/2.0);

    self.activityView.right = _textLabel.left - 5;
    _activityView.centerY = _textLabel.centerY;
    _activityView.transform = CGAffineTransformMakeScale(0.8, 0.8);
}


#pragma mark - CADisplayLink
/**
  *  @brief   启动音频振幅计时器，更新音频振幅视图
  */
- (void)__startMeterTimer
{
    // 停止计时器
    [self __stopMeterTimer];
    
    self.amplitudeDisplayLink = [CADisplayLink displayLinkWithTarget:self
                                                            selector:@selector(__updateMeter)];
    // 设置每秒的帧数
    if (@available(iOS 10.0, *)) {
        self.amplitudeDisplayLink.preferredFramesPerSecond = 10;
    }
    else {
        self.amplitudeDisplayLink.frameInterval = 6;
    }
    [self.amplitudeDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)__stopMeterTimer
{
    [self.amplitudeDisplayLink invalidate];
    self.amplitudeDisplayLink = nil;
}


#pragma mark - NSTimer

- (void)__startAudioTimer
{
    [self __stopAudioTimer];
    
    if (_soundState != SoundState_Play) {
        _recordDuration = 0;
    }
    
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(__addSecond)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)__stopAudioTimer
{
    if (self.audioTimer) {
        if ([_audioTimer isValid]) {
            [_audioTimer invalidate];
        }
        _audioTimer = nil;
    }
}

- (void)__addSecond
{
    // 正在播放
    if (_soundState == SoundState_Play) {
        if (_recordDuration == [RecordModel sharedInstance].duration) {
            [self __stopAudioTimer];
            return;
        }
    }
    _recordDuration++;
    
    [self __updateTimeLabel];
}

- (void)__startPlayTimer
{
    __allLevelCount = self.allAmplitudes.count;
    
    [self __stopPlayTimer];
    self.playDisplayLink = [CADisplayLink displayLinkWithTarget:self
                                                       selector:@selector(__updatePlayMeter)];
    // 设置每秒的帧数
    if (@available(iOS 10.0, *)) {
        self.playDisplayLink.preferredFramesPerSecond = 10;
    }
    else {
        self.playDisplayLink.frameInterval = 6;
    }
    [self.playDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)__stopPlayTimer
{
    [self.playDisplayLink invalidate];
    self.playDisplayLink = nil;
}

- (void)__updatePlayMeter
{
    CGFloat value = 1 - (CGFloat)self.allAmplitudes.count / __allLevelCount;
    
    if (value == 1) {
        [self __stopPlayTimer];
        [self __stopAudioTimer];
    }
    
    if (_playProgressBlock) {
        _playProgressBlock(value);
    }
    
    if (value == 1)
        return;
    
    CGFloat level = [self.allAmplitudes.firstObject floatValue];
    [self.currentAmplitudes removeLastObject];
    [self.currentAmplitudes insertObject:@(level) atIndex:0];
    [self.allAmplitudes removeObjectAtIndex:0];
    [self __updateLevelLayer];
}


#pragma mark - Update UI

- (void)__updateMeter
{
    // 音频分贝值
    CGFloat level = [[Recorder sharedInstance] levels];
    
    [self.currentAmplitudes removeLastObject];
    [self.currentAmplitudes insertObject:@(level) atIndex:0];
    [self.allAmplitudes addObject:@(level)];
    
    [self __updateLevelLayer];
}

/**
  *  @brief   更新分贝值图层
  */
- (void)__updateLevelLayer
{
    self.amplitudePath = [UIBezierPath bezierPath];
    
    CGFloat height = CGRectGetHeight(self.amplitudeLayer.frame);
    
    for (NSInteger i = 0; i < self.currentAmplitudes.count; i++) {
        CGFloat x = i * (levelWidth + levelSpace) + 5;
        CGFloat pathH = [self.currentAmplitudes[i] floatValue] * height;
        CGFloat startY = height/2.0 - pathH/2.0;
        CGFloat endY   = height/2.0 + pathH/2.0;
        
        [_amplitudePath moveToPoint:CGPointMake(x, startY)];
        [_amplitudePath addLineToPoint:CGPointMake(x, endY)];
    }
    
    self.amplitudeLayer.path = _amplitudePath.CGPath;
}

/**
  *   @brief   更新录音播放时间
  */
- (void)__updateTimeLabel
{
    NSString * text;
    if (_recordDuration < 60) {
        text = [NSString stringWithFormat:@"0:%02zd", _recordDuration];
    }
    else {
        NSInteger minutes = _recordDuration / 60;
        NSInteger seconds = _recordDuration % 60;
        text = [NSString stringWithFormat:@"%zd:%02zd", minutes, seconds];
    }
    self.timeLabel.text = text;
}


#pragma mark - SET

- (void)setSoundState:(SoundState)soundState
{
    _soundState = soundState;
    
    self.amplitudeContentView.hidden = YES;
    [self.activityView stopAnimating];
    
    switch (soundState) {
        case SoundState_Default:
        {
            self.textLabel.text = @"按住说话";
            [self __updateSubviewsFrame];
        }
            break;
            
        case SoundState_ClickRecord:
        {
            self.textLabel.text = @"点击录音";
            [self __updateSubviewsFrame];
        }
            break;
        
        case SoundState_TouchChangeVoice:
        {
            self.textLabel.text = @"按住变声";
            [self __updateSubviewsFrame];
        }
            break;
            
        case SoundState_Listen:
        {
            self.textLabel.text = @"松手试听";
            [self __updateSubviewsFrame];
        }
            break;
            
        case SoundState_Cancel:
        {
            self.textLabel.text = @"松手取消发送";
            [self __updateSubviewsFrame];
        }
            break;
        
        case SoundState_Prepare:
        {
            self.textLabel.text = @"准备中";
            [self __updateSubviewsFrame];
            [self.activityView startAnimating];
        }
            break;
        
        case SoundState_Recording:
        {
            self.textLabel.hidden = YES;
            self.amplitudeContentView.hidden = NO;
        }
            break;
            
        case SoundState_Play:
        {
            self.textLabel.hidden = YES;
            self.amplitudeContentView.hidden = NO;
            [self __playAndMertering];
        }
            break;
            
        case SoundState_PreparePlay:
        {
            self.textLabel.hidden = YES;
            self.amplitudeContentView.hidden = NO;
            [self __prepareToPlay];
        }
            
        case SoundState_Send:
        default:
            break;
    }
}


#pragma mark - GET

- (NSMutableArray *)allAmplitudes
{
    if (_allAmplitudes == nil) {
        _allAmplitudes = [NSMutableArray arrayWithCapacity:1];
    }
    return _allAmplitudes;
}

- (NSMutableArray *)currentAmplitudes
{
    if (_currentAmplitudes == nil) {
        _currentAmplitudes = [ @[ @0.05, @0.05, @0.05, @0.05, @0.05,
                                  @0.05, @0.05, @0.05, @0.05, @0.05] mutableCopy];
    }
    return _currentAmplitudes;
}

- (UIView *)amplitudeContentView
{
    if (_amplitudeContentView == nil) {
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:view];
        view.hidden = YES;
        _amplitudeContentView = view;
        
        [self timeLabel];
        [self replicatorLayer];
    }
    return _amplitudeContentView;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, self.height)];
        label.text = @"0:00";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = kNormalTextColor;
        label.center = self.amplitudeContentView.center;
        [_amplitudeContentView addSubview:label];
        _timeLabel = label;
    }
    return _timeLabel;
}

- (CAReplicatorLayer *)replicatorLayer
{
    if (_replicatorLayer == nil) {
        CAReplicatorLayer * layer = [CAReplicatorLayer layer];
        layer.frame = self.layer.bounds;
        layer.instanceCount = 2;
        layer.instanceTransform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        [self.amplitudeContentView.layer addSublayer:layer];
        _replicatorLayer = layer;
        
        [self amplitudeLayer];
    }
    return _replicatorLayer;
}

- (CAShapeLayer *)amplitudeLayer
{
    if (_amplitudeLayer == nil) {
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(self.timeLabel.right, 10, self.width/2.0 - 30, self.height - 20);
        layer.strokeColor = UIColorFromRGBA(253, 99, 9, 1.0).CGColor;
        layer.lineWidth = levelWidth;
        [self.replicatorLayer addSublayer:layer];
        _amplitudeLayer = layer;
    }
    return _amplitudeLayer;
}

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = @"按住说话";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = kNormalTextColor;
        [self addSubview:label];
        _textLabel = label;
    }
    return _textLabel;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        UIActivityIndicatorView * view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.hidesWhenStopped = YES;
        [self addSubview:view];
        _activityView = view;
    }
    return _activityView;
}

@end
