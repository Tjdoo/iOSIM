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
//  UDPDataReciever.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/27.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @brief   数据接收处理独立线程。
 *
 *  @discussion   主要工作是将收到的数据进行解析，并按 MobileIMSDK 框架的协议进行调度和处理。
 *   本类是 MobileIMSDK 框架数据接收处理的唯一实现类，也是整个框架算法最为关键的部分。
 *
 *  @warning   本线程的启停，目前属于 MobileIMSDK 算法的一部分，暂时无需也不建议由应用层自行调用。
 */
@interface UDPDataReciever : NSObject

/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------

/// 获取本类的单例。使用单例访问本类的所有资源是唯一的合法途径。
+ (instancetype)sharedInstance;

/*!
  *  @brief   解析收到的原始消息数据，并按照 MobileIMSDK 定义的协议进行调度和处理。
  *
  *  @discussion   本方法目前由 UDPSocketProvider 自动调用。
  *
  *  @param   originalProtocalJSONData   收到的 MobileIMSDK 框架原始通信报文数据内容
  *  @see  UDPSocketProvider
  */
- (void)handleProtocal:(NSData *)originalProtocalJSONData;

@end
