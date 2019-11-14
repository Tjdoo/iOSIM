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
//  DataKits.h
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import <Foundation/Foundation.h>

/*!
 *  @brief   实用工具类。
 */
@interface DataKits : NSObject

/// ----------------------------------------------
/// @name   方法
/// ----------------------------------------------


/*!
 *  @brief   生成 UUID（或者叫 GUID）.
 */
+ (NSString *)generateUUID;

/*!
 *  @brief   返回系统时间戳（单位：毫秒）。浮点表示，形如：1414074342829.249023
 */
+ (NSTimeInterval)getTimeStampWithMillisecond;

/*!
 *  @brief   返回系统时间戳（单位：毫秒）。long 表示，形如：1414074342829
 */
+ (long)getTimeStampWithMillisecond_l;

/*!
 *  @brief  将二进制数据按 UTF-8 编码组织成字符串
 */
+ (NSString *)stringWithData:(NSData *)data;

/*!
 *  @brief   将字符串按 UTF-8 编码成二进制数据。
 */
+ (NSData *)dataWithString:(NSString *)string;


///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSON
///////////////////////////////////////////////////////////////////////////////////////////////////////

/*!
 *  @brief   将 JSON 格式的二进制数据转成 NSDictionary
 *  @see   dataWithDictionary:
 */
+ (NSDictionary *)dictionaryWithData:(NSData *)data;

/*!
 *  @brief   将字典对象转换成 JSON 表示的二进制数据（以便网络传输的场景下）。
 */
+ (NSData *)dataWithDictionary:(NSDictionary *)dictionary;

/*!
 *  @brief   将指定对象序列化成 NSMutableDictionary
 */
+ (NSMutableDictionary *)mutableDictionaryWithObject:(id)object;

/*!
 *  @brief   将 Dictionary 描述的 Key-values 数据反序列化成对象
 */
+ (id)parseDictionary:(NSDictionary *)dic toClass:(Class)cls;

@end
