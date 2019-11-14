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
//  ConfigEntity.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @typedef   SenseMode
 * MobileIMSDK即时通讯核心框架预设的敏感度模式.
 *
 *   对于客户端而言，此模式决定了用户与服务端网络会话的健康模式，原则上超敏感客户端的体验越好。
 *
 *  重要说明：客户端本模式的设定必须要与服务端的模式设制保持一致，否则可能因参数的不一致而导致 IM 算法的不匹配，进而出现不可预知的问题。
 */
typedef enum
{
    /*!
         * 此模式下：
         * * KeepAlive 心跳问隔为 3 秒；
         * * 10 秒后未收到服务端心跳反馈即认为连接已断开（相当于连续 3 个心跳间隔后仍未收到服务端反馈）。
         */
    SenseMode3S,
    
    /*!
         * 此模式下：
         * * KeepAlive 心跳问隔为 10 秒；
         * * 21 秒后未收到服务端心跳反馈即认为连接已断开（相当于连续 2 个心跳间隔后仍未收到服务端反馈）。
         */
    SenseMode10S,
    
    /*!
         * 此模式下：
         * * KeepAlive 心跳问隔为 30 秒；
         * * 61 秒后未收到服务端心跳反馈即认为连接已断开（相当于连续 2 个心跳间隔后仍未收到服务端反馈）。
         */
    SenseMode30S,
    
    /*!
         * 此模式下：
         * * KeepAlive 心跳问隔为 60 秒；
         * * 121 秒后未收到服务端心跳反馈即认为连接已断开（相当于连续 2 个心跳间隔后仍未收到服务端反馈）。
         */
    SenseMode60S,
    
    /*!
         * 此模式下：
         * * KeepAlive 心跳问隔为 120 秒；
         * * 241 秒后未收到服务端心跳反馈即认为连接已断开（相当于连续 2  个心跳间隔后仍未收到服务端反馈）。
         */
    SenseMode120S
} SenseMode;






/*!
 *  @brief   MobileIMSDK 的全局参数控制类。提供存储和获取的方法，内部只定义 static 变量来保存数据
 */
@interface ConfigEntity : NSObject

/*!
 *  @brief   设置 AppKey
 */
+ (void)registerWithAppKey:(NSString *)key;

/*!
 *  @brief  全局设置：服务端 IP 或域名。
 *  @warning   如需设置本参数，请在登录前调用，否则将不起效。
 *  @param   sIp   服务器的 ip 地址或域名
 */
+ (void)setServerIp:(NSString *)sIp;
+ (NSString *)serverIp;

/*!
 *  @brief   全局设置：服务端 UDP 服务侦听端口号。
 *  @warning   如需设置本参数，请在登录前调用，否则将不起效。
 *  @param   sPort   服务端的端口号
 */
+ (void)setServerPort:(int)sPort;
+ (int)serverPort;

/*!
  *  @brief   全局设置：本地 UDP 数据发送和侦听端口。默认是 7801。
  *
  *  @discussion   在什么场景下建议使用固定端口号呢？
 
        通常用于 debug 时，比如观察 NAT 网络下的外网端口分配情况。当然只要开发者确认使用的端口不会与其它 App 冲突，则可随便指定本地端口，不会有任何影响（不影响与服务端的通信逻辑）。
 *
 *  @warning   如需设置本参数，请在登录前调用，否则将不起效。
 *
 *  @param   lPort   本地 UDP 数据发送和侦听端口号。参数 lPort = -1 时表示不绑定固定  port（由系统自动分配，这意味着同时开启两个及以上本 SDK 的实例也不会出现端口占用冲突），否则使用指定端口
 */
+ (void)setLocalUdpSendAndListeningPort:(int)lPort;
+ (int)localUdpSendAndListeningPort;

/*!
 *  @brief   设置 MobileIMSD K即时通讯核心框架预设的敏感度模式。
 *
 *  @discussion   重要说明：客户端本模式的设定必须要与服务端的模式设制保持一致，否则可能因参数的不一致而导致 IM 算法的不匹配，进而出现不可预知的问题。
 *
 *  @warning   请在登录前调用，否则将不起效.
 */
+ (void)setSenseMode:(SenseMode)mode;

@end
