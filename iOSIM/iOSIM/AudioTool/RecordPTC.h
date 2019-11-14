//
//  RecordPTC.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <Foundation/Foundation.h>


@protocol RecordPTC <NSObject>

/**
  *  @brief   录音工具准备中
  */
- (void)recorderInPreparation;
/**
  *  @brief   录音中
  */
- (void)recorderRecording;
/**
  *  @brief   录音失败
  */
- (void)recorderRecordFail:(NSString *)failMsg;

@end
