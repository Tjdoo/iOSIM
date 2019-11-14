//
//  IMManager.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/14.
//  Copyright © 2019年 D. All rights reserved.


#import "IMManager.h"
#import "ConfigEntity.h"
#import "ClientCoreSDK.h"


@interface IMManager () <ChatBasePTC, ChatTransDataPTC, MessageQoSPTC>

@property (nonatomic, assign) BOOL initialized; //  MobileIMSDK 是否已经初始过
@property (nonatomic, strong) NSMutableArray<LogModel *> * logArray;

@end


@implementation IMManager

IMP_SINGLETON


- (instancetype)init
{
    if (self = [super init]) {
        self.logArray = [NSMutableArray<LogModel *> array];
        [self initIMSDK];
    }
    return self;
}

- (void)initIMSDK
{
    if (self.initialized)
        return;
    
    // 设置 AppKey
    [ConfigEntity registerWithAppKey:@"5418023dfd98c579b6001741"];
    
    // 使用以下代码表示不绑定固定 port（由系统自动分配），否则使用默认的 7801 端口
    //[ConfigEntity setLocalUdpSendAndListeningPort:-1];
    
    // 敏感度模式设置
    //[ConfigEntity setSenseMode:SenseMode10S];
    
    // 开启 Debug 信息输出
    [ClientCoreSDK setEnabledDebug:YES];
    
    // 设置事件回调
    [ClientCoreSDK sharedInstance].chatBaseDelegate = self;
    [ClientCoreSDK sharedInstance].chatTransDataDelegate = self;
    [ClientCoreSDK sharedInstance].messageQoSDelegate = self;
    
    self.initialized = YES;
}

- (void)releaseIMSDK
{
    [[ClientCoreSDK sharedInstance] releaseCoreSDK];
    
    self.initialized = NO;
}

- (NSArray<LogModel *> *)logData
{
    return [[NSArray alloc] initWithArray:self.logArray copyItems:YES];
}

- (void)clearLog
{
    [self.logArray removeAllObjects];
}

- (void)addLog:(LogModel *)log
{
    [self.logArray addObject:log];
}


#pragma mark - ChatBasePTC
/*!
 *  @brief   本地用户的登陆结果回调事件通知。
 *
 *  @param    dwErrorCode   服务端反馈的登录结果。0  - 登陆成功，否则为服务端自定义的出错代码（按照约定通常为 >=1025 的数）
 */
- (void)onLoginMessage:(int)dwErrorCode
{
    if (dwErrorCode == 0) {
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(0, 255, 0, 1.0) content:[NSString stringWithFormat:@"IM 服务器登录成功, dwErrorCode=%d", dwErrorCode]];
        [self.logArray addObject:log];
    }
    else {
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(255, 0, 0, 1.0) content:[NSString stringWithFormat:@"IM 服务器登录/连接失败,code=%d", dwErrorCode]];
        [self.logArray addObject:log];
    }
    
    if(self.loginBlock != nil) {
        self.loginBlock(nil, [NSNumber numberWithInt:dwErrorCode]);
    }
}

/*!
 *  @brief   与服务端的通信断开的回调事件通知。
 *
 *  @param   dwErrorCode   本回调参数表示表示连接断开的原因，目前错误码没有太多意义，仅作保留字段，目前通常为 -1
 */
- (void)onLinkCloseMessage:(int)dwErrorCode
{
    // 添加日志
    LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(255, 0, 0, 1.0) content:[NSString stringWithFormat:@"与IM服务器的连接已断开, 自动登陆/重连将启动! (%d)", dwErrorCode]];
    [self.logArray addObject:log];
}


#pragma mark - ChatTransDataPTC
/*!
 *  @brief   收到普通消息的回调事件通知。
 *  应用层可以将此消息进一步按自已的 IM 协议进行定义，从而实现完整的即时通信软件逻辑。
 *
 *  @param   fingerPrintOfProtocal   当该消息需要 QoS 支持时，本回调参数为该消息的特征指纹码，否则为 null
 *  @param   dwUserid   消息的发送者 id
 *  @param   dataContent   消息内容的文本表示形式
 */
- (void)onTransBuffer:(NSString *)fingerPrintOfProtocal
           withUserId:(NSString *)dwUserid
           andContent:(NSString *)dataContent
             andTypeu:(int)typeu
{
    // 添加日志
    LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(0, 0, 0, 1.0)
                                content:[NSString stringWithFormat:@"%@说：%@", dwUserid, dataContent]];
    [self.logArray addObject:log];
}

/*!
 *  @brief   服务端反馈的出错信息回调事件通知。
 *
 *  @param   errorCode   错误码，定义在常量表 ErrorCode 中有关服务端错误码的定义
 *  @param   errorMsg   描述错误内容的文本信息
 *  @see   ErrorCode
 */
- (void)onErrorResponse:(int)errorCode withErrorMsg:(NSString *)errorMsg
{
    // UI 显示
    if(errorCode == ForS_RESPONSE_FOR_UNLOGIN) {
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(255, 0, 255, 1.0) content:[NSString stringWithFormat:@"服务端会话已失效，自动登陆/重连将启动! (%d)", errorCode]];
        [self.logArray addObject:log];
    }
    else {
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(255, 0, 0, 1.0) content:[NSString stringWithFormat:@"Server反馈错误码：%d,errorMsg=%@", errorCode, errorMsg]];
        [self.logArray addObject:log];
    }
}


#pragma mark - MessageQoSPTC
/*!
  *  @brief   消息未送达的回调事件通知.
  *
  * @param   lostMessages   由 MobileIMSDK QoS 算法判定出来的未送达消息列表
  */
- (void)messagesLost:(NSMutableArray *)lostMessages
{
    // 添加日志
    LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(255, 0, 255, 1.0) content:[NSString stringWithFormat:@"[QoS保证机制判定消息未成功送达]共%li条!(网络状况不佳或对方id不存在)", lostMessages.count]];
    [self.logArray addObject:log];
}

/*!
 *  @brief   消息已被对方收到的回调事件通知
 */
- (void)messagesBeReceived:(NSString *)theFingerPrint
{
    if(theFingerPrint != nil) {
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(0, 0, 255, 1.0)
                                 content:[NSString stringWithFormat:@"[收到应答]%@", theFingerPrint]];
        [self.logArray addObject:log];
    }
}

@end
