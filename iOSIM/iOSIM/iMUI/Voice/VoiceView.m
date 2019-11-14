//
//  VoiceView.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "VoiceView.h"
#import "ChangeVoiceView.h"
#import "TalkbackView.h"
#import "RecordView.h"
#import "Macros.h"
#import "UIView+Layout.h"


@interface VoiceView () <UIScrollViewDelegate>
{
    CGFloat __origOffsetX;  // 初始时，滚动视图横轴上的偏移量
    CGFloat __labelWidth;  // 记录变声、对讲、录音文本框的宽度（三者宽度相同），用于滚动时处理文本框的移动
}
@property (nonatomic, weak) UIScrollView * bgScroll; // 承载内容的视图。因为 addSubView 会强引用，所以这里用 weak
@property (nonatomic, weak) ChangeVoiceView * changeVoiceView;  // 变声视图
@property (nonatomic, weak) TalkbackView * talkbackView;  // 对讲视图
@property (nonatomic, weak) RecordView * recordView;  // 录音视图
@property (nonatomic, weak) UIView * dotView;  // 蓝色圆点
@property (nonatomic, weak) UIView * bottomTextView;  // （变声、对讲、录音）文本的 bgView

@property (nonatomic, strong) NSArray<UILabel *> * labels;  // bottomTextView 上的标签数组
@property (nonatomic, weak) UILabel * curSelectedLabel;  // 当前选中的 label

@end


@implementation VoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self __setupSubviews];
    }
    return self;
}

/**
  *  @brief   设置子视图
  */
- (void)__setupSubviews
{
    // 调用 getter 方法
    [self bgScroll];
    [self changeVoiceView];
    [self talkbackView];
    [self recordView];
    [self bottomTextView];
    [self dotView];
    
    __origOffsetX = self.bgScroll.width;
    
    [self __selectLabel:self.labels[1]];
}

/**
  *  @brief   设置当前选中的文本样式
  */
- (void)__selectLabel:(UILabel *)label
{
    _curSelectedLabel.textColor = kNormalTextColor;
    label.textColor = kSelectTextColor;
    _curSelectedLabel = label;
}

/**
  *  @brief   变声、对讲、录音标签
  */
- (void)__setupBottomViewSubviews
{
    CGFloat margin = 10.0;
    
    UILabel * talkbackLabel = [self __getLabelWithText:@"对讲"];
    talkbackLabel.center = CGPointMake(self.bottomTextView.width /2.0, self.bottomTextView.height/2.0);
    [_bottomTextView addSubview:talkbackLabel];
    
    UILabel * changeVoiceLabel = [self __getLabelWithText:@"变声"];
    changeVoiceLabel.center = CGPointMake(talkbackLabel.left - margin - changeVoiceLabel.width /2.0,
                                          _bottomTextView.height / 2.0);
    [_bottomTextView addSubview:changeVoiceLabel];
    
    UILabel * recordLabel = [self __getLabelWithText:@"录音"];
    recordLabel.center = CGPointMake(talkbackLabel.right + margin + recordLabel.width / 2.0,
                                     _bottomTextView.height / 2.0);
    [_bottomTextView addSubview:recordLabel];
    
    // 保存文本框的宽度
    __labelWidth = recordLabel.centerX - talkbackLabel.centerX;
    
    self.labels = @[ changeVoiceLabel, talkbackLabel, recordLabel ];
}

/**
  *  @brief   提供 label
  */
- (UILabel *)__getLabelWithText:(NSString *)text
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.textColor = kNormalTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    [label sizeToFit];  // 重要，计算出文本框的尺寸
    return label;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollDistance = scrollView.contentOffset.x - __origOffsetX;
    CGFloat transtionX = (scrollDistance / _bgScroll.width) * __labelWidth;
    // 由偏移位置回到 (0, 0) 也是移动
    _bottomTextView.transform = CGAffineTransformMakeTranslation(-transtionX, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / _bgScroll.width;
    [self __selectLabel:_labels[index]];
}


#pragma mark - SET
/**
  *  @brief   设置状态时调整视图的展示
  */
- (void)setState:(VoiceState)state
{
    _state = state;
    
    self.bottomTextView.hidden = state != VoiceState_Default;
    self.dotView.hidden = state != VoiceState_Default;
    self.bgScroll.scrollEnabled = state == VoiceState_Default;
}


#pragma mark - GET
/**
  *  @brief   承载内容的滚动视图
  */
- (UIScrollView *)bgScroll
{
    if (_bgScroll == nil) {
        CGRect rect = CGRectMake(0, 0, self.width, self.height);
        UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:rect];
        scroll.pagingEnabled = YES;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.delegate = self;
        scroll.contentSize = CGSizeMake(self.width * 3, self.height);
        scroll.contentOffset = CGPointMake(self.width, 0);
        [self addSubview:scroll];
        _bgScroll = scroll;
    }
    return _bgScroll;
}

/**
  *  @brief   变声
  */
- (ChangeVoiceView *)changeVoiceView
{
    if (_changeVoiceView == nil) {
        CGRect rect = CGRectMake(0, 0, _bgScroll.width, _bgScroll.height);
        ChangeVoiceView * changeVoiceView = [[ChangeVoiceView alloc] initWithFrame:rect];
        [_bgScroll addSubview:changeVoiceView];
        _changeVoiceView = changeVoiceView;
    }
    return _changeVoiceView;
}

/**
  *  @brief   对讲
  */
- (TalkbackView *)talkbackView
{
    if (_talkbackView == nil) {
        CGRect rect = CGRectMake(_bgScroll.width, 0, _bgScroll.width, _bgScroll.height);
        TalkbackView * talkbackView = [[TalkbackView alloc] initWithFrame:rect];
        [_bgScroll addSubview:talkbackView];
        _talkbackView = talkbackView;
    }
    return _talkbackView;
}

/**
  *  @brief   录音
  */
- (RecordView *)recordView
{
    if (_recordView == nil) {
        CGRect rect = CGRectMake(_bgScroll.width * 2, 0, _bgScroll.width, _bgScroll.height);
        RecordView * recordView  = [[RecordView alloc] initWithFrame:rect];
        [_bgScroll addSubview:recordView];
        _recordView = recordView;
    }
    return _recordView;
}

/**
  *  @brief   底部文本视图
  */
- (UIView *)bottomTextView
{
    if (_bottomTextView == nil) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 45, self.width, 25)];
        [self addSubview:view];
        _bottomTextView = view;
        
        [self __setupBottomViewSubviews];
    }
    return _bottomTextView;
}

/**
  *  @brief   蓝色小圆点
  */
- (UIView *)dotView
{
    if (_dotView == nil) {
        CGFloat wh = 8;
        CGRect rect = CGRectMake((self.width - wh) / 2.0, self.bottomTextView.top - wh, wh, wh);
        UIView * view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = kSelectTextColor;
        view.layer.cornerRadius = wh / 2.0;
        [self addSubview:view];
        _dotView = view;
    }
    return _dotView;
}

@end
