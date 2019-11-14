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
//  UDPSocketProvider.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "CompletionDefine.h"


/*!
 *  @brief   本地 UDP Socket 实例封装实用类。
 *
 *  @discussion   本类提供存取本地 UDP Socket 通信对象引用的方便方法，封装了 Socket 有效性判断以及异常处理等，以便确保调用者通过方法 {@link #getLocalUDPSocket()} 拿到的 Socket 对象是健康有效的。
 */
@interface UDPSocketProvider : NSObject

/// ----------------------------------------------
/// @name   属性
/// ----------------------------------------------

/// 本类中的 Socket 对象是否是健康的。YES - 健康的
@property (nonatomic, readonly, assign, getter=isLocalUDPSocketReady) BOOL localUDPSocketReady;


/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (instancetype)sharedInstance;

/*!
 *  @brief   重置并新建一个全新的 Socket 对象
 */
- (GCDAsyncUdpSocket *)resetLocalUDPSocket;

/*!
 *  @brief  获得本地 UDPSocket 的实例引用。
 *
 *  @discussion   本方法内封装了 Socket 有效性判断以及异常处理等，以便确保调用者通过本方法拿到的 Socket 对象是健康有效的。
 *  @return   如果该实例正常则返回它的引用，否则返回 null
 */
- (GCDAsyncUdpSocket *)localUDPSocket;

/*!
 *  @brief   设置 UDP Socket 连接结果事件观察者。
 *  @note   此回调一旦设置后只会被调用一次，即无论是被"- (void)udpSocket:didConnectToAddress:"还是“- (void)udpSocket:didNotConnect:”调用，都将在调用完成后被置 nil
  */
- (void)setConnectionObserver:(ConnectionCompletion)connObserver;

/*!
 *  @brief   尝试连接指定的 socket。
 *
 *  @discussion   UDP 是无连接的，此处的连接仅是逻辑意义上的操作，实施方法实际动作是进行状态设置等操作，而带来的方便是每次 send数据时就无需再指明主机和端口了。
 *
 *   @note   本框架中，在发送数据前，请首先确保 isConnected == YES。
 *   @note   connect 实际上是异步的，真正意义上，能连接上目标主机需要等到真正的 IMAP 包到来。但此机无需等到异步返回，只需保证 coonect 从形式上成功即可，即使连接不上主机后绪的 QoS 保证等机制也会起到错误通知等。
 *
 *  @param   error  本参数为 Error 的地址，本方法执行返回时如有错误产生则不为空，否则为 nil
 *  @param   completion   连接结果 block
 *
 *   @return   0 - 表示 connect 的意图是否成功发出（实际上真正连接是通过异常的delegate方法回来的，不在此方法考虑之列），否则表示错误码
 *   @see   GCDAsyncUdpSocket，ConnectionCompletion
 */
- (int)tryConnectToHostWithSocket:(GCDAsyncUdpSocket *)skt
                            error:(NSError **)error
                       completion:(ConnectionCompletion)completion;

/*!
 *  @brief  强制关闭本地 UDP Socket 侦听。
 *
 *  @discussion  本方法通常在两个场景下被调用：
            1、真正需要关闭 Socket 时（如所在的 App 退出时）；
            2、当调用者检测到网络发生变动后希望重置以便获得健康的 Socket 引用对象时。
 *
 *  @note   一旦调用本方法后，再次调用 [UDPSocketProvider localUDPSocket] 将会返回一个全新的 Socket 对象引用。
 *
 *  @see   [GCDAsyncUdpSocket close]
 */
- (void)closeLocalUDPSocket;

@end
