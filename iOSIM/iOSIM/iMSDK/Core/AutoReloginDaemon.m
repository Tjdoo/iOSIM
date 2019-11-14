//  ----------------------------------------------------------------------
//  Copyright (C) 2017  即时通讯网(52im.net) & Jack Jiang.
//  The MobileIMSDK_X (MobileIMSDK v3.x) Project.
//  All rights reserved.
//
//  > Github地址: https://github.com/JackJiang2011/MobileIMSDK
//  > 文档地址: http://www.52im.net/forum-89-1.html
//  > 即时通讯技术社区：http://www.52im.net/
//  > 即时通讯技术交流群：320837163 (http://www.52im.net/topic-qqgroup.html)
//
//  "即时通讯网(52im.net) - 即时通讯开发者社区!" 推荐开源工程。
//
//  如需联系作者，请发邮件至 jack.jiang@52im.net 或 jb2011@163.com.
//  ----------------------------------------------------------------------
//
//  AutoReloginDaemon.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/24.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "AutoReloginDaemon.h"
#import "ClientCoreSDK.h"
#import "UDPDataSender.h"


static int __autoReloginInterval = 2000;

@interface AutoReloginDaemon ()

@property (nonatomic, assign) BOOL autoReLoginRunning;
@property (nonatomic, assign) BOOL excuting;
@property (nonatomic, strong) NSTimer * timer;

@end


@implementation AutoReloginDaemon

static AutoReloginDaemon * __instance__;

+ (instancetype)sharedInstance
{
    if (__instance__ == nil) {
        __instance__ = [[self alloc] init];
    }
    return __instance__;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance__ = [super allocWithZone:zone];
    });
    return __instance__;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"AutoReloginDaemon init finish!");
        
        self.autoReLoginRunning = NO;
        self.excuting = NO;
    }
    return self;
}

/**
  *  @brief   启动线程
  */
- (void)start:(BOOL)immediately
{
    [self stop];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:__autoReloginInterval / 1000
                                                  target:self
                                                selector:@selector(__run)
                                                userInfo:nil
                                                 repeats:YES];
    // 立即开启计时器
    if(immediately) {
        [self.timer fire];
    }
    self.autoReLoginRunning = YES;
    
    // form DEBUG
    if(self.debugObserver != nil) {
        self.debugObserver(nil, @(1));
    }
}

/**
  *  @brief   停止线程
  */
- (void)stop
{
    // 销毁定时器
    if(self.timer){
        if([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    self.autoReLoginRunning = NO;
    
    // form DEBUG
    if(self.debugObserver != nil) {
        self.debugObserver(nil, @(0));
    }
}

/**
  *  @brief  定时重连
  */
- (void)__run
{
    if(!self.excuting) {
        self.excuting = YES;
        
        // debug 信息
        if([ClientCoreSDK isEnabledDebug]) {
            NSLog(@"自动重连线程执行中, autoReLogin? %d...", [ClientCoreSDK isAutoRelogin]);
        }
        
        int code = -1;
        
        // 允许自动重连
        if([ClientCoreSDK isAutoRelogin]) {
            // 当前用户信息
            NSString * curLoginUserId = [ClientCoreSDK sharedInstance].loginUserID;
            NSString * curLoginToken  = [ClientCoreSDK sharedInstance].loginToken;
            NSString * curLoginExtra  = [ClientCoreSDK sharedInstance].loginExtraInfo;
            
            // 发送登录信息
            code = [[UDPDataSender sharedInstance] sendLogin:curLoginUserId
                                                   withToken:curLoginToken
                                                    andExtra:curLoginExtra];
            
            // form DEBUG
            if(self.debugObserver != nil) {
                self.debugObserver(nil, [NSNumber numberWithInt:2]);
            }
        }
        
        // 重新登录成功
        if(code == 0) {
            if([ClientCoreSDK isEnabledDebug])
                NSLog(@"自动重连数据包已发出(iOS上无需自己启动UDP接收线程, GCDAsyncUDPTask 自行解决了).");
        }
        
        self.excuting = NO;
    }
}


#pragma mark - SET & GET

+ (void)setAutoReloginInterval:(int)autoReLoginInterval
{
    __autoReloginInterval = autoReLoginInterval;
}

+ (int)autoReloginInterval
{
    return __autoReloginInterval;
}

@end
