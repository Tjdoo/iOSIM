//
//  LoginProgress.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>


@protocol LoginProgressDelegate <NSObject>
@optional

- (void)loginTimeOut;

@end


/**   登录进度   **/
@interface LoginProgress : NSObject

@property (nonatomic, weak) id<LoginProgressDelegate> delegate;

- (instancetype)initWithDelegate:(id<LoginProgressDelegate>)delegate;

/**
  *  @brief   在 view 上显示登录进度视图
  */
- (void)showProgress:(BOOL)show onView:(UIView *)view;

@end
