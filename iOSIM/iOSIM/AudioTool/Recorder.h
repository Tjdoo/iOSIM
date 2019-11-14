//
//  Recorder.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>
#import "RecordPTC.h"
#import "Macros.h"

/**   录音工具    **/
@interface Recorder : NSObject

@property (nonatomic, readonly, copy) NSString * recordFilePath;
@property (nonatomic, weak) id<RecordPTC> delegate;
@property (nonatomic, assign, getter=isRecording) BOOL recording;

/**
  *  @brief   开始录音
  */
- (void)beginRecordWithStoreFilePath:(NSString *)recordFilePath;
/**
  *  @brief   结束录音
  */
- (void)endRecord;
/**
  *  @brief    暂停录音
  */
- (void)pauseRecord;
/**
  *  @brief    删除录音
  */
- (void)deleteRecord;
/**
   *  @return   返回分贝值
   */
- (float)levels;

DEF_SINGLETON;

@end
