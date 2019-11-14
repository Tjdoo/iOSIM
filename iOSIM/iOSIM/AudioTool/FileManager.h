//
//  FileManager.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import "Macros.h"

/**    本地文件管理    **/
@interface FileManager : NSObject

DEF_SINGLETON

/**
  *  @brief   存放所有语音文件的文件夹路径
  */
+ (NSString *)folderPath;
/**
  *  @brief   变声文件保存的路径。变声文件和普通的录音文件分开存放
  */
+ (NSString *)changedVoiceSavePathWithFileName:(NSString *)fileName;
/**
  *  @brief   普通音频文件路径。使用时间戳来区分不同文件
  */
+ (NSString *)filePath;
/**
  *  @brief   移除音频文件
  */
+ (BOOL)removeFile:(NSString *)filePath;

@end
