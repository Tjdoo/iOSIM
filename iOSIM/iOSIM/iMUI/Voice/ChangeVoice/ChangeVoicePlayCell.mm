//
//  ChangeVoicePlayCell.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "ChangeVoicePlayCell.h"
#import "UIView+Layout.h"
#import "RecordModel.h"
#import "AudioPlayer.h"
#import "SoundTouchOperation.h"


static CGFloat const levelWidth = 3.0;
static CGFloat const levelSpace = 2.0;

@interface ChangeVoicePlayCell ()

@property (nonatomic, weak) UIButton * playButton;
@property (nonatomic, weak) UIButton * titleButton;
@property (nonatomic, strong) NSMutableArray * currentLevels; // 当前振幅数组
@property (nonatomic, strong) NSMutableArray * allLevels;     // 所有收集到的振幅,预先保存，用于播放
@property (nonatomic, assign) NSInteger recordDuration;       // 录音时长
@property (nonatomic, weak) CAShapeLayer * levelLayer;        // 振幅layer
@property (nonatomic, strong) UIBezierPath * levelPath;       // 画振幅的path
@property (nonatomic, weak) UILabel * timeLabel;              // 录音时长标签
@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, weak) CAShapeLayer * circleLayer;       // 环形进度条
@property (nonatomic, strong) NSDictionary * pitchDict;

@end


@implementation ChangeVoicePlayCell
{
    NSInteger _allCount; // 记录所有振幅的总个数
    NSInteger _callNumbel;   // 记录定时器方法调用多少次，根据这个来算秒数(每秒10次)
    NSOperationQueue * _soundTouchQueue;
    CGFloat _tempoValue;
    CGFloat _pitchValue;
    CGFloat _rateValue;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self __initSoundTouchQueue];
        [self __setupSubviews];
        _voicePath = [RecordModel sharedInstance].filePath;
    }
    return self;
}

- (void)__initSoundTouchQueue
{
    _soundTouchQueue = [[NSOperationQueue alloc] init];
    _soundTouchQueue.maxConcurrentOperationCount = 1;
}

- (void)__setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    [self playButton];
    [self titleButton];
}

- (void)layoutSubviews
{
    self.playButton.center = CGPointMake(self.width / 2.0, self.height / 2.0 - 10);
    self.titleButton.centerX = self.width / 2.0;
    self.titleButton.centerY = (self.height - self.playButton.bottom) / 2 + self.playButton.bottom;
}

/**
  *  @brief   播放录音
  */
- (void)playingRecord
{
    [self __preparePlayAudio];
    
    // 播放音频
    if ([self.title isEqualToString:@"原声"]) {
        [self playVoiceChange:[RecordModel sharedInstance].filePath];
    }
    else {
        [self playAudioWithPath:[RecordModel sharedInstance].filePath];
    }
    
}

- (void)updateLevels
{
    CGFloat value = 1 - (CGFloat)self.allLevels.count / _allCount;
    
    if (value == 1 || self.allLevels.count == 0) {
        WEAK_SELF;
        if (_endPlayBlock) {
            _endPlayBlock(weakSelf);
        }
        return;
    }
    
    // 振幅更新
    [self __updateLevelLayer];
    // 圆形进度条更新
    self.progressValue = value;
    
    _callNumbel++;
    // 刷新 10 次增加一秒
    if (_callNumbel % 10 == 0)
        [self __addSecond];
}

- (void)endPlay
{
    // 开启事务，取消隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.levelLayer.hidden = YES;
    [CATransaction commit];
    
    self.timeLabel.hidden = YES;
    self.playButton.selected = NO;
    self.titleButton.selected = NO;
    
    [[AudioPlayer sharedInstance] stopPlay]; // 停止播放音频
    
    self.progressValue = 0;
}

/**
  *  @brief   准备播放
  */
- (void)__preparePlayAudio
{
    _callNumbel = 0;
    
    _recordDuration = 0;
    [self __updateTimeLabel];
    
    _progressValue = 0;
    self.levelLayer.hidden = NO;
    self.timeLabel.hidden = NO;
    self.allLevels = [[RecordModel sharedInstance].levels mutableCopy];
    [self.currentLevels removeAllObjects];
    _allCount = self.allLevels.count;
    
    for (NSInteger i = self.allLevels.count - 1 ; i >= self.allLevels.count - 6 ; i--) {
        CGFloat level = 0.05;
        if (i >= 0) {
            level = [self.allLevels[i] floatValue];
        }
        [self.currentLevels addObject:@(level)];
    }
}

/**
  *  @brief   增加计时
  */
- (void)__addSecond
{
    if (_recordDuration == [RecordModel sharedInstance].duration) {
        return;
    }
    _recordDuration++;
    
    [self __updateTimeLabel];
}

/**
  *  @brief   更新时间标签
  */
