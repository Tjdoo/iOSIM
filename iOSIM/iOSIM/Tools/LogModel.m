//
//  LogModel.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/14.
//  Copyright © 2019年 D. All rights reserved.


#import "LogModel.h"

@implementation LogModel

- (instancetype)initWithColor:(UIColor *)color content:(NSString *)content
{
    if (self = [super init]) {
        self.color   = color;
        self.content = content;
    }
    return self;
}

@end
