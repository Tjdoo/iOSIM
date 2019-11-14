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
//  AutoReloginDaemon.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/24.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "CompletionDefine.h"

/*!
 *  @brief   与服务端通信中断后的自动登录（重连）独立线程。
 *
 *  @discussion   鉴于无线网络的不可靠性和特殊性，移动端的即时通讯经常存在网络通信断断续续的状况，可能的原因有（但不限于）：
 
        1、无线网络信号不稳定
        2、WiFi 与 2G/3G/4G 等同时开启情况下的网络切换
        3、手机系统的省电策略等。
 
        这就使得即时通信框架拥有对上层透明且健壮的健康度探测和自动治愈机制非常有必要。本类使得 MobileIMSDK 框架拥有通信自动治愈的能力。

         注意：自动登录（重连）只可能发生在登录成功后与服务端的网络通信断开时。

        本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 */
@interface AutoReloginDaemon : NSObject

/// ----------------------------------------------
/// @name   属性
/// ----------------------------------------------

/// 线程是否正在运行中
@property (nonatomic, readonly, assign, getter=isAutoReLoginRunning) BOOL autoReLoginRunning;

/// Just for DEBUG.
@property (nonatomic, copy) ObserverCompletion debugObserver;


/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (instancetype)sharedInstance;

/*!
  *  @brief   设置/获取自动重新登录时间间隔（单位：毫秒），默认 2000 毫秒。
  *
  *  @discussion   此参数只会影响断线后与服务器连接的即时性，不受任何配置参数的影响。请基于重连（重登录）即时性和手机能耗上作出权衡。
  *  @warning   除非对 MobileIMSDK 的整个即时通讯算法非常了解，否则请勿尝试单独设置本参数。如需调整心跳频率请见 {@link [ConfigEntity.setSenseMode:SenseMode]}。
  */
+ (void)setAutoReloginInterval:(int)autoReLoginInterval;
+ (int)autoReloginInterval;

/*!
 *  @brief   启动线程。
 *  @discussion  无论本方法调用前线程是否已经在运行中，都会尝试首先调用 @link stop @/link 方法，以便确保线程被启动前是真正处于停止状态，这也意味着可无害调用本方法。
 *  @param   immediately   YES - 立即执行线程作业，否则直到 {@link #AUTO_RE$LOGIN_INTERVAL} 执行间隔的到来才进行首次作业的执行
 */
- (void)start:(BOOL)immediately;

/*!
 *  @brief   无条件中断本线程的运行。
 *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 */
- (void)stop;

@end
