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
//  UDPDataReciever.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/27.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "UDPDataReciever.h"
#import "Protocal.h"
#import "UDPDataSender.h"
#import "ProtocalFactory.h"
#import "ClientCoreSDK.h"
#import "ErrorCode.h"
#import "QoS4ReciveDaemon.h"
#import "ProtocalType.h"
#import "ChatTransDataPTC.h"
#import "KeepAliveDaemon.h"
#import "PLoginInfoResponse.h"
#import "AutoReloginDaemon.h"
#import "QoS4SendDaemon.h"
#import "PErrorResponse.h"
#import "UDPSocketProvider.h"


@implementation UDPDataReciever

static UDPDataReciever * __instance__ = nil;

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

/**
  *  @brief   解析收到的原始消息数据
  */
- (void)handleProtocal:(NSData *)originalProtocalJSONData
{
    if(originalProtocalJSONData == nil)
        return;
    
    // 解析
    Protocal * pFromServer = [ProtocalFactory parse:originalProtocalJSONData];
    
    // QoS 消息包
    if(pFromServer.QoS) {
        // 解析登录响应包信息 -》 code != 0  -》登录失败
        if(pFromServer.type == FROM_SERVER_TYPE_OF_RESPONSE_LOGIN
           && [ProtocalFactory parseLoginResponseInfo:pFromServer.dataContent].code != 0) {
            
            if([ClientCoreSDK isEnabledDebug])
                NSLog(@"请求登录的服务端响应包，且服务端判定登录失败(即code!=0)，本次无需发送ACK应答包！");
        }
        else {
            // 询问 QoS 接受数据类对象，是否已经收到过这个数据 -》已收到
            if([[QoS4ReciveDaemon sharedInstance] hasRecieved:pFromServer.fp]) {
                
                if([ClientCoreSDK isEnabledDebug]) {
                    NSLog(@"【QoS机制】%@已经存在于发送列表中，这是重复包，通知应用层收到该包！", pFromServer.fp);
                }
                [self __sendRecievedBack:pFromServer];
                
                // 已验证是相同数据，直接返回
                return;
            }

            // 添加本次响应包的特征指纹
            [[QoS4ReciveDaemon sharedInstance] addRecieved:pFromServer];
            [self __sendRecievedBack:pFromServer];
        }
    }
    
    // 根据消息类型，分发处理
    switch(pFromServer.type) {
        case FROM_CLIENT_TYPE_OF_COMMON_DATA:  // 收到普通消息
        {
            if([ClientCoreSDK sharedInstance].chatTransDataDelegate != nil) {
                // 向外通知
                [[ClientCoreSDK sharedInstance].chatTransDataDelegate onTransBuffer:pFromServer.fp
                                                                         withUserId:pFromServer.from
                                                                    andContent:pFromServer.dataContent
                                                                           andTypeu:pFromServer.typeu];
            }
        }
            break;

        case FROM_SERVER_TYPE_OF_RESPONSE_KEEP_ALIVE:  // 心跳保活应答
        {
            if([ClientCoreSDK isEnabledDebug]) {
                NSLog(@"收到服务端回过来的Keep Alive心跳响应包.");
            }
            // 更新时间戳
            [[KeepAliveDaemon sharedInstance] updateGetKeepAliveResponseFromServerTimstamp];
        }
            break;

        case FROM_CLIENT_TYPE_OF_RECIVED:  // 用户发送后，对方收到的应答包
        {
            NSString * theFingerPrint = pFromServer.dataContent;
            if([ClientCoreSDK isEnabledDebug]) {
                NSLog(@"【IMCORE】【QoS】收到%@发过来的指纹为%@的应答包.", pFromServer.from, theFingerPrint);
            }
            // 向外通知
            if([ClientCoreSDK sharedInstance].messageQoSDelegate != nil) {
                [[ClientCoreSDK sharedInstance].messageQoSDelegate messagesBeReceived:theFingerPrint];
            }
            // 从发送队列中删除
            [[QoS4SendDaemon sharedInstance] remove:theFingerPrint];
        }
            break;

        case FROM_SERVER_TYPE_OF_RESPONSE_LOGIN:  // 登录响应包
        {
            // 解析登录响应数据
            PLoginInfoResponse * loginInfoRes = [ProtocalFactory parseLoginResponseInfo:pFromServer.dataContent];
            
            // 登录成功
            if(loginInfoRes.code == 0) {
                // 修改已登录状态 -》YES
                [ClientCoreSDK sharedInstance].login = YES;
                // 停止自动重连线程
                [[AutoReloginDaemon sharedInstance] stop];
                
                // 超时网络断开 block
                ObserverCompletion observerBlock = ^(id observerble, id data) {
                    // 停止发送
                    [[QoS4SendDaemon sharedInstance] stop];
                    // 修改网络连接状态 -》NO
                    [ClientCoreSDK sharedInstance].connectedToServer = NO;
                    if ([ClientCoreSDK sharedInstance].chatBaseDelegate != nil && [[ClientCoreSDK sharedInstance].chatBaseDelegate respondsToSelector:@selector(onLoginMessage:)]) {
                        [[ClientCoreSDK sharedInstance].chatBaseDelegate onLinkCloseMessage:-1];
                    }
                    // 启动自动重连线程
                    [[AutoReloginDaemon sharedInstance] start:YES];
                };

                // 设置网络断开监听
                [[KeepAliveDaemon sharedInstance] setNetworkConnectionLostObserver:observerBlock];
                // 不立即启动保活线程
                [[KeepAliveDaemon sharedInstance] start:NO];
                // 开启 QoS 信息的接受
                [[QoS4ReciveDaemon sharedInstance] startup:YES];
                // 开启 QoS 信息的发送
                [[QoS4SendDaemon sharedInstance] startup:YES];
                // 修改网络连接状态 -》YES
                [ClientCoreSDK sharedInstance].connectedToServer = YES;
            }
            // 登录失败
            else {
                // 关闭 UDP socket
                [[UDPSocketProvider sharedInstance] closeLocalUDPSocket];
                // 修改网络连接状态 -》NO
                [ClientCoreSDK sharedInstance].connectedToServer = NO;
            }
            
            // 向外通知
            if([ClientCoreSDK sharedInstance].chatBaseDelegate != nil && [[ClientCoreSDK sharedInstance].chatBaseDelegate respondsToSelector:@selector(onLoginMessage:)]) {
                [[ClientCoreSDK sharedInstance].chatBaseDelegate onLoginMessage:loginInfoRes.code];
            }
        }
            break;

        case FROM_SERVER_TYPE_OF_RESPONSE_FOR_ERROR:  // 发生错误
        {
            PErrorResponse * errorRes = [ProtocalFactory parseResponseErrorInfo:pFromServer.dataContent];
            
            // 客户端未登录
            if(errorRes.errorCode == ForS_RESPONSE_FOR_UNLOGIN) {
                // 修改已登录状态 -》NO
                [ClientCoreSDK sharedInstance].login = NO;
                
                NSLog(@"收到服务端的“尚未登录”的错误消息，心跳线程将停止，请应用层重新登录.");

                // 停止保活线程
                [[KeepAliveDaemon sharedInstance] stop];
                // 不立即启动自动重连线程
                [[AutoReloginDaemon sharedInstance] start:NO];
            }
            
            // 向外通知
            if([ClientCoreSDK sharedInstance].chatTransDataDelegate != nil && [[ClientCoreSDK sharedInstance].chatTransDataDelegate respondsToSelector:@selector(onErrorResponse:withErrorMsg:)])
            {
                [[ClientCoreSDK sharedInstance].chatTransDataDelegate onErrorResponse:errorRes.errorCode
                                                                         withErrorMsg:errorRes.errorMsg];
            }
            break;
        }
            
        default:
            NSLog(@"收到的服务端消息类型：%d，但目前该类型客户端不支持解析和处理！", pFromServer.type);
            break;
    }
}

/**
  *  @brief   用户回复
  */
- (void)__sendRecievedBack:(Protocal *)pFromServer
{
    if(pFromServer.fp != nil) {
        // 客服端的回复包
        Protocal * p = [ProtocalFactory createRecivedBack:pFromServer.to
                                                 toUserId:pFromServer.from
                                          withFingerPrint:pFromServer.fp
                                                andBridge:pFromServer.bridge];
        int sendCode = [[UDPDataSender sharedInstance] sendCommonData:p];
        
        // 发送成功
        if(sendCode == COMMON_CODE_OK) {
            if([ClientCoreSDK isEnabledDebug])
                NSLog(@"【QoS】向%@发送%@包的应答包成功, from=%@ 【bridge?%d】！", pFromServer.from,pFromServer.fp, pFromServer.to, pFromServer.bridge);
        }
        // 发送失败
        else {
            if([ClientCoreSDK isEnabledDebug])
                NSLog(@"【IMCORE】【QoS】向%@发送%@包的应答包失败了,错误码=%d！", pFromServer.from,pFromServer.fp, sendCode);
        }
    }
    else {
        NSLog(@"【QoS】收到%@发过来需要QoS的包，但它的指纹码却为 null！无法发应答包！", pFromServer.from);
    }
}

@end
