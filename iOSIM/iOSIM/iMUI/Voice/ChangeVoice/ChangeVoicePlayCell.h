//
//  ChangeVoicePlayCell.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

@interface ChangeVoicePlayCell : UIView

@property (nonatomic, copy) NSString * voicePath;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, copy) NSString * imageName;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) void (^ playRecordBlock)(ChangeVoicePlayCell * cell);
@property (nonatomic, copy) void (^ endPlayBlock)(ChangeVoicePlayCell * cell);

- (void)playingRecord;

- (void)updateLevels;

- (void)endPlay;

@end
