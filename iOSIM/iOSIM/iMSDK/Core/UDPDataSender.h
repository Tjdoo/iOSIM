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
//  UDPDataSender.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/27.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "Protocal.h"

/*!
 *  @brief  数据发送处理实用类。
 * 本类是 MobileIMSDK 框架的唯一提供数据发送的公开实用类。
 */
@interface UDPDataSender : NSObject

/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (instancetype)sharedInstance;

/*!
 *  @brief   发送登录信息。
 *
 *  @discussion   在本方法中已经调用 [ClientCoreSDK initCoreSDK] 方法，进行了核心库的初始化，因而使用本类完成登录时，就无需再调用核心库的初始化方法了。
 *
 *  @warning   本库的启动入口就是登录过程触发的，因而要使本库能正常工作，请确保首先进行登录操作。
 *  @param    loginUserId    提交到服务端的唯一 id，保证唯一就可以通信，可能是登录用户名、也可能是任意不重复的 id 等，具体意义由业务层决定
 *  @param   loginToken   提交到服务端用于身份鉴别和合法性检查的 token，它可能是登录密码，也可能是通过前置单点登录接口拿到的 token等，具体意义由业务层决定
 *  @param   extra   额外信息字符串，可为 null。本字段目前为保留字段，供上层应用自行放置需要的内容
 * @return    0  - 表示数据发出成功，否则返回的是错误码
 *
 *  @see   [UDPDataSender __sendImpl:(NSData *)]
 */
- (int)sendLogin:(NSString *)loginUserId
       withToken:(NSString *)loginToken
        andExtra:(NSString *)extra;
- (int)sendLogin:(NSString *)loginUserId
       withToken:(NSString *)loginToken;

/*!
 *  @brief   发送注销登录信息
 *
 *  @discussion   在本方法中已经调用 [ClientCoreSDK releaseCoreSDK]，除非再次进行登录过程，否则核心库将处于未初始化状态。
 *  @warning   本方法将会额外调用资源释放方法 [ClientCoreSDK releaseCoreSDK]，以保证资源释放。
 *  @return   0 - 表示数据发出成功，否则返回的是错误码
 *  @see   [UDPDataSender __sendImpl:(NSData *)]
 */
- (int)sendLogout;

/*!
 *  @brief   发送 Keep Alive 心跳包.
 *
 *  @return   0 - 表示数据发出成功，否则返回的是错误码
 *  @see    [UDPDataSender __sendImpl:(NSData *)]
 */
- (int)sendKeepAlive;

/*!
 *  @brief   通用数据发送方法。
 *
 *  @param   dataContentWidthStr    要发送的数据内容（字符串方式组织）
 *  @param   to_user_id   要发送到的目标用户 id
 *  @param   QoS   YES - 表示需 QoS 机制支持，不则不需要
 *  @param   fingerPrint   QoS 机制中要用到的指纹码（即消息包唯一 id），生成方法见 [Protocal:genFingerPrint]
 *  @return   0 - 表示数据发出成功，否则返回的是错误码
 *  @see   #sendCommonData(Protocal)
 *  @see   DataFactoryC.createCommonData(String, int, int)
 */
- (int)sendCommonDataWithStr:(NSString *)dataContentWidthStr
                    toUserId:(NSString *)to_user_id
                         qos:(BOOL)QoS
                          fp:(NSString *)fingerPrint
                   withTypeu:(int)typeu;
- (int)sendCommonDataWithStr:(NSString *)dataContentWidthStr
                    toUserId:(NSString *)to_user_id
                   withTypeu:(int)typeu;
- (int)sendCommonDataWithStr:(NSString *)dataContentWidthStr
                    toUserId:(NSString *)to_user_id;

/*!
 *  @brief   通用数据发送的根方法。
 *
 *  @param   p   要发送的内容（MobileIMSDK 框架的“协议”DTO 对象组织形式）
 *  @return   0 - 表示数据发出成功，否则返回的是错误码
 *  @see [LocalUDPDataSender __sendImpl:(NSData *)]
 */
- (int)sendCommonData:(Protocal *)p;

@end
