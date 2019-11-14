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
//  Protocal.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @brief   协议报文对象.
 *  @discussion   重要说明：因本类中的属性 retryCount 仅用于本地（不需要通过网络把值传给接收方），因为在对象转 JSON 时应去掉此属性，那么接收方收到本对象并反序列化时该属性正好就是默认值 0。
 */
@interface Protocal : NSObject

/// ----------------------------------------------
/// @name   属性
/// ----------------------------------------------

/// 是否来自跨服务器的消息。YES - 表示是，NO - 不是。本字段是为跨服务器或集群准备的。默认：NO
@property (nonatomic, assign) bool bridge;

/*!
 *  @brief    协议类型。默认：0
 *
 *  @note   本字段为框架专用字段，本字段的使用涉及 IM 核心层算法的表现，如无必要请避免应用层使用此字段。理论上应用层不参与本字段的定义，可将其视为透明，如需定义应用层的消息类型，请使用 {@link typeu} 字段并配合 dataContent 一起使用。
 *
 *  @see   @link ProtocalType @/link
 */
@property (nonatomic, assign) int type;

/// 协议数据内容。本字段用于 MobileIMSDK_X 框架中时，可能会存放一些指令内容。当本字段用于应用层时，由用户自行定义和使用其内容
@property (nonatomic, copy) NSString * dataContent;

/// 消息发出方的 id（当用户登录时，此值可不设置）。“-1” 表示未设定；为“0” 表示来自 Server。默认："-1"
@property (nonatomic, copy) NSString * from;

/// 消息接收方的 id（当用户退出时，此值可不设置）。“-1” 表示未设定、为“0” 表示发给 Server。默认："-1"
@property (nonatomic, copy) NSString * to;

/*!
 *  @brief   用于 QoS 消息包的质量保证时，作为消息的指纹特征码（理论上全局唯一）。
 *  @note   本字段为框架专用字段，请勿用作其它用途。
 */
@property (nonatomic, copy) NSString * fp;

/*!
 *  @brief   YES - 表示本包需要进行 QoS 质量保证，否则不需要。默认：NO
 *
 *  @warning   当本属性申明为 BOOL 类型时，在模拟器 iPhone 4s、iPhone 5 时，利用官方的 NSJSONSerialization 类转成 JSON 时，会被解析成0 或 1，而在 iPhone 5s 和 iPhone 6 上会被解析成 true 或 false，符合 JSON 规范的应是 true 和 false。经过实验，把申明改成 bool 型时，在 4s、5、5s、6 上都能正常解析成 true 和 false，暂时原因不明！
 */
@property (nonatomic, assign) bool QoS;

/**
 *  @brief   应用层专用字段：用于应用层存放聊天、推送等场景下的消息类型。默认：-1
 *  @note   此值为 -1 时表示未定义。MobileIMSDK_X 框架中，本字段为保留字段，不参与框架的核心算法，专留用应用层自行定义和使用。
 */
@property (nonatomic, assign) int typeu;


/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/*!
 *  @brief   本字段仅用于 QoS 时：表示丢包重试次数。
 */
- (int)retryCount;

/*!
 *  @brief   本方法仅用于 QoS 时：选出包重试次数 +1。
 *  @warning   本方法理论上由 MobileIMSDK 内部调用，应用层无需额外调用。
 */
- (void)increaseRetryCount;

/*!
 *  @brief  将本对象转换成 JSON 字符串
 */
- (NSString *)toJsonString;

/*!
 *  @brief   将本对象转换成 JSON 表示的二进制数据（以便网络传输）。
 */
- (NSData *)toData;

/**
 *  @brief   返回本对象的一个副本
 */
- (Protocal *)clone;

/*!
 *  @brief   创建并返回 Protocal 对象的快捷方法
 *
 *  @param   type        协议类型
 *  @param   dataContent 协议数据内容
 *  @param   from       消息发出方的 id（当用户登录时，此值可不设置）
 *  @param   to            消息接收方的 id（当用户退出时，此值可不设置）
 *  @param   QoS        是否需要QoS支持，true表示是，否则不需要
 *  @param   fingerPrint   协议包的指纹特征码，当 QoS 字段=true 时且本字段为 null 时，方法中将自动生成指纹码否则使用本参数指定的指纹码
 *  @param   bridge      是否来自跨服务器的消息，true表示是、否则不是。本字段是为跨服务器或集群准备的
 *  @param   typeu       应用层专用字段——用于应用层存放聊天、推送等场景下的消息类型，不需要设置时请填 -1 即可
 */
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
                         qos:(bool)QoS
                          fp:(NSString *)fingerPrint
                          bg:(bool)bridge
                          tu:(int)typeu;
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to;
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
                          tu:(int)typeu;
+ (instancetype)initWithType:(int)type
                     content:(NSString *)dataContent
                        from:(NSString *)from
                          to:(NSString *)to
                         qos:(bool)QoS
                          fp:(NSString *)fingerPrint
                          tu:(int)typeu;

/*!
 *  @brief   返回 QoS 需要的消息包的指纹特征码。
 *
 *  @note   重要说明：使用系统时间戳作为指纹码，则意味着只在 Protocal 生成的环境中可能唯一。它存在重复的可能性有 2 种：
 
            1、比如在客户端生成时如果生成过快的话（时间戳最小单位是 1 毫秒，如 1 毫秒内生成多个指纹码），理论上是有重复可能性；
            2、不同的客户端因为系统时间并不完全一致，理论上也是可能存在重复的，所以唯一性应是：好友+指纹码才对。
 *
 *  目前使用的 UUID 基本能保证全局唯一，但它有 36 位长（加上分隔符 32+4），目前为了保持框架的算法可读性，暂时不进行优化，以后可考虑使用二进制方式或者 Protobuffer 实现。
 *
 *  @return   指纹特征码实际上就是系统的当时时间戳
 *  @see   DataKits.generateUUID()
 */
+ (NSString *)genFingerPrint;

@end
