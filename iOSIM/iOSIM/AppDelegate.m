//
//  AppDelegate.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "AppDelegate.h"
#import "IMManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 提示：在不退出 app 的情况下退出登陆后再重新登陆时，请确保调用本方法一次，不然会报code=203错误哦！
    [[IMManager sharedInstance] initIMSDK];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // 释放 IM 核心占用的资源
    [[IMManager sharedInstance] releaseIMSDK];
}

@end
