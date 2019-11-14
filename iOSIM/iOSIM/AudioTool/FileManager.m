//
//  FileManager.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "FileManager.h"

@implementation FileManager

IMP_SINGLETON

/**
  *  @brief   存放所有语音文件的文件夹路径
  */
+ (NSString *)folderPath
{
    NSString * document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * folderPath = [NSString stringWithFormat:@"%@/Voice", document];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath];
    if (!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return folderPath;
}

/**
  *  @brief   存放变声文件的路径
  */
+ (NSString *)changedVoiceSavePathWithFileName:(NSString *)fileName
{
    // 文件夹路径
    NSString * directoryPath = [NSString stringWithFormat:@"%@/ChangedVoice", [self folderPath]];
    
    // 文件路径
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, fileName];

    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath];
    if (!isExist) {
        // 如果文件夹不存在则创建，并且这时文件肯定也不存在
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    else {
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (isExist) {
            // 如果文件存在则移除，防止文件冲突
            [self removeFile:filePath];
        }
    }
    
    return filePath;
}

/**
  *  @brief   普通音频文件路径
  */
+ (NSString *)filePath
{
    NSString * directoryPath = [self folderPath];
    NSString * fileName = [self __fileName];
    return [directoryPath stringByAppendingPathComponent:fileName];
}

/**
  *  @brief   移除音频文件
  */
+ (BOOL)removeFile:(NSString *)filePath
{
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


#pragma mark - Tool
/**
  *  @brief   音频文件名。采用时间戳命名不同的文件
  */
+ (NSString *)__fileName
{
    return [NSString stringWithFormat:@"Voice%lld.wav", (long long)[NSDate timeIntervalSinceReferenceDate]];
}

@end
