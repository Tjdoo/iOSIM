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
//  DataKits.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/22.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "DataKits.h"
#import "RMMapper.h"


@implementation DataKits

+ (NSString *)generateUUID
{
    return [[NSUUID UUID] UUIDString];
}

+ (NSTimeInterval)getTimeStampWithMillisecond
{
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    return [date timeIntervalSince1970] * 1000;
}

+ (long)getTimeStampWithMillisecond_l
{
    return [[NSNumber numberWithDouble:[DataKits getTimeStampWithMillisecond]] longValue];
}

/// NSData -》NSString
+ (NSString *)stringWithData:(NSData *)data;
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/// NSString -》NSData
+ (NSData *)dataWithString:(NSString *)string
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

/// NSDictionary -》NSData
+ (NSData *)dataWithDictionary:(NSDictionary *)dictionary
{
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    
    if(error != nil)
        NSLog(@"【IMCORE】将对象转成JSON数据时出错了：%@", error);
    
    return jsonData;
}

+ (NSMutableDictionary *)mutableDictionaryWithObject:(id)object
{
    return [RMMapper mutableDictionaryForObject:object];
}

+ (NSDictionary *)dictionaryWithData:(NSData *)data
{
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (id)parseDictionary:(NSDictionary *)dic toClass:(Class)cls
{
    return[RMMapper objectWithClass:cls fromDictionary:dic];
}

@end
