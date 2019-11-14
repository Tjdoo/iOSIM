//
//  LoginProgress.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "LoginProgress.h"
#import "MBProgressHUD.h"

// 超时时间
static NSTimeInterval time_out = 6000;

@implementation LoginProgress
{
    @private
        MBProgressHUD * __progressHUD;
        NSTimer * __timer;
}

- (instancetype)initWithDelegate:(id<LoginProgressDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)showProgress:(BOOL)show onView:(UIView *)view
{
    [self __showMBProgressHUD:show onView:view];
    [self __stopTimer];
    
    if (show) {
        // 自动启动
        __timer = [NSTimer scheduledTimerWithTimeInterval:time_out / 1000.0
                                                   target:self
                                                 selector:@selector(__timeout)
                                                 userInfo:nil repeats:NO];
    }
}

/**
  *  @brief   登录超时
  */
- (void)__timeout
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginTimeOut)]) {
        [self.delegate loginTimeOut];
    }
}

/**
  *  @brief   显示、隐藏进度提示
  */
- (void)__showMBProgressHUD:(BOOL)show onView:(UIView *)view
{
    if (show) {
        if (__progressHUD == nil) {
            __progressHUD = [[MBProgressHUD alloc] initWithView:view];
            [view addSubview:__progressHUD];
            __progressHUD.label.text = @"登录中...";
        }
        [__progressHUD showAnimated:YES];
    }
    else {
        if (__progressHUD) {
            [__progressHUD hideAnimated:NO];
        }
    }
}

/**
  *  @brief   停止定时器
  */
- (void)__stopTimer
{
    if (__timer) {
        if ([__timer isValid]) {
            [__timer invalidate];
        }
        __timer = nil;
    }
}

@end
