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
//  ProtocalFactory.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/23.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>
#import "Protocal.h"
#import "PLoginInfoResponse.h"
#import "PErrorResponse.h"

/*!
 *  @brief   MibileIMSDK 框架的协议工厂类。
 *  @note   理论上这些协议都是即时通讯框架内部要用到的，上层应用可以无需理解和理会之。
 */
@interface ProtocalFactory : NSObject

/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Parse
///////////////////////////////////////////////////////////////////////////////////////////

/*!
 *  @brief   将 JSON 转换而来的二进制数据反序列化成 Protocal 类的对象。
 *  @note   本方法主要由MobileIMSDK框架内部使用。
 */
+ (Protocal *)parse:(NSData *)data;

/*!
 *  @brief   将 JSON 转换而来的二进制数据反序列化成指定类的对象。
 *  @note   本方法主要由MobileIMSDK框架内部使用。
 */
+ (id)parse:(NSData *)data toClass:(Class)cls;

/*!
 *  @brief   将指定的 JSON 字符串反序列化成指定类的对象
 *  @note   本方法主要由 MobileIMSDK 框架内部使用。
 */
+ (id)parseString:(NSString *)jsonString toClass:(Class)cls;

/*!
 *  @brief   接收用户登录响应消息对象（该对象由客户端接收）
 *  @note  本方法主要由 MobileIMSDK 框架内部使用。
 */
+ (PLoginInfoResponse *)parseLoginResponseInfo:(NSString *)string;

/*!
 *  @brief   解析错误响应消息对象（该对象由客户端接收）
 *  @note  本方法主要由 MobileIMSDK 框架内部使用。
 */
+ (PErrorResponse *)parseResponseErrorInfo:(NSString *)string;


//////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Create
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/*!
 *  @brief   创建用户注消登录消息对象（该对象由客户端发出）
 */
+ (Protocal *)createPLoginoutInfo:(NSString *)user_id;

/*!
 *  @brief   创建用户登录消息对象（该对象由客户端发出）
 *  @param   loginUserId   提交到服务端的唯一 id，保证唯一就可以通信，可能是登录用户名、也可能是任意不重复的id等，具体意义由业务层决定
 *  @param   loginToken   提交到服务端用于身份鉴别和合法性检查的 token，它可能是登录密码，也可能是通过前置单点登录接口拿到的 token等，具体意义由业务层决定
 * @param   extra   额外信息字符串。本字段目前为保留字段，供上层应用自行放置需要的内容
 */
+ (Protocal *)createPLoginInfo:(NSString *)loginUserId
                     withToken:(NSString *)loginToken
                      andExtra:(NSString *)extra;

/*!
 *  @brief   创建用户心跳包对象（该对象由客户端发出）
 */
+ (Protocal *)createPKeepAlive:(NSString *)from_user_id;

/*!
 *  @brief   通用消息的 Protocal 对象新建方法。
 *  @note   本方法主要由MobileIMSDK框架内部使用。
 *
 *  @param   dataContent   要发送的数据内容（字符串方式组织）
 *  @param   from_user_id   发送人的 user_id
 *  @param   to_user_id   接收人的 user_id
 *  @param   QoS          是否需要 QoS 支持，YES - 表示需要，否则不需要
 *  @param   fingerPrint    消息指纹特征码，为nil则表示由系统自动生成指纹码，否则使用本参数指明的指纹码
 */
+ (Protocal *)createCommonData:(NSString *)dataContent
                    fromUserId:(NSString *)from_user_id
                      toUserId:(NSString *)to_user_id
                           qos:(bool)QoS
                            fp:(NSString *)fingerPrint
                     withTypeu:(int)typeu;
+ (Protocal *)createCommonData:(NSString *)dataContent
                    fromUserId:(NSString *)from_user_id
                      toUserId:(NSString *)to_user_id;
+ (Protocal *)createCommonData:(NSString *)dataContent
                    fromUserId:(NSString *)from_user_id
                      toUserId:(NSString *)to_user_id
                     withTypeu:(int)typeu;

/*!
 *  @brief   客户端 from_user_id 向 to_user_id 发送一个 QoS 机制中需要的“收到消息应答包”。
 *  @note   本方法主要由 MobileIMSDK 框架内部使用。
 *
 *  @param   from_user_id  发起方
 *  @param   to_user_id   接收方
 *  @param   recievedMessageFingerPrint   已收到的消息包指纹码
 *  @param   bridge  是否跨服务器
 */
+ (Protocal *)createRecivedBack:(NSString *)from_user_id
                       toUserId:(NSString *)to_user_id
                withFingerPrint:(NSString *)recievedMessageFingerPrint
                      andBridge:(bool)bridge;
+ (Protocal *)createRecivedBack:(NSString *)from_user_id
                       toUserId:(NSString *)to_user_id
                withFingerPrint:(NSString *)recievedMessageFingerPrint;

@end
 
