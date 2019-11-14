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
//  PLoginInfo.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @brief  登录信息模型类。
 */
@interface PLoginInfo : NSObject

/// 登录时提交的准一 id，保证唯一就可以通信，可能是登录用户名、也可能是任意不重复的 id 等，具体意义由业务层决定
@property (nonatomic, copy) NSString * loginUserId;

/// 登录时提交到服务端用于身份鉴别和合法性检查的 token，它可能是登录密码，也可能是通过前置单点登录接口拿到的 token 等，具体意义由业务层决定
@property (nonatomic, copy) NSString * loginToken;

/// 额外信息字符串。本字段目前为保留字段，供上层应用自行放置需要的内容
@property (nonatomic, copy) NSString * extra;

@end
