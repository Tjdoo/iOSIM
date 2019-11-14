//
//  RecordModel.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import "Macros.h"

@interface RecordModel : NSObject

@property (nonatomic, copy) NSString * filePath;   // 文件存储地址
@property (nonatomic, copy) NSArray * levels;      // 振幅数组
@property (nonatomic, assign) NSInteger duration;  // 录音时长

DEF_SINGLETON

@end
