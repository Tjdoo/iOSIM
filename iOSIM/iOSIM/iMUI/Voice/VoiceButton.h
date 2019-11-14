//
//  VoiceButton.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

/**    对外提供按钮控件    **/
@interface VoiceButton : UIButton

@property (nonatomic, weak) CALayer * backgroundLayer;

@property (nonatomic, strong) UIImage * normalImage;
@property (nonatomic, strong) UIImage * selectedImage;

/**
  *  @brief  创建按钮，传递按钮不同状态下的图片
  *  @param   normalBgImageName    正常状态下的背景图片
  *  @param   selectedBgImageName   选中状态下的背景图片
  *  @param   normalImageName   正常状态下的（前景）图片
  *  @param   selectedImageName  选中状态下的（前景）图片
  */
+ (instancetype)buttonWithFrame:(CGRect)frame
      normalBackgroundImageName:(NSString *)normalBgImageName
    selectedBackgroundImageName:(NSString *)selectedBgImageName
                normalImageName:(NSString *)normalImageName
              selectedImageName:(NSString *)selectedImageName
                   isMicrophone:(BOOL)isMicrophone;
@end
