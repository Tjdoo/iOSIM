//  ----------------------------------------------------------------------
//  Copyright (C) 2017  即时通讯网(52im.net) & Jack Jiang.
//  The MobileIMSDK_X (MobileIMSDK v3.x) Project.
//  All rights reserved.
//
//  > Github地址: https://github.com/JackJiang2011/MobileIMSDK
//  > 文档地址: http://www.52im.net/forum-89-1.html
//  > 即时通讯技术社区：http://www.52im.net/
//  > 即时通讯技术交流群：320837163 (http://www.52im.net/topic-qqgroup.html)
//
//  "即时通讯网(52im.net) - 即时通讯开发者社区!" 推荐开源工程。
//
//  如需联系作者，请发邮件至 jack.jiang@52im.net 或 jb2011@163.com.
//  ----------------------------------------------------------------------
//
//  ClientCoreSDK.m
//  MibileIMSDK4i_X (MobileIMSDK v3.0 at Summer 2017)
//
//  Created by JackJiang on 14/10/21.
//  Copyright (c) 2017年 52im.net. All rights reserved.


#import "ClientCoreSDK.h"
#import "MBReachability.h"
#import "QoS4SendDaemon.h"
#import "KeepAliveDaemon.h"
#import "UDPSocketProvider.h"
#import "QoS4ReciveDaemon.h"
#import "AutoReloginDaemon.h"


static BOOL __enabledDebug = NO;
static BOOL __autoRelogin = YES;

@interface ClientCoreSDK ()
@property (nonatomic, strong) MBReachability * reachability;
@end


@implementation ClientCoreSDK

static ClientCoreSDK * __singleton__;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

/**
  *  @brief   单例实现
  */
+ (instancetype)sharedInstance
{
    if (__singleton__ == nil) {
        __singleton__ = [[self alloc] init];
    }
    return __singleton__;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        __singleton__ = [super allocWithZone:zone];
    });
    return __singleton__;
}

/**
  *  @brief   初始化核心框架
  */
- (void)initCoreSDK
{
    if(_initialed)
        return;
    
    _isExistenceNetwork = NO;
    _connectedToServer = NO;
    _login = NO;
    
    // 开始监测网路
    [self.reachability startNotifier];

    _isExistenceNetwork = [self __checkNetworkStatus];
    _initialed = YES;
    
    NSLog(@"ClientCoreSDK initCore finish!");
}

/**
  *  @brief  释放资源
  */
- (void)releaseCoreSDK
{
    [[AutoReloginDaemon sharedInstance] stop]; 
    [[QoS4ReciveDaemon sharedInstance] stop];
    [[KeepAliveDaemon sharedInstance] stop];
    [[QoS4SendDaemon sharedInstance] stop];
    [[UDPSocketProvider sharedInstance] closeLocalUDPSocket];

    [[QoS4SendDaemon sharedInstance] clear];
    [[QoS4ReciveDaemon sharedInstance] clear];

    if (self.reachability) {
        [self.reachability stopNotifier];
    }
    
    _initialed = NO;
    _login = NO;
    _connectedToServer = NO;
}

+ (BOOL)isEnabledDebug
{
    return __enabledDebug;
}

+ (void)setEnabledDebug:(BOOL)enabled
{
    __enabledDebug = enabled;
}

+ (BOOL)isAutoRelogin
{
    return __autoRelogin;
}

+ (void)setAutoRelogin:(BOOL)autoRelogin
{
    __autoRelogin = autoRelogin;
}


#pragma mark - Network
/**
  *  @brief   检查网络状态
  */
- (BOOL)__checkNetworkStatus
{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    
    return status == ReachableViaWWAN || status == ReachableViaWiFi;
}

/**
  *  @brief   网络发生改变通知
  */
- (void)__reachabilityChanged:(NSNotification *)note
{
    MBReachability * reachability = [note object];
    NSParameterAssert([reachability isKindOfClass:[MBReachability class]]);
    
    // 网络状态
    NetworkStatus status = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    
    NSString * debugLog = @"";
    
    switch (status) {
        case NotReachable:  // 无网络
        {
            debugLog = NSLocalizedString(@"【本地网络通知】网络连接已断开!", @"");
            connectionRequired = NO;
            
            _isExistenceNetwork = NO;
            // 关闭 socket 连接
            [[UDPSocketProvider sharedInstance] closeLocalUDPSocket];
        }
            break;
            
        case ReachableViaWWAN: // 蜂窝网络、3G网络等
        case ReachableViaWiFi: // WIFI
        {
            debugLog = [NSString stringWithFormat:NSLocalizedString(@"本地网络通知】%@已连接! ", @""), (status == ReachableViaWiFi) ? @"WIFI" : @"Cellular"];
            
            _isExistenceNetwork = true;
            // 关闭 socket 连接
            [[UDPSocketProvider sharedInstance] closeLocalUDPSocket];
        }
            break;
            
        default:
            break;
    }
    
    if (connectionRequired) {
        debugLog = [NSString stringWithFormat:NSLocalizedString(@"【IMCORE】%@, Connection Required", @"Concatenation of status string with connection requirement"), debugLog];
    }
    
    if(__enabledDebug) {
        NSLog(@"%@", debugLog);
    }
}


#pragma mark - GET

- (MBReachability *)reachability
{
    if(_reachability == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(__reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        self.reachability = [MBReachability reachabilityForInternetConnection];
    }
    return _reachability;
}

@end
