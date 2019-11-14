//
//  SocketVC.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/13.
//  Copyright © 2019年 D. All rights reserved.


#import "SocketVC.h"
#import "Macros.h"
#import "IMManager.h"

#import "SocketTVCell.h"
#import "ClientCoreSDK.h"
#import "UDPDataSender.h"
#import "AutoReloginDaemon.h"
#import "KeepAliveDaemon.h"
#import "QoS4SendDaemon.h"
#import "QoS4ReciveDaemon.h"


@interface SocketVC ()
{
    CGFloat __startPointX; // 滑动初始点的 x 值
}
@property (weak, nonatomic) IBOutlet UIView * bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bgViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel * connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel * userIdLabel;
@property (weak, nonatomic) IBOutlet UITextField * chatPeopleTF;
@property (weak, nonatomic) IBOutlet UIImageView * autoReloadIV;
@property (weak, nonatomic) IBOutlet UIImageView * keepAliveIV;
@property (weak, nonatomic) IBOutlet UIImageView * qosSendIV;
@property (weak, nonatomic) IBOutlet UIImageView * qosReceiveIV;
@property (weak, nonatomic) IBOutlet UIButton * logoutBtn;
@property (weak, nonatomic) IBOutlet UITableView * tableView;

@property (nonatomic, copy) NSArray<LogModel *> * logList;

@end


@implementation SocketVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self __updateSubviews];
    // 设置调试相关
    [self __setupDebug];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 更新网络状态
    [self __refreshConnectStatus];
    // 更新服务指示灯
    [self __refreshIndicatorLight];
    // 更新 log 数据
    [self __refreshLogInfo];
    
    // 将当前账号显示出来
    self.userIdLabel.text = [ClientCoreSDK sharedInstance].loginUserID;
}

- (void)__updateSubviews
{
    CGFloat leading = SCREEN_RATIO * 50;
    self.bgViewLeadingConstraint.constant = leading;
    
    // 圆角
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH - leading, SCREEN_HEIGHT);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect
                                           byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                      cornerRadii:CGSizeMake(9, 9)];
    CAShapeLayer * shape = [CAShapeLayer layer];
    shape.frame = rect;
    shape.path = path.CGPath;
    self.bgView.layer.mask = shape;
    
    // 阴影效果
    _logoutBtn.layer.shadowColor   = UIColorFromRGBA_0x(0xFD924A, 0.3).CGColor;
    _logoutBtn.layer.shadowOffset  = CGSizeMake(0, 5);
    _logoutBtn.layer.shadowOpacity = 1;
    _logoutBtn.layer.shadowRadius  = 12.5;
    _logoutBtn.layer.masksToBounds = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:SOCKET_TV_CELL_NIB bundle:nil] forCellReuseIdentifier:SOCKET_TV_CELL_RUID];
}

/**
  *  @brief   设置调试
  */
- (void)__setupDebug
{
    [self __setupAnimationForStatusImage:self.autoReloadIV];
    [self __setupAnimationForStatusImage:self.keepAliveIV];
    [self __setupAnimationForStatusImage:self.qosSendIV];
    [self __setupAnimationForStatusImage:self.qosReceiveIV];
    
    [AutoReloginDaemon sharedInstance].debugObserver = [self __observerForDebug:self.autoReloadIV];
    [KeepAliveDaemon sharedInstance].debugObserver = [self __observerForDebug:self.keepAliveIV];
    [QoS4SendDaemon sharedInstance].debugObserver = [self __observerForDebug:self.qosSendIV];
    [QoS4ReciveDaemon sharedInstance].debugObserver = [self __observerForDebug:self.qosReceiveIV];
}

- (void)__setupAnimationForStatusImage:(UIImageView *)iv
{
    iv.animationImages = @[ [UIImage imageNamed:@"绿色圆点_light"],
                            [UIImage imageNamed:@"绿色圆点"] ];
    iv.animationDuration = 0.5;
    iv.animationRepeatCount = 1;
}

- (ObserverCompletion)__observerForDebug:(UIImageView *)iv
{
    return ^(id observerble, id data) {
        int status = [(NSNumber *)data intValue];
        [self __showIndicatorImage:status forImageView:iv];
    };;
}

/**
  *  @brief   更新网络状态
  */
- (void)__refreshConnectStatus
{
    if ([ClientCoreSDK sharedInstance].connectedToServer) {
        self.connectStatusLabel.text = @"通信正常";
        self.connectStatusLabel.textColor = UIColorFromRGBA_0x(0x65AC47, 1.0);
    }
    else {
        self.connectStatusLabel.text = @"连接断开";
        self.connectStatusLabel.textColor = UIColorFromRGBA_0x(0xFF00FF, 1.0);
    }
}

/**
  *  @brief   更新服务指示灯
  */
