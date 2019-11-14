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
//  UDPSocketProvider.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "UDPSocketProvider.h"
#import "GCDAsyncUdpSocket.h"
#import "ClientCoreSDK.h"
#import "ConfigEntity.h"
#import "ErrorCode.h"
#import "UDPDataReciever.h"
#import "CompletionDefine.h"


/**   遵守 GCDAsyncUdpSocketDelegate 代理，实现代理方法   **/
@interface UDPSocketProvider () <GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket * __localUDPSocket;
}
@property (nonatomic, copy) ConnectionCompletion connectionCompletionOnce;

@end


@implementation UDPSocketProvider

static UDPSocketProvider * __instance__ = nil;

+ (UDPSocketProvider *)sharedInstance
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
  *  @brief   重新创建并返回 GCDAsyncUdpSocket 对象
  */
- (GCDAsyncUdpSocket *)resetLocalUDPSocket
{
    // 先关闭当前的 socket
    [self closeLocalUDPSocket];
    
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"new GCDAsyncUdpSocket >>> ing");

    // 创建
    __localUDPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                     delegateQueue:dispatch_get_main_queue()];
    // 绑定监听的端口
    NSInteger port = [ConfigEntity localUdpSendAndListeningPort];
    if (port < 0 || port > 65535)
        port = 0;
    
    NSError * error = nil;
    if (![__localUDPSocket bindToPort:port error:&error]) {
        NSLog(@"localUDPSocket创建时出错，原因是 bindToPort: %@", error);
        return nil;
    }

    // 开始收取信息
    if (![__localUDPSocket beginReceiving:&error]) {
        [self closeLocalUDPSocket];
        
        NSLog(@"localUDPSocket创建时出错，原因是 beginReceiving: %@", error);
        return nil;
    }
    
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"localUDPSocket创建已成功完成.");
    
    // 创建成功并返回
    return __localUDPSocket;
}

/**
  *  @brief   尝试连接指定的 socket
  */
- (int)tryConnectToHostWithSocket:(GCDAsyncUdpSocket *)skt
                            error:(NSError *__autoreleasing *)error
                       completion:(ConnectionCompletion)completion
{
    // 未设置监听的服务器 ip
    if([ConfigEntity serverIp] == nil) {
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【IMCORE】tryConnectToHost到目标主机%@:%d没有成功，ConfigEntity.server_ip==null!", [ConfigEntity serverIp], [ConfigEntity serverPort]);
        return ForC_TO_SERVER_NET_INFO_NOT_SETUP;
    }
    
    if(completion != nil)
       [self setConnectionCompletionOnce:completion];
    
    NSError * connectError = nil;

    // GCDAsyncUdpSocket 连接
    [skt connectToHost:[ConfigEntity serverIp]
                onPort:[ConfigEntity serverPort]
                 error:&connectError];
    
    // 连接失败
    if(connectError != nil) {
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【IMCORE】localUDPSocket尝试发出连接到目标主机%@:%d的动作时出错了：%@.(此前isConnected?%d)", [ConfigEntity serverIp], [ConfigEntity serverPort], connectError, [skt isConnected]);
        return ForC_BAD_CONNECT_TO_SERVER;
    }
    // 连接成功
    else {
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【IMCORE】localUDPSocket尝试发出连接到目标主机%@:%d的动作成功了.(此前isConnected?%d)", [ConfigEntity serverIp], [ConfigEntity serverPort], [skt isConnected]);
        return COMMON_CODE_OK;
    }
}

/**
  *  @brief   获取 GCDAsyncUdpSocket 对象
  */
- (GCDAsyncUdpSocket *)localUDPSocket
{
    if([self isLocalUDPSocketReady]) {
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【IMCORE】isLocalUDPSocketReady()==true，直接返回本地socket引用哦。");
        return __localUDPSocket;
    }
    else {
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【IMCORE】isLocalUDPSocketReady()==false，需要先resetLocalUDPSocket()...");
        return [self resetLocalUDPSocket];
    }
}

/**
  *  @brief  正在关闭 socket 连接
  */
- (void)closeLocalUDPSocket
{
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"Close LocalUDPSocket >>> ing");
    
    if(__localUDPSocket != nil) {
        [__localUDPSocket close];  // 关闭
        __localUDPSocket = nil;
    }
    else {
        NSLog(@"【IMCORE】Socket处于未初化状态（可能是您还未登录），无需关闭。");
    }
}


#pragma mark - GCDAsyncUdpSocketDelegate
/**
  *  @brief   成功发送数据
  */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"【UDP_SOCKET】tag为%li的NSData已成功发出.", tag);
}

/**
  *  @brief   未发送成功
  */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"【UDP_SOCKET】tag为%li的NSData没有发送成功，原因是%@", tag, error);
}

/**
  *  @brief  收到数据
  */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString * msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg) {
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【UDP_SOCKET】RECV: %@", msg);
        // 解析数据
        [[UDPDataReciever sharedInstance] handleProtocal:data];
    }
    // 无法转为字符串
    else {
        NSString * host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        if([ClientCoreSDK isEnabledDebug])
            NSLog(@"【UDP_SOCKET】RECV: Unknown message from: %@:%hu", host, port);
    }
}

/**
  *  @brief   GCDAsyncUdpSocket 已连接
  */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"【UDP_SOCKET】成收到的了UDP的connect反馈, isCOnnected?%d", [sock isConnected]);
    if(self.connectionCompletionOnce != nil)
        self.connectionCompletionOnce(YES);
}

/**
  *  @brief   GCDAsyncUdpSocket 未连接
  */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    if([ClientCoreSDK isEnabledDebug])
        NSLog(@"【UDP_SOCKET】成收到的了UDP的connect反馈，但连接没有成功, isCOnnected?%d", [sock isConnected]);
    if(self.connectionCompletionOnce != nil)
        self.connectionCompletionOnce(NO);
}


#pragma mark - SET & GET

- (void)setConnectionObserver:(ConnectionCompletion)connObserver
{
    self.connectionCompletionOnce = connObserver;
}

- (BOOL)isLocalUDPSocketReady
{
    return __localUDPSocket != nil && ![__localUDPSocket isClosed];
}

@end
