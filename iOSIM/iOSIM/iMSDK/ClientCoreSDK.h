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
//  ClientCoreSDK.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/21.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "ChatTransDataPTC.h"
#import "ChatBasePTC.h"
#import "MessageQoSPTC.h"

/*!
  *  @brief   MobileIMSDK 核心框架的核心入口类。本类主要提供一些全局参数的读取和设置。
  */
@interface ClientCoreSDK : NSObject

/// ----------------------------------------------
/// @name   属性
/// ----------------------------------------------

/*!
  *  @brief  网络是否可用。
  *  @discussion   YES - 可用；否则表示不可用。内部使用注册通知的方式，监听网络状态的变化，并重置 isExistenceNetwork 字段值
 */
@property (nonatomic, readonly, assign) BOOL isExistenceNetwork;

/*!
  *  @brief   是否已成功连接到服务器（前提是已成功发起过登录请求后）
  *
  *  @discussion   “成功”意味着可以正常与服务端通信（可以近似理解为 Socket 正常建立），“不成功”意味着不能与服务端通信。

        不成功的因素有很多：比如网络不可用、网络状况很差导致的掉线、心跳超时等。

        本参数是整个 MobileIMSDK 框架中唯一可作为判断与 MobileIMSDK 服务器的通信是否正常的准确依据。
        本参数将在收到服务端的登录请求反馈后被设置为 YES，在与服务端的通信无法正常完成时被设置为 NO。

        MobileIMSDK 如何判断与服务端的通信是否正常呢？判断方法如下：

            ①、登录请求被正常反馈即意味着通信正常（包括首次登录时和断掉后的自动重新时）；
            ②、首次登录或断线后自动重连时登录请求被发出后，没有收到服务端反馈时即意味着不正常；
            ③、与服务端通信正常后，在规定的超时时间内没有收到心跳包的反馈后即意味着与服务端的通信又中断了（即所谓的掉线）。
 */
@property (nonatomic, assign, getter=isConnected) BOOL connectedToServer;

/*!
  *  @brief  是否已登录。
  *  @discussion   当且仅当用户从登录界面成功登录后设置本字段为 YES，系统退出（登录）时设置为 NO。
  */
@property (nonatomic, assign, getter=isLogin) BOOL login;


/*!
  *  @brief   保存提交到服务端的唯一 id
  *  @discussion   保证唯一就可以通信，可能是登录用户名、也可能是任意不重复的 id 等，具体意义由业务层决定。

        本字段在登录信息成功发出后就会被设置，将在掉线后自动重连时使用。

        因不保证服务端正确收到和处理了该用户的登录信息，所以本字段因只在 @link connectedToServer @/link == YES 时才有意义.
 */
@property (nonatomic, copy) NSString * loginUserID;

/*!
 *  @brief   保存提交到服务端用于身份鉴别和合法性检查的 token
 *  @discussion   它可能是登录密码，也可能是通过前置单点登录接口拿到的 token 等，具体意义由业务层决定。

        本字段在登录信息成功发出后就会被设置，将在掉线后自动重连时使用。

        因不保证服务端正确收到和处理了该用户的登录信息，所以本字段因只在  @link connectedToServer @/link == YES 时才有意义.
  */
@property (nonatomic, copy) NSString * loginToken;

/*!
  *  @brief   保存本地用户登录时要提交的额外信息（非必须字段，具体意义由客户端自行决定）。

        本字段在登录信息成功发出后就会被设置，将在掉线后自动重连时使用。

        因不保证服务端正确收到和处理了该用户的登录信息，所以本字段应只在  {@link #connectedToServer} == YES 时才有意义。
 */
@property (nonatomic, copy) NSString * loginExtraInfo;

/*!
  *  @brief   MobileIMSDK 的核心框架是否已经初始化。本参数由框架自动设置。
  *
  *  @discussion   当调用 @link initCore @/link 方法后本字段将被置为 YES，调用 @link  releaseCore @/link  时将被重新置为 NO
  *
  * @return   YES - 已初始化完成，否则没有初始化完成
  */
@property (nonatomic, assign, getter=isInitialed) BOOL initialed;

/// 框架基础通信消息的代理（如：登录成功事件通知、掉线事件通知）。
@property (nonatomic, weak) id<ChatTransDataPTC> chatTransDataDelegate;

/// 通用数据通信消息的代理（如：收到聊天数据事件通知、服务端返回的错误信息事件通知）
@property (nonatomic, weak) id<ChatBasePTC> chatBaseDelegate;

///  QoS质量保证机制的代理（如：消息未成功发送的通知、消息已被对方成功收到的通知）
@property (nonatomic, weak) id<MessageQoSPTC> messageQoSDelegate;


/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------


/*!
 *  @brief   取得本类实例的唯一公开方法。
 *  @discussion   依据作者对 MobileIMSDK API 的设计理念，本类目前在整个框架运行中是以单例的形式存活。
 */
+ (instancetype)sharedInstance;

/*!
 *  @brief  初始化核心库。
 *
 *  @discussion   本方法被调用后， @link isInitialed @/link 将返回 YES，否则返回 NO。

        本方法无需调用者自行调用，它将在发送登录路请求后（即调用  [UDPDataSender sendLogin:(NSString *)loginName withPassword:(NSString *)loginPsw] 时）被自动调用。
 */
- (void)initCoreSDK;

/*!
 *  @brief   统一释放 MobileIMSDK 框架资源的方法。
 *
 *  @discussion   本方法建议在退出登录（或退出 App 时）时调用。调用时将尝试关闭所有 MobileIMSDK 框架的后台守护线程，并同时设置核心框架 init = NO、isLogin = false、connectedToServer = NO。
 *
 *  @see   AutoReloginDaemon.stop()
 *  @see   QoS4SendDaemon.stop()
 *  @see   KeepAliveDaemon.stop()
 *  @see   UDPDataReciever.stop()
 *  @see   QoS4ReciveDaemon.stop()
 *  @see   UDPSocketProvider.closeLocalUDPSocket()
 */
- (void)releaseCoreSDK;

/*!
  *  @brief   设置/返回 MobileIMSDK 框架的日志输出开关量值。
  *  @discussion   YES - 开启 MobileIMSDK Debug 信息在控制台下的输出，否则关闭。默认为NO
  */
+ (void)setEnabledDebug:(BOOL)enabled;
+ (BOOL)isEnabledDebug;

/*!
 *  @brief   是否在登录成功后，掉线时自动在重新登录线程中实质性发起登录请求。本参数的设置将实时生效。
 *
 *  @discussion          YES - 将在线程运行周期中正常发起，否则不发起（即关闭实质性的重新登录请求）

        什么样的场景下，需要设置本参数为 NO？
 
        比如：上层应用可以在自已的节电逻辑中控制当网络长时断开时就不需要实质性发起登录请求了，因为网络请求是非常耗电的。
 */
+ (void)setAutoRelogin:(BOOL)autoRelogin;
+ (BOOL)isAutoRelogin;

@end