- (void)__refreshIndicatorLight
{
    [self __showIndicatorImage:([[AutoReloginDaemon sharedInstance] isAutoReLoginRunning] ? 1 : 0)
                  forImageView:self.autoReloadIV];
    [self __showIndicatorImage:([[KeepAliveDaemon sharedInstance] isKeepAliveRunning] ? 1 : 0)
                  forImageView:self.keepAliveIV];
    [self __showIndicatorImage:([[QoS4SendDaemon sharedInstance] isRunning] ? 1 : 0)
                    forImageView:self.qosSendIV];
    [self __showIndicatorImage:([[QoS4ReciveDaemon sharedInstance] isRunning] ? 1 : 0)
                  forImageView:self.qosReceiveIV];
}

/**
  *  @brief   指示灯
  */
- (void)__showIndicatorImage:(int)status forImageView:(UIImageView *)iv
{
    if(iv.hidden)
        iv.hidden = NO;
    
    if(status == 1) {
        // 确保先stop ，否则正在动画中时此时设置图片则只会停在动画的最后一帧
        if([iv isAnimating])
            [iv stopAnimating];
        
        [iv setImage:[UIImage imageNamed:@"绿色圆点"]];
    }
    else if(status == 2) {
        [iv setImage:[UIImage imageNamed:@"绿色圆点"]];
        if([iv isAnimating]) {
            [iv stopAnimating];
        }
        [iv startAnimating];
    }
    else {
        // 确保先stop ，否则正在动画中时此时设置图片则只会停在动画的最后一帧
        if([iv isAnimating])
            [iv stopAnimating];
        [iv setImage:[UIImage imageNamed:@"灰色圆点"]];
    }
}

/**
  *  @brief   退出登录
  */
- (void)__doLogout
{
    // 发出退出登陆请求包
    int code = [[UDPDataSender sharedInstance] sendLogout];
    
    if(code == COMMON_CODE_OK) {
        [self __refreshConnectStatus];
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(0, 255, 0, 1.0)
                                                 content:@"注销登陆请求已完成。"];
        [[IMManager sharedInstance] addLog:log];
    }
    else {
        // 添加日志
        LogModel * log = [[LogModel alloc] initWithColor:UIColorFromRGBA(255, 0, 0, 1.0) content:[NSString stringWithFormat:@"注销登陆请求发送失败，错误码：%d", code]];
        [[IMManager sharedInstance] addLog:log];
    }
    
    [[IMManager sharedInstance] releaseIMSDK];
}

/**
  *  @brief   退出程序
  */
- (void)__doExit
{
    UIWindow * window = [UIApplication sharedApplication].delegate.window;
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

/**
 *  @brief   显示日志信息
 */
- (void)__refreshLogInfo
{
    self.logList = [[IMManager sharedInstance] logData];
    [self __calculateAllCellHeight];
    
    [self.tableView reloadData];
    
    // 自动显示最后一行
    NSInteger s = [self.tableView numberOfSections];
    if (s < 1)
        return;
    NSInteger r = [self.tableView numberOfRowsInSection:s-1];
    if (r < 1)
        return;
    NSIndexPath * ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/**
  *  @brief   根据显示内容计算行高
  */
- (void)__calculateAllCellHeight
{
    if(self.logList.count == 0)
        return;
    
    CGFloat w = self.tableView.frame.size.width;
    UIFont * font = [UIFont systemFontOfSize:14];

    [self.logList enumerateObjectsUsingBlock:^(LogModel * obj, NSUInteger idx, BOOL * stop) {
        
        obj.height = [obj.content boundingRectWithSize:CGSizeMake(w, MAXFLOAT)
                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName : font }
                                               context:nil].size.height;
    }];
}


#pragma mark - Touch

- (IBAction)pan:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        __startPointX = point.x;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        if (point.x >= __startPointX) {
            CGFloat ratio = 1 - (point.x - __startPointX)/ 100.0;
            self.bgView.backgroundColor = UIColorFromRGBA_0x(0x000000, ratio * 0.4);
            self.bgViewLeadingConstraint.constant = SCREEN_RATIO * 60 + point.x - __startPointX;
            [self.bgView layoutIfNeeded];
        }
    }
}

/**
 *  @brief   退出登录
 */
- (IBAction)logout:(UIButton *)sender
{
    // 退出登陆
    [self __doLogout];
    // 退出程序
    [self __doExit];
}


#pragma mark - UITableViewDelegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.logList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogModel * log = self.logList[indexPath.section];
    return log.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SocketTVCell * cell = [tableView dequeueReusableCellWithIdentifier:SOCKET_TV_CELL_RUID
                                                          forIndexPath:indexPath];
    
    LogModel * log = self.logList[indexPath.section];
    cell.contentLabel.textColor = log.color;
    cell.contentLabel.text = log.content;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
