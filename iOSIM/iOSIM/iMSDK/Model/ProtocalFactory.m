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
//  ProtocalFactory.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/23.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "ProtocalFactory.h"
#import "DataKits.h"
#import "Protocal.h"
#import "ProtocalType.h"
#import "PKeepAliveResponse.h"
#import "PKeepAlive.h"
#import "PLoginInfo.h"
#import "PLoginInfoResponse.h"
#import "PErrorResponse.h"


@implementation ProtocalFactory

//////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Parse
//////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (Protocal *)parse:(NSData *)data
{
    return [ProtocalFactory parse:data toClass:Protocal.class];
}

+ (id)parse:(NSData *)data toClass:(Class)cls
{
    return [DataKits parseDictionary:[DataKits dictionaryWithData:data] toClass:cls];
}

+ (id)parseString:(NSString *)jsonString toClass:(Class)cls
{
    NSData * data = [DataKits dataWithString:jsonString];
    
    return [DataKits parseDictionary:[DataKits dictionaryWithData:data] toClass:cls];
}

+ (PErrorResponse *)parseResponseErrorInfo:(NSString *)string
{
    return [ProtocalFactory parseString:string toClass:[PErrorResponse class]];
}

+ (PLoginInfoResponse *)parseLoginResponseInfo:(NSString *)string
{
    return [ProtocalFactory parseString:string toClass:[PLoginInfoResponse class]];
}

+ (PKeepAliveResponse *)__parsePKeepAliveResponse:(NSString *)string
{
    return [ProtocalFactory parseString:string toClass:[PKeepAliveResponse class]];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Create
//////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSString *)__create:(id)protocalDataContentObj
{
    NSDictionary * dict = [DataKits mutableDictionaryWithObject:protocalDataContentObj];
    
    return [DataKits stringWithData:[DataKits dataWithDictionary:dict]];
}

/**
  *  @brief   心跳包
  */
+ (Protocal *)createPKeepAlive:(NSString *)from_user_id
{
    NSString * dataContent = [ProtocalFactory __create:[[PKeepAlive alloc] init]];
    
    return [Protocal initWithType:FROM_CLIENT_TYPE_OF_KEEP_ALIVE
                          content:dataContent
                             from:from_user_id
                               to:@"0"];
}

/**
  *  @brief   退出登录消息
  */
+ (Protocal *)createPLoginoutInfo:(NSString *)user_id
{
    return [Protocal initWithType:FROM_CLIENT_TYPE_OF_LOGOUT
                          content:nil
                             from:user_id
                               to:@"0"];
}

/**
  *  @brief   登录消息
  */
+ (Protocal *)createPLoginInfo:(NSString *)loginUserId
                     withToken:(NSString *)loginToken
                      andExtra:(NSString *)extra
{
    PLoginInfo * li = [[PLoginInfo alloc] init];
    li.loginUserId = loginUserId;
    li.loginToken  = loginToken;
    li.extra       = extra;
    NSString * dataContent = [ProtocalFactory __create:li];
    
    return [Protocal initWithType:FROM_CLIENT_TYPE_OF_LOGIN
                          content:dataContent
                             from:loginUserId//@"-1"
                               to:@"0"];
}

/**
  *  @brief   普通消息
  */
+ (Protocal *)createCommonData:(NSString *)dataContent
                    fromUserId:(NSString *)from_user_id
                      toUserId:(NSString *)to_user_id
{
    return [ProtocalFactory createCommonData:dataContent
                                  fromUserId:from_user_id
                                    toUserId:to_user_id
                                         qos:YES
                                          fp:nil
                                   withTypeu:-1];
}

+ (Protocal *)createCommonData:(NSString *)dataContent
                    fromUserId:(NSString *)from_user_id
                      toUserId:(NSString *)to_user_id
                     withTypeu:(int)typeu
{
    return [ProtocalFactory createCommonData:dataContent
                                  fromUserId:from_user_id
                                    toUserId:to_user_id
                                         qos:YES
                                          fp:nil
                                   withTypeu:typeu];
}

+ (Protocal *)createCommonData:(NSString *)dataContent
                    fromUserId:(NSString *)from_user_id
                      toUserId:(NSString *)to_user_id
                           qos:(bool)QoS
                            fp:(NSString *)fingerPrint
                     withTypeu:(int)typeu
{
    return [Protocal initWithType:FROM_CLIENT_TYPE_OF_COMMON_DATA
                          content:dataContent
                             from:from_user_id
                               to:to_user_id
                              qos:QoS
                               fp:fingerPrint
                               tu:typeu];
}

/**
  *  @brief   应答消息
  */
+ (Protocal *)createRecivedBack:(NSString *)from_user_id
                       toUserId:(NSString *)to_user_id
                withFingerPrint:(NSString *)recievedMessageFingerPrint
{
    return [ProtocalFactory createRecivedBack:from_user_id
                                     toUserId:to_user_id
                              withFingerPrint:recievedMessageFingerPrint
                                    andBridge:NO];
}

+ (Protocal *)createRecivedBack:(NSString *)from_user_id
                       toUserId:(NSString *)to_user_id
                withFingerPrint:(NSString *)recievedMessageFingerPrint
                      andBridge:(bool)bridge
{
    return [Protocal initWithType:FROM_CLIENT_TYPE_OF_RECIVED
                          content:recievedMessageFingerPrint
                             from:from_user_id
                               to:to_user_id
                              qos:NO
                               fp:nil
                               bg:bridge
                               tu:-1];
}

@end
