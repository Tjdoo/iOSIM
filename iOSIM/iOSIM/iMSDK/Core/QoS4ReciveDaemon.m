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
//  ProtocalQoS4ReciveProvider.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/23.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "QoS4ReciveDaemon.h"
#import "ClientCoreSDK.h"
#import "DataKits.h"
#import "Protocal.h"
#import "NSMutableDictionary+Ext.h"


static int __check_interval = 5 * 60 * 1000;
static int __messages_valid_time = 10 * 60 * 1000; // 信息留存时长

@interface QoS4ReciveDaemon ()

@property (nonatomic, strong) NSMutableDictionary * recievedMessages;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL excuting;
@property (nonatomic, strong) NSTimer * timer;

@end


@implementation QoS4ReciveDaemon

static QoS4ReciveDaemon * __instance__ = nil;

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
        NSLog(@"ProtocalQoS4ReciveProvider init finish!");
        
        self.running = NO;
        self.excuting = NO;
        self.recievedMessages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
  *  @brief   启动线程
  */
- (void)startup:(BOOL)immediately
{
    // 先停止
    [self stop];

    if(self.recievedMessages != nil && [self.recievedMessages count] > 0) {
        NSArray * keyArr = [self.recievedMessages allKeys];
        for (NSString * key in keyArr) {
            [self __putImpl:key];
        }
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:__check_interval / 1000
                                                  target:self
                                                selector:@selector(__run)
                                                userInfo:nil
                                                 repeats:YES];
    // 立即启动
    if(immediately) {
        [self.timer fire];
    }
    self.running = YES;
    
    // form DEBUG
    if(self.debugObserver != nil)
        self.debugObserver(nil, [NSNumber numberWithInt:1]);
}

/**
  *  @brief   停止
  */
- (void)stop
{
    // 注销定时器
    if(self.timer != nil) {
        if([self.timer isValid]) {
           [self.timer invalidate];
        }
        self.timer = nil;
    }
    self.running = NO;
    
    // form DEBUG
    if(self.debugObserver != nil)
        self.debugObserver(nil, [NSNumber numberWithInt:0]);
}

- (BOOL)isRunning
{
    return self.running;
}

- (void)addRecieved:(Protocal *)p
{
    if(p != nil && p.QoS)
        [self addRecievedWithFingerPrint:p.fp];
}

/**
  *  @brief   向列表中加入一个包的特征指纹
  */
- (void)addRecievedWithFingerPrint:(NSString *) fingerPrintOfProtocal
{
    if(fingerPrintOfProtocal == nil) {
        NSLog(@"无效的 fingerPrintOfProtocal==null!");
        return;
    }
    
    // 已经存在接收列表中
    if([self.recievedMessages containsKey:fingerPrintOfProtocal])
        NSLog(@"【IMCORE】【QoS接收方】指纹为 %@ 的消息已经存在于接收列表中，该消息重复了（原理可能是对方因未收到应答包而错误重传导致），更新收到时间戳哦.", fingerPrintOfProtocal);
    
    [self __putImpl:fingerPrintOfProtocal];
}

- (BOOL)hasRecieved:(NSString *)fingerPrintOfProtocal
{
    return [self.recievedMessages containsKey:fingerPrintOfProtocal];
}

- (void)clear
{
    [self.recievedMessages removeAllObjects];
}

- (unsigned long) size
{
    return [self.recievedMessages count];
}


#pragma mark - Private
/**
  *  @brief   发送
  */
- (void)__run
{
    if(!self.excuting) {
        self.excuting = YES;
        
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【QoS接收方】++++++++++ START 暂存处理线程正在运行中，当前长度 %li", (unsigned long)[self.recievedMessages count]);
        
        NSArray * keyArr = [self.recievedMessages allKeys];
        for (NSString * key in keyArr) {
            NSNumber * objectValue = [self.recievedMessages objectForKey:key];
            long delta = [DataKits getTimeStampWithMillisecond_l] - objectValue.longValue;
            
            // 超过存活时长
            if(delta >= __messages_valid_time) {
                if([ClientCoreSDK isEnabledDebug]) {
                    NSLog(@"【IMCORE】【QoS接收方】指纹为%@的包已生存%li 毫秒(最大允许%d毫秒), 马上将删除之.", key, delta, __messages_valid_time);
                }
                [self.recievedMessages removeObjectForKey:key];
            }
        }
    }
    
    if([ClientCoreSDK isEnabledDebug]) {
        NSLog(@"【IMCORE】【QoS接收方】++++++++++ END 暂存处理线程正在运行中，当前长度 %li", (unsigned long)[self.recievedMessages count]);
    }
    self.excuting = NO;
    
    // form DEBUG
    if(self.debugObserver != nil)
        self.debugObserver(nil, [NSNumber numberWithInt:2]);
}

/**
  *  @brief   将指定的特征指纹存入字典。key - 特征指纹；value = 时间戳
  */
- (void)__putImpl:(NSString *)fingerPrintOfProtocal
{
    if(fingerPrintOfProtocal != nil)
        [self.recievedMessages setValue:@([DataKits getTimeStampWithMillisecond_l])
                                 forKey:fingerPrintOfProtocal];
}


@end
