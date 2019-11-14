//
//  VoiceButton.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "VoiceButton.h"
#import "UIView+Layout.h"


@implementation VoiceButton

+ (instancetype)buttonWithFrame:(CGRect)frame
      normalBackgroundImageName:(NSString *)normalBgImageName
    selectedBackgroundImageName:(NSString *)selectedBgImageName
                normalImageName:(NSString *)normalImageName
              selectedImageName:(NSString *)selectedImageName
                   isMicrophone:(BOOL)isMicrophone
{
    VoiceButton * button = [VoiceButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.imageView.backgroundColor = [UIColor clearColor];

    UIImage * normalImage = [UIImage imageNamed:normalBgImageName];
    UIImage * selectedImage = [UIImage imageNamed:selectedBgImageName];

    button.normalImage = normalImage;
    button.selectedImage = selectedImage;
    button.size = normalImage.size;
    
    if (isMicrophone) {
        [button setBackgroundImage:normalImage   forState:UIControlStateNormal];
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    }
    else {
        button.backgroundLayer.contents = (__bridge id _Nullable)(normalImage.CGImage);
    }
    
    [button setImage:[UIImage imageNamed:normalImageName]   forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    
    return button;
}


#pragma mark - SET

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // 开启事务，取消隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIImage * img = selected ? self.selectedImage : self.normalImage;
    self.backgroundLayer.contents = (__bridge id _Nullable)(img.CGImage);
    [CATransaction commit];
}


#pragma mark - GET

- (CALayer *)backgroundLayer
{
    if (_backgroundLayer == nil) {
        CALayer * layer = [CALayer layer];
        layer.frame = self.bounds;
        [self.layer insertSublayer:layer atIndex:0];
        _backgroundLayer = layer;
    }
    return _backgroundLayer;
}

@end
