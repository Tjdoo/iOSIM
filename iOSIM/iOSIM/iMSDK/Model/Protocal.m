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
//  Protocal.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "Protocal.h"
#import "DataKits.h"
#import "RMMapper.h"
#import "ProtocalFactory.h"


@interface Protocal ()
{
    int __retryCount;
}
@end


@implementation Protocal

/// 4 个参数
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
{
    return [Protocal initWithType:type
                          content:dataContent
                             from:from
                               to:to
                              qos:YES
                               fp:nil
                               tu:-1];
}

/// 5 个参数
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
                          tu:(int)typeu
{
    return [Protocal initWithType:type
                          content:dataContent
                             from:from
                               to:to
                              qos:YES
                               fp:nil
                               tu:typeu];
}

/// 7 个参数
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
                         qos:(bool)QoS
                          fp:(NSString *)fingerPrint
                          tu:(int)typeu
{
    return [Protocal initWithType:type
                          content:dataContent
                             from:from
                               to:to
                              qos:QoS
                               fp:fingerPrint
                               bg:NO
                               tu:typeu];
}

/// 8 个参数
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
                         qos:(bool)QoS
                          fp:(NSString *)fingerPrint
                          bg:(bool)bridge
                          tu:(int)typeu
{
    Protocal * p = [[Protocal alloc] init];
    
    p.type        = type;
    p.dataContent = dataContent;
    p.from        = from;
    p.to          = to;
    p.QoS         = QoS;
    p.bridge      = bridge;
    p.typeu       = typeu;

    if(QoS && fingerPrint == nil)
        p.fp = [Protocal genFingerPrint];
    else
        p.fp = fingerPrint;
    
    return p;
}

- (instancetype)init
{
    if(self = [super init]) {
        self.type    = 0;
        self.from    = @"-1";
        self.to      = @"-1";
        self.QoS     = NO;
        self.bridge  = NO;
        self.typeu   = -1;
        __retryCount = 0;
    }
    return self;
}

- (int)retryCount
{
    return __retryCount;
}

- (void)increaseRetryCount
{
    __retryCount += 1;
}

- (NSString *)toJsonString
{
    return [DataKits stringWithData:[self toData]];
}

- (NSData *)toData
{
    NSMutableDictionary * dic = [self __toMutableDictionary:YES];
    return [DataKits dataWithDictionary:dic];
}

- (Protocal *)clone
{
    NSMutableDictionary * dic = [self __toMutableDictionary:YES];
    Protocal * pepFromJASON = [RMMapper objectWithClass:[Protocal class] fromDictionary:dic];
    return pepFromJASON;
}

+ (NSString *)genFingerPrint
{
    return [DataKits generateUUID];
}


#pragma mark - Private

- (NSMutableDictionary *)__toMutableDictionary:(BOOL)deleteRetryCountProperty
{
    NSMutableDictionary * dic = [DataKits mutableDictionaryWithObject:self];
    // 移除 retryCount 值
    if(deleteRetryCountProperty)
        [dic removeObjectForKey:@"retryCount"];
    
    return dic;
}

@end
