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
//  UDPDataSender.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/27.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "UDPDataSender.h"
#import "ProtocalFactory.h"
#import "ClientCoreSDK.h"
#import "KeepAliveDaemon.h"
#import "QoS4SendDaemon.h"
#import "ErrorCode.h"
#import "GCDAsyncUdpSocket.h"
#import "UDPSocketProvider.h"
#import "ConfigEntity.h"
#import "CompletionDefine.h"


@implementation UDPDataSender

static UDPDataSender * __instance__ = nil;

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


#pragma mark - Login

- (int)sendLogin:(NSString *)loginUserId withToken:(NSString *)loginToken
{
    return [self sendLogin:loginUserId withToken:loginToken andExtra:nil];
}

/**
  *  @brief   发送登录信息
  */
- (int)sendLogin:(NSString *)loginUserId withToken:(NSString *)loginToken andExtra:(NSString *)extra
{
    // 核心库初始化
    [[ClientCoreSDK sharedInstance] initCoreSDK];
    
    NSData * b = [[ProtocalFactory createPLoginInfo:loginUserId
                                          withToken:loginToken
                                           andExtra:extra] toData];
    // 实际发送
    int code = [self __sendImpl:b];
    
    // 发送成功后存储当前用户数据
    if(code == 0) {
        [[ClientCoreSDK sharedInstance] setLoginUserID:loginUserId];
        [[ClientCoreSDK sharedInstance] setLoginToken:loginToken];
        [[ClientCoreSDK sharedInstance] setLoginExtraInfo:extra];
    }
    
    return code;
}

/**
  *  @brief   注销登录
  */
- (int)sendLogout
{
    int code = COMMON_CODE_OK;
    // 已登录状态
    if([ClientCoreSDK sharedInstance].isLogin) {
        
        NSString * loginUserId = [ClientCoreSDK sharedInstance].loginUserID;
        NSData * b = [[ProtocalFactory createPLoginoutInfo:loginUserId] toData];
        
        // 实际发送
        code = [self __sendImpl:b];
        if(code == 0) {
            // 停止保活线程
            [[KeepAliveDaemon sharedInstance] stop];
            // 修改登录状态 -》NO
            [[ClientCoreSDK sharedInstance] setLogin:NO];
        }
    }
    
    // 释放资源
    [[ClientCoreSDK sharedInstance] releaseCoreSDK];
    
    return code;
}


#pragma mark - Keep Alive
/**
  *  @brief   发送心跳包
  */
- (int)sendKeepAlive
{
    NSString * currentLoginUserId = [[ClientCoreSDK sharedInstance] loginUserID];
    NSData * b = [[ProtocalFactory createPKeepAlive:currentLoginUserId] toData];
    
    return [self __sendImpl:b];
}


#pragma mark - Common

- (int)sendCommonDataWithStr:(NSString *)dataContentWidthStr toUserId:(NSString *)to_user_id
{
    return [self sendCommonDataWithStr:dataContentWidthStr toUserId:to_user_id withTypeu:-1];
}

/**
  *  @brief   发送普通消息。没有 fingerPrint，也就是不使用 QoS 机制
  */
- (int)sendCommonDataWithStr:(NSString *)dataContentWidthStr
                    toUserId:(NSString *)to_user_id
                   withTypeu:(int)typeu
{
    NSString * currentLoginUserId = [[ClientCoreSDK sharedInstance] loginUserID];
    Protocal * p = [ProtocalFactory createCommonData:dataContentWidthStr
                                          fromUserId:currentLoginUserId
                                            toUserId:to_user_id
                                           withTypeu:typeu];
    return [self sendCommonData:p];
}

/**
  *  @brief   发送普通消息。使用 QoS 机制
  */
- (int)sendCommonDataWithStr:(NSString *)dataContentWidthStr
                    toUserId:(NSString *)to_user_id
                         qos:(BOOL)QoS
                          fp:(NSString *)fingerPrint
                   withTypeu:(int)typeu
{
    NSString * currentLoginUserId = [[ClientCoreSDK sharedInstance] loginUserID];
    Protocal * p = [ProtocalFactory createCommonData:dataContentWidthStr
                                          fromUserId:currentLoginUserId
                                            toUserId:to_user_id
                                                 qos:QoS
                                                  fp:fingerPrint
                                           withTypeu:typeu];
    return [self sendCommonData:p];
}

/**
  *  @brief   根方法
  */
- (int)sendCommonData:(Protocal *)p
{
    @synchronized(self)
    {
        if(p != nil) {
            int code = [self __sendImpl:[p toData]];
            
            if(code == 0) {
                [self __putToQoS:p];
            }
            return code;
        }
        else
            return COMMON_INVALID_PROTOCAL;
    }
}


#pragma mark - Private
/**
  *  @brief   实际发送消息。底层使用 GCDAsyncUdpSocket
  */
- (int)__sendImpl:(NSData *)data
{
    if(![[ClientCoreSDK sharedInstance] isInitialed])
        return ForC_CLIENT_SDK_NO_INITIALED;
    
    if(![ClientCoreSDK sharedInstance].isExistenceNetwork) {
        NSLog(@"本地无网络，send数据没有继续!");
        return ForC_LOCAL_NETWORK_NOT_WORKING;
    }
    
    GCDAsyncUdpSocket * ds = [[UDPSocketProvider sharedInstance] localUDPSocket];
    // UDP socket 未连接
    if(ds != nil && ![ds isConnected]) {
        ConnectionCompletion observerBlock = ^(BOOL connectResult) {
            if(connectResult) {
                // 连接成功，发送数据
                [self __send:ds withData:data];
            }
            else {
                
            }
        };
        // 设置 socket 连接的回调
        [[UDPSocketProvider sharedInstance] setConnectionObserver:observerBlock];
        
        // 发起 socket 连接
        NSError * connectError = nil;
        int connectCode = [[UDPSocketProvider sharedInstance] tryConnectToHostWithSocket:ds
                                                                                   error:&connectError
                                                                              completion:observerBlock];
        // 连接失败
        if(connectCode != COMMON_CODE_OK)
            return connectCode;
        else
            return COMMON_CODE_OK;
    }
    else {
        return [self __send:ds withData:data] ? COMMON_CODE_OK : COMMON_DATA_SEND_FAILD;
    }
}

- (BOOL)__send:(GCDAsyncUdpSocket *)skt withData:(NSData *)d
{
    BOOL success = YES;

    if(skt != nil && d != nil) {
        if([skt isConnected]) {
            [skt sendData:d withTimeout:-1 tag:0];
        }
    }
    else {
        success = NO;
        NSLog(@"在send()UDP数据报时没有成功执行，原因是：skt==null || d == null!");
    }
    
    return success;
}

/**
  *  @brief   存储已发送的 QoS 消息
  */
- (void)__putToQoS:(Protocal *)p
{
    if(p.QoS && ![[QoS4SendDaemon sharedInstance] exist:p.fp]) {
        [[QoS4SendDaemon sharedInstance] put:p];
    }
}

@end
