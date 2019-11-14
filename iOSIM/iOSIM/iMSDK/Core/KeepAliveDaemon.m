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
//  KeepAliveDaemon.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/24.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "KeepAliveDaemon.h"
#import "DataKits.h"
#import "UDPDataSender.h"
#import "ClientCoreSDK.h"


static int __networkConnectionTimeOut = 10 * 1000;
static int __keepAliveinterval = 3000;

@interface KeepAliveDaemon ()

@property (nonatomic, assign) BOOL keepAliveRunning;
@property (nonatomic, assign) long lastGetKeepAliveResponseFromServerTimstamp;
@property (nonatomic, assign) BOOL excuting;
@property (nonatomic, strong) NSTimer * timer;

@end


@implementation KeepAliveDaemon

static KeepAliveDaemon * __instance__ = nil;

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
        NSLog(@"KeepAliveDaemon init finish!");
        
        self.keepAliveRunning = NO;
        self.lastGetKeepAliveResponseFromServerTimstamp = 0;
        self.excuting = NO;
    }
    return self;
}

/**
  *  @brief   开启线程
  */
- (void)start:(BOOL)immediately
{
    [self stop];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:__keepAliveinterval / 1000
                                                  target:self
                                                selector:@selector(__run)
                                                userInfo:nil
                                                 repeats:YES];
    // 立即开启
    if(immediately) {
        [self.timer fire];
    }
    self.keepAliveRunning = YES;
    
    // form DEBUG
    if(self.debugObserver != nil) {
        self.debugObserver(nil, [NSNumber numberWithInt:1]);
    }
}

/**
  *  @brief   停止线程
  */
- (void)stop
{
    // 销毁定时器
    if(self.timer) {
        if([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    self.keepAliveRunning = NO;
    self.lastGetKeepAliveResponseFromServerTimstamp = 0;
    
    // for DEBUG
    if(self.debugObserver != nil) {
        self.debugObserver(nil, [NSNumber numberWithInt:0]);
    }
}

/**
  *  @brief   定时发送心跳包
  */
- (void)__run
{
    if(!self.excuting) {
        self.excuting = YES;
        

        // debug 信息
        if([ClientCoreSDK isEnabledDebug]) {
            NSLog(@"心跳线程执行中...");
        }
        
        BOOL willStop = NO;

        // 发送心跳包
        int code = [[UDPDataSender sharedInstance] sendKeepAlive];
        
        // form DEBUG
        if(self.debugObserver != nil) {
            self.debugObserver(nil, [NSNumber numberWithInt:2]);
        }
        
        // 是否第一次发送心跳包
        BOOL isInitialedForKeepAlive = (self.lastGetKeepAliveResponseFromServerTimstamp == 0);
        
        if (isInitialedForKeepAlive) {
            self.lastGetKeepAliveResponseFromServerTimstamp = [DataKits getTimeStampWithMillisecond_l];
        }
        else {
            long now = [DataKits getTimeStampWithMillisecond_l];
            // 超时
            if(now - self.lastGetKeepAliveResponseFromServerTimstamp >= __networkConnectionTimeOut) {
                // 停止发送心跳包
                [self stop];
                if(self.networkConnectionLostObserver != nil) {
                    self.networkConnectionLostObserver(nil, nil);
                }
                willStop = YES;
            }
        }
        
        self.excuting = NO;
        if(!willStop) {
            ;
        }
        else {
            [self stop];
        }
    }
}

- (void)updateGetKeepAliveResponseFromServerTimstamp
{
    self.lastGetKeepAliveResponseFromServerTimstamp = [DataKits getTimeStampWithMillisecond_l];
}


#pragma mark - SET & GET

+ (void)setKeepAliveinterval:(int)keepAliveTimeWithMils
{
    __keepAliveinterval = keepAliveTimeWithMils;
}

+ (int)keepAliveinterval
{
    return __keepAliveinterval;
}

+ (void)setNetworkConnectionTimeOut:(int)networkConnectionTimeout
{
    __networkConnectionTimeOut = networkConnectionTimeout;
}

+ (int)networkConnectionTimeOut
{
    return __networkConnectionTimeOut;
}

@end
