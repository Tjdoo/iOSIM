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
//  ChatBasePTC.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/21.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @protocol   ChatBasePTC
 *  @brief   MobileIMSDK 的基础通信消息的回调事件接口（如：登录成功事件通知、掉线事件通知等）。
 
        实现此接口后，通过 [ClientCoreSDK setChatBasePTC:]方法设置之，可实现回调事件的通知和处理。
 */
@protocol ChatBasePTC <NSObject>

/*!
  *  @brief  本地用户的登录结果回调事件通知。
  *
  *  @param   dwErrorCode   服务端反馈的登录结果：0  - 登录成功，否则为服务端自定义的出错代码（按照约定通常为>=1025 的数）
  */
- (void)onLoginMessage:(int)dwErrorCode;

/*!
  *  @brief   与服务端的通信断开的回调事件通知。
  *
  *  @discussion   该消息只有在客户端连接服务器成功之后网络异常中断之时触发。

        导致与与服务端的通信断开的原因有（但不限于）：
 
            1、无线网络信号不稳定
            2、WiFi 与 2G/3G/4G 等同时开启情况下的网络切换
            3、手机系统的省电策略等。
 *
 *  @param   dwErrorCode  本回调参数表示表示连接断开的原因，目前错误码没有太多意义，仅作保留字段，目前通常为 -1
 */
- (void)onLinkCloseMessage:(int)dwErrorCode;

@end
