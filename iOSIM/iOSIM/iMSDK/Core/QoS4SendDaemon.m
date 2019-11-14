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
//  ProtocalQoS4SendProvider.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/24.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "QoS4SendDaemon.h"
#import "ClientCoreSDK.h"
#import "Protocal.h"
#import "NSMutableDictionary+Ext.h"
#import "UDPDataSender.h"
#import "ErrorCode.h"
#import "CompletionDefine.h"
#import "DataKits.h"


static int __check_interval = 5000;  // 检查是否有未发送的消息的间隔
static int __messages_just_now_time = 3 * 1000;
static int __qos_try_count = 2;  // QoS 消息重试次数

@interface QoS4SendDaemon ()

@property (nonatomic, retain) NSMutableDictionary * sentMessages;
@property (nonatomic, retain) NSMutableDictionary * sendMessagesTimestamp;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL excuting;
@property (nonatomic, retain) NSTimer * timer;

@end


@implementation QoS4SendDaemon

static QoS4SendDaemon * __instance__ = nil;

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
        NSLog(@"ProtocalQoS4SendProvider init finish!");
        
        self.running = NO;
        self.excuting = NO;
        self.sentMessages = [[NSMutableDictionary alloc] init];
        self.sendMessagesTimestamp = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
  *  @brief   启动线程
  */
- (void)startup:(BOOL)immediately
{
    [self stop];
    
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

/*!
  *  @brief   停止线程
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

- (BOOL)exist:(NSString *)fingerPrint
{
    return [self.sentMessages containsKey:fingerPrint];
}

/**
  *  @brief   增加一个等待发送的消息进质量保证队列
  */
- (void)put:(Protocal *)p
{
    if(p == nil) {
        NSLog(@"Invalid arg p==null.");
        return;
    }

    if(p.fp == nil) {
        NSLog(@"Invalid arg p.getFp() == null.");
        return;
    }
    
    if(!p.QoS) {
        NSLog(@"This protocal is not QoS pkg, ignore it!");
        return;
    }
    
    if([self.sentMessages containsKey:p.fp])
        NSLog(@"【QoS】指纹为 %@ 的消息已经放入了发送质量保证队列，该消息为何会重复？（生成的指纹码重复？还是重复put？）", p.fp);
    
    [self.sentMessages setObject:p forKey:p.fp];
    [self.sendMessagesTimestamp setObject:@([DataKits getTimeStampWithMillisecond_l]) forKey:p.fp];
}

/**
  *  @brief   移除指定指纹特征的消息包
  */
- (void)remove:(NSString *)fingerPrint
{
    if([self.sentMessages containsKey:fingerPrint]) {
        Protocal * p = [self.sentMessages objectForKey:fingerPrint];
        [self.sendMessagesTimestamp removeObjectForKey:fingerPrint];
        [self.sentMessages removeObjectForKey:fingerPrint];
        NSLog(@"【IMCORE】【QoS】指纹为%@的消息已成功从发送质量保证队列中移除(可能是收到接收方的应答也可能是达到了重传的次数上限)，重试次数=%d", fingerPrint, [p retryCount]);
    }
    else {
        NSLog(@"【IMCORE】【QoS】指纹为%@的消息已成功从发送质量保证队列中移除(可能是收到接收方的应答也可能是达到了重传的次数上限)，重试次数=none呵呵.", fingerPrint);
    }
}

- (void)clear
{
    [self.sentMessages removeAllObjects];
    [self.sendMessagesTimestamp removeAllObjects];
}

- (unsigned long)size
{
    return [self.sentMessages count];
}


#pragma mark - Private
/**
  *  @brief   核心方法
  */
- (void)__run
{
    if(!self.excuting) {
        NSMutableArray * lostMessages = [[NSMutableArray alloc] init];
        
        self.excuting = YES;
        
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【IMCORE】【QoS】=========== 消息发送质量保证线程运行中, 当前需要处理的列表长度为 %li ...", (unsigned long)[self.sentMessages count]);
        
        for (NSString * key in [self.sentMessages allKeys]) {
            
            Protocal * p = [self.sentMessages objectForKey:key];
            
            if(p != nil && p.QoS == YES) {
                
                // 超过重传次数
                if([p retryCount] >= __qos_try_count) {
                    if([ClientCoreSDK isEnabledDebug])
                        NSLog(@"【IMCORE】【QoS】指纹为 %@ 的消息包重传次数已达 %d (最多 %d 次)上限，将判定为丢包！", p.fp, [p retryCount], __qos_try_count);
                    
                    // 复制了一份
                    [lostMessages addObject:[p clone]];
                    [self remove:p.fp];
                }
                else {
                    NSNumber * objectValue = [self.sendMessagesTimestamp objectForKey:key];
                    long delta = [DataKits getTimeStampWithMillisecond_l] - objectValue.longValue;
                    
                    if(delta <= __messages_just_now_time) {
                        if([ClientCoreSDK isEnabledDebug])
                            NSLog(@"【IMCORE】【QoS】指纹为%@的包距\"刚刚\"发出才%li ms(<=%d ms将被认定是\"刚刚\"), 本次不需要重传哦.", key, delta, __messages_just_now_time);
                    }
                    else {
                        // 发送消息
                        int sendCode = [[UDPDataSender sharedInstance] sendCommonData:p];
                        
                        // 发送成功
                        if(sendCode == COMMON_CODE_OK) {
                            // 增加重传次数
                            [p increaseRetryCount];
                            
                            if([ClientCoreSDK isEnabledDebug])
                                NSLog(@"【IMCORE】【QoS】指纹为%@的消息包已成功进行重传，此次之后重传次数已达%d(最多%d次).", p.fp, [p retryCount], __qos_try_count);
                        }
                        // 重传失败
                        else {
                            NSLog(@"【IMCORE】【QoS】指纹为%@的消息包重传失败，它的重传次数之前已累计为%d(最多%d次).", p.fp, [p retryCount], __qos_try_count);
                        }
                    }
                }
            }
            else {
                [self remove:key];
            }
        }
        
        if(lostMessages != nil && [lostMessages count] > 0) {
            [self __notifyMessageLost:lostMessages];
        }
        
        self.excuting = NO;
        
        // form DEBUG
        if(self.debugObserver != nil)
            self.debugObserver(nil, [NSNumber numberWithInt:2]);
    }
}

/**
  *  @brief  向外通知重传失败的消息包数组
  */
- (void)__notifyMessageLost:(NSMutableArray *)lostMsgs
{
    if([ClientCoreSDK sharedInstance].messageQoSDelegate != nil && [[ClientCoreSDK sharedInstance].messageQoSDelegate respondsToSelector:@selector(messagesLost:)]) {
        [[ClientCoreSDK sharedInstance].messageQoSDelegate messagesLost:lostMsgs];
    }
}

@end
