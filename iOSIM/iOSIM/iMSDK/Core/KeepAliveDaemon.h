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
//  KeepAliveDaemon.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/24.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "CompletionDefine.h"

/*!
  *  @brief   用于保持与服务端通信活性的 Keep alive 独立线程。
  *  @discussion   Keep alive 的目的有 2 个：
 
            1、防止 NAT 路由算法导致的端口老化。
                》路由器的 NAT 路由算法存在所谓的“端口老化”概念
                》（理论上 NAT 算法中 UDP 端口老化时间为 300s，但这不是标准，而且中高端路由器可由网络管理员自行设定此值），Keep alive 机制可确保在端口老化时间到来前重置老化时间，进而实现端口“保活”的目的，否则端口老化导致的后果是服务器将向客户端发送的数据将被路由器抛弃。
            2、即时探测由于网络状态的变动而导致的通信中断（进而自动触发自动治愈机制）。此种情况可的原因有（但不限于）：
                ①、无线网络信号不稳定
                ②、WiFi 与 2G/3G/4G 等同时开启情况下的网络切换
                ③、手机系统的省电策略等。

  *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 */
@interface KeepAliveDaemon : NSObject

/// ----------------------------------------------
/// @name   属性
/// ----------------------------------------------

/// 线程是否正在运行中。
@property (nonatomic, readonly, assign, getter=isKeepAliveRunning) BOOL keepAliveRunning;
/// 设置网络断开事件观察者。目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用
@property (nonatomic, copy) ObserverCompletion networkConnectionLostObserver;
/// Just for DEBUG.
@property (nonatomic, copy) ObserverCompletion debugObserver;


/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (instancetype)sharedInstance;

/*!
 *  @brief   Keep Alive 心跳时间间隔（单位：毫秒），默认 3000 毫秒。
 *
 *  @discussion   心跳间隔越短则保持会话活性的健康度更佳，但这也使得在大量客户端连接情况下服务端因此而增加负载，且手机将消耗更多电量和流量，所以此间隔需要权衡（建议为：>= 1 秒，且 < 300秒）
 
            说明：此参数用于设定客户端发送到服务端的心跳间隔，心跳包的作用是用来保持与服务端的会话活性（更准确的说是为了避免客户端因路由器的 NAT 算法而导致 UDP 端口老化）。
  *
  *  @warning   修改此参数的同时，也需要相应设置服务端的 ServerLauncher.SESION_RECYCLER_EXPIRE 参数，即客户端与服务端保持一致
  */
+ (void)setKeepAliveinterval:(int)keepAliveTimeWithMils;
+ (int)keepAliveinterval;

/*!
 *  @brief   设置收到服务端响应心跳包的超时间时间（单位：毫秒），默认（3000 * 3 + 1000）＝ 10000 毫秒。
 *
 *  @discussion   超过这个时间客户端将判定与服务端的网络连接已断开（建议间隔为：(KEEP_ALIVE_INTERVAL * 3) + 1 秒），没有上限，但不可太长，否则将不能即时反映出与服务器端的连接断开（比如掉掉线时），请从能忍受的反应时长和即时性上做出权衡。
 *
 *      本参数除与 {@link KeepAliveDaemon#KEEP_ALIVE_INTERVAL} 有关联外，不受其它设置影响。
 */
+ (void)setNetworkConnectionTimeOut:(int)networkConnectionTimeout;
+ (int)networkConnectionTimeOut;

/*!
  *  @brief   启动线程。
  *
  *  @discussion   无论本方法调用前线程是否已经在运行中，都会尝试首先调用 {@link #stop()} 方法，以便确保线程被启动前是真正处于停止状态，这也意味着可无害调用本方法。
  *
  *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
  *
  *  @param   immediately   YES - 表示立即执行线程作业，否则直到 {@link #AUTO_RE$LOGIN_INTERVAL} 执行间隔的到来才进行首次作业的执行
 */
- (void)start:(BOOL)immediately;

/*!
  *  @brief   无条件中断本线程的运行。
  *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
  */
- (void)stop;

/**
  *  @brief   收到服务端反馈的心跳包时调用此方法。作用：更新服务端最背后的响应时间戳.
  *   @warning   本方法的调用，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
  */
- (void)updateGetKeepAliveResponseFromServerTimstamp;

@end
