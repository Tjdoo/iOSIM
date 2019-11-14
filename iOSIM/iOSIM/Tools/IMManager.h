//
//  IMManager.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/14.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import "Macros.h"
#import "CompletionDefine.h"
#import "LogModel.h"


@interface IMManager : NSObject

/// 仅用于登录时（因为登录与收到服务端的登录验证结果是异步的，所以由此来完成收到验证后的回调处理）
@property (nonatomic, copy) ObserverCompletion loginBlock;

DEF_SINGLETON

/**
  *  @brief   初始化 SDK
  */
- (void)initIMSDK;

/**
 *  @brief   释放 SDK 资源
 */
- (void)releaseIMSDK;

/**
  *  @brief   产生的日志数据
  */
- (NSArray<LogModel *> *)logData;
- (void)clearLog;
- (void)addLog:(LogModel *)log;

@end