- (void)__updateTimeLabel
{
    NSString * text ;
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

/**
  *  @brief   更新振幅视图
 */
- (void)__updateLevelLayer
{
    CGFloat level = [self.allLevels.firstObject floatValue];
    [self.currentLevels removeLastObject];
    [self.currentLevels insertObject:@(level) atIndex:0];
    [self.allLevels removeObjectAtIndex:0];
    
    self.levelPath = [UIBezierPath bezierPath];
    
    CGFloat height = CGRectGetHeight(self.levelLayer.frame);
    
    for (int i = 0; i < self.currentLevels.count; i++) {
        CGFloat x = i * (levelWidth + levelSpace) + levelWidth / 2.0;
        
        CGFloat pathH = [self.currentLevels[i] floatValue] * height;
        CGFloat startY = height / 2.0 - pathH / 2.0;
        CGFloat endY = height / 2.0 + pathH / 2.0;
        
        [_levelPath moveToPoint:CGPointMake(x, startY)];
        [_levelPath addLineToPoint:CGPointMake(x, endY)];
    }
    
    self.levelLayer.path = _levelPath.CGPath;
}

- (void)__updateCircleLayer
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    CGFloat width = CGRectGetWidth(self.circleLayer.frame);
    CGFloat startAngle = -M_PI_2;
    CGFloat angle = _progressValue * M_PI * 2;
    CGFloat endAngle = startAngle + angle;
    
    [path addArcWithCenter:CGPointMake(width / 2.0, width / 2.0)
                    radius:width / 2.0 - 1.0
                startAngle:startAngle
                  endAngle:endAngle
                 clockwise:YES];
    self.circleLayer.path = path.CGPath;
}


#pragma mark - Touch

- (void)__playAudio
{
    self.titleButton.selected = !self.playButton.selected;
    self.playButton.selected = !self.playButton.selected;

    WEAK_SELF;
    if (self.playButton.selected) {
        if (_playRecordBlock)
            _playRecordBlock(weakSelf);
    }
    else {
        if (_endPlayBlock)
            _endPlayBlock(weakSelf);
    }
}

#pragma mark - Change Voice

- (void)playAudioWithPath:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    MySountTouchConfig config;
    config.sampleRate = 11025;
    config.tempoChange = 0;        // -50 - 100
    config.pitch = [self.pitchDict[self.title] intValue]; // -12 - 12
    config.rate = 0;    // -50 - 100
    
    SoundTouchOperation *sdop = [[SoundTouchOperation alloc] initWithTarget:self
                                                                     action:@selector(playVoiceChange:)
                                                           SoundTouchConfig:config soundFile:data];
    [_soundTouchQueue cancelAllOperations];
    [_soundTouchQueue addOperation:sdop];
}

- (void)playVoiceChange:(NSString *)path
{
    [[AudioPlayer sharedInstance] playAudioWith:path];
    self.voicePath = path;
}


#pragma mark - SET

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage imageNamed:_imageName] forState:UIControlStateNormal];
}

- (void)setProgressValue:(CGFloat)progressValue
{
    _progressValue = progressValue;
    [self __updateCircleLayer];
}


#pragma mark - GET

- (NSDictionary *)pitchDict
{
    if (_pitchDict == nil) {
        _pitchDict = @{ @"原声" : @(0),
                        @"萝莉" : @(12),
                        @"大叔" : @(-7),
                        @"惊悚" : @(-12),
                        @"空灵" : @(3),
                        @"搞怪" : @(7),
                       };
    }
    return _pitchDict;
}

- (NSMutableArray *)allLevels
{
    if (_allLevels == nil) {
        _allLevels = [NSMutableArray array];
    }
    return _allLevels;
}

- (NSMutableArray *)currentLevels
{
    if (_currentLevels == nil) {
        _currentLevels = [NSMutableArray arrayWithArray:@[ @0.05, @0.05, @0.05, @0.05, @0.05, @0.05 ]];
    }
    return _currentLevels;
}

- (UIButton *)playButton
{
    if (_playButton == nil) {
        UIImage * image = [UIImage imageNamed:@"aio_voiceChange_effect_0"];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.size = image.size;
        button.center = CGPointMake(self.width / 2.0, self.height / 2.0 - 10);

        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setImage:nil forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"aio_voiceChange_effect_selected"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"aio_voiceChange_effect_pressed"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(__playAudio) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.playButton = button;
    }
    return _playButton;
}

- (UIButton *)titleButton
{
    if (_titleButton == nil) {
        UIImage * image = [UIImage imageNamed:@"aio_voiceChange_text_select"];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.size = image.size;
        button.center = CGPointMake(self.width/2.0, (self.height - self.playButton.bottom)/2.0 + self.playButton.bottom);
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:@"原声" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setBackgroundImage:image forState:UIControlStateSelected];

        [self addSubview:button];
        self.titleButton = button;
    }
    return _titleButton;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 20)];
        label.top = self.playButton.centerY + 5;
        label.text = @"0:00";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.hidden = YES;
        [self addSubview:label];
        self.timeLabel = label;
    }
    return _timeLabel;
}

- (CAShapeLayer *)levelLayer
{
    if (_levelLayer == nil) {
        CGFloat w = 6 * levelWidth + 5 * levelSpace;
        
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(self.playButton.centerX - w/2.0, self.playButton.centerY - 20, w, 20);
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineWidth = levelWidth;
        [self.layer addSublayer:layer];
        _levelLayer = layer;
    }
    return _levelLayer;
}

- (CAShapeLayer *)circleLayer
{
    if (_circleLayer == nil) {
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.frame = self.playButton.frame;
        layer.strokeColor = [UIColorFromRGBA(20, 120, 211, 1.0) CGColor];
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = 1.5;
        [self.layer addSublayer:layer];
        _circleLayer = layer;
    }
    return _circleLayer;
}

@end
