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
//  ProtocalQoS4SendProvider.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/24.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "Protocal.h"
#import "CompletionDefine.h"

/*!
 *  @brief   QoS 机制中提供消息送达质量保证的守护线程。
 *  @discussion   本类是 QoS 机制的核心，极端情况下将弥补因 UDP 协议天生的不可靠性而带来的丢包情况。
 *
        当前 MobileIMSDK 的 QoS 机制支持全部的 C2C、C2S、S2C 共 3 种消息交互场景下的消息送达质量保证。
 *
 *  @warning 本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 *
        FIXME：按照目前 MobileIMSDK 通信机制的设计原理，有 1 种非常极端的情况目前的 QoS 重传绝对不会成功，那就是当对方非正常退出，而本地并未及时（在服务会话超时时间内）收到他下线通知，此时间间隔内发的消息，本地将尝试重传。但对方在重传重试期限内正常登录也将绝不会收到，为什么呢？因为对方再次登录时 user_id 已经更新成新的了，之前的包记录的发送目的地还是老 user_id。这种情况可以改善，那就是这样的包里还记录它的登录名，服务端根据 user_id 尝试给目标发消息，但 user_id 不存在的情况下（即刚才这种情况）可以用登录名尝试找到它的新 user_id，从而向新 user_id 发消息就可以让对方收到了。目前为了最大程度保证算法的合理性和简洁性暂不实现这个了，好在客户端业务层可无条件判定并提示该消息没有成功发送，那此种情况在应用层的体验上也是可接受的！
 */
@interface QoS4SendDaemon : NSObject

/// ----------------------------------------------
/// @name   属性
/// ----------------------------------------------

/// Just for DEBUG
@property (nonatomic, copy) ObserverCompletion debugObserver;


/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (instancetype)sharedInstance;

/*!
 *  @brief   启动线程。
 *  @note   无论本方法调用前线程是否已经在运行中，都会尝试首先调用 stop 方法，以便确保线程被启动前是真正处于停止状态，这也意味着可无害调用本方法。
 *
 *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 *
 *  @param  immediately    YES - 表示立即执行线程作业，否则直到 AUTO_RE$LOGIN_INTERVAL 执行间隔的到来才进行首次作业的执行
 */
- (void)startup:(BOOL)immediately;

/*!
 *  @brief   无条件中断本线程的运行。
 *
 *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 */
- (void)stop;

/*!
 *  @brief   线程是否正在运行中。
 *
 *  @return   YES - 表示运行中，NO - 线路处于停止状态
 */
- (BOOL)isRunning;

/*!
 *  @brief   该包是否已存在于队列中。
 *
 *  @param   fingerPrint   消息包的指纹特征码（理论上是唯一的）
 */
- (BOOL)exist:(NSString *)fingerPrint;

/*!
 *  @brief   推入一个消息包的指纹特征码.
 *  @note  本方法只会将指纹码推入，而不是将整个 Protocal 对象放入列表中。
 */
- (void)put:(Protocal *)p;

/*!
 *  @brief   移除一个消息包。
 *   @note   此操作是在步异线程中完成，目的是尽一切可能避免可能存在的阻塞本类中的守望护线程.
 */
- (void)remove:(NSString *)fingerPrint;

/**
 *  @brief   清空缓存队列。
 *   调用此方法可以防止在 App 不退出的情况下，退出登录 MobileIMSDK 时没有清除队列缓存，导致此时换用另一账号时发生数据交叉。
 */
- (void)clear;

/*!
 *  @brief  队列大小.
 *
 *  @see   HashMap#size()
 */
- (unsigned long)size;

@end
