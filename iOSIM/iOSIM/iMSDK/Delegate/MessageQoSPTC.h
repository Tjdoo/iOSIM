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
//  MessageQoSPTC.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/21.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
  *  @protocol   MessageQoSPTC
  *  @brief   MobileIMSDK 的 QoS 质量保证机制的回调事件接口。
  *  @discussion   当前 MobileIMSDK 的 QoS 机制支持全部的 C2C、C2S、S2C 共 3 种消息交互场景下的消息送达质量保证。

        MobileIMSDK QoS 机制的目标是：尽全力送达消息，即使无法送达也会通过回调告诉应用层，尽最大可能避免因 UDP 协议天生的不可靠性而发生消息黑洞情况（黑洞消息：即消息发出后发送方完全不知道到底送达了还是没有送达，而 MobileIMSDK 的 QoS 机制将会即时准确地告之发送方：“已送达”或者“没有送达”，没有第 3 种可能）。
 */
@protocol MessageQoSPTC <NSObject>

/*!
  *  @brief   消息未送达的回调事件通知.
  *
  *  @param   lostMessages  由 MobileIMSDK QoS 算法判定出来的未送达消息列表（此列表中的 Protocal 对象是原对象的 clone（即原对象的深拷贝），请放心使用哦），应用层可通过指纹特征码找到原消息并可以 UI 上将其标记为”发送失败“以便即时告之用户
  *  @see  Protocal.h
  */
- (void)messagesLost:(NSMutableArray *)lostMessages;

/*!
  *  @brief   消息已被对方收到的回调事件通知。
  *
  *  @discussion   目前，判定消息被对方收到是有两种可能：

            1、对方确实是在线并且实时收到了；
            2、对方不在线或者服务端转发过程中出错了，由服务端进行离线存储成功后的反馈（此种情况严格来讲不能算是“已被收到”，但对于应用层来说，离线存储了的消息原则上就是已送达了的消息：因为用户下次登录时肯定能通过 HTTP 协议取到）。
 *
 *  @param   theFingerPrint   已被收到的消息的指纹特征码（唯一 ID），应用层可据此 ID 来找到原先已发生的消息，并可在 UI 上将其标记为”已送达“或”已读“以便提升用户体验
 */
- (void)messagesBeReceived:(NSString *)theFingerPrint;

@end
