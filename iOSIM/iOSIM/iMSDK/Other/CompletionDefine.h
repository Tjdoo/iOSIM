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
//  CompletionDefine.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/27.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @brief   本接口中定义了一些用于回调的 block 类型。
 */
@interface CompletionDefine : NSObject

/*!
 *  @brief   通用回调。应用场景是模拟 Java 中的 Obsrver 观察者模式。
 *
 *  @param   observerble   此参数通常为 nil，字段意义可自行定义
 *  @param   arg1   通常为回调时的数据（字段意义可自行定义），可为 nil
 */
typedef void (^ObserverCompletion)(id observerble, id arg1);

/*!
 *  @brief   UDP Socket 连接结果回调。
 *
 *  @param   connectRsult   YES - 表示连接成功，NO - 表示连接失败
 */
typedef void (^ConnectionCompletion)(BOOL connectRsult);

@end
