//
//  LogModel.h
//  iOSIM
//
//  Created by CYKJ on 2019/11/14.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

@interface LogModel : NSObject

@property (nonatomic, strong) UIColor * color;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, assign) CGFloat height;  // 展示的高度

- (instancetype)initWithColor:(UIColor *)color
                      content:(NSString *)content;

@end
