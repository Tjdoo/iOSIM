//
//  LoginVC.m
//  iOSIM
//
//  Created by CYKJ on 2019/11/12.
//  Copyright © 2019年 D. All rights reserved.


#import "LoginVC.h"
#import "LoginProgress.h"
#import "ConfigEntity.h"
#import "Macros.h"
#import "UDPDataSender.h"
#import "CompletionDefine.h"
#import "IMVC.h"
#import "IMManager.h"
#import "ErrorCode.h"


@interface LoginVC () <LoginProgressDelegate>

@property (weak, nonatomic) IBOutlet UITextField * serviceTF;  // 服务器地址
@property (weak, nonatomic) IBOutlet UITextField * portTF;     // 服务器端口
@property (weak, nonatomic) IBOutlet UITextField * usernameTF; // 登录名
@property (weak, nonatomic) IBOutlet UITextField * passwordTF; // 登录密码

@property (nonatomic, strong) LoginProgress * loginProgress;  // 登录进度提示
@property (nonatomic, copy) ObserverCompletion loginSuccessObserver; // 收到服务端的登录完成反馈时

@end


@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginProgress = [[LoginProgress alloc] initWithDelegate:self];

    // 准备好异步登陆结果回调 block（将在登陆方法中使用）
    WEAK_SELF;
    self.loginSuccessObserver = ^(id observerble, id data) {
        STRONG_SELF;
        // 收到服务端登陆反馈，立即隐藏登录 loading
        [strongSelf.loginProgress showProgress:NO onView:strongSelf.view];
        
        // 服务端返回的登陆结果值
        int code = [(NSNumber *)data intValue];
        
        // 登陆成功
        if(code == 0) {
            IMVC * vc = [strongSelf.storyboard instantiateViewControllerWithIdentifier:@"IMVC_SBID"];
            [strongSelf.navigationController pushViewController:vc animated:YES];
        }
        // 登陆失败
        else {
            [strongSelf __showPrompt:[NSString stringWithFormat:@"Sorry，登陆失败，错误码=%d", code]];
        }
        
        [IMManager sharedInstance].loginBlock = nil;
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (IBAction)login:(id)sender
{
    // 服务器地址
    NSString * serverIP = [self.serviceTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    Log_ERROR_AND_RETURN(serverIP.length == 0, @"服务器地址不能为空！");

    // 服务器端口
    NSString * serverPort = self.portTF.text;
    Log_ERROR_AND_RETURN(serverPort.length == 0, @"服务器端口号不能为空！");

    // 登录名
    NSString * username = self.usernameTF.text;
    Log_ERROR_AND_RETURN(username.length == 0, @"登录名不能为空！");

    // 登录密码
    NSString * password = self.passwordTF.text;
    Log_ERROR_AND_RETURN(password.length == 0, @"登录密码不能为空！");


    // 设置服务器地址
    [ConfigEntity setServerIp:serverIP];
    // 设置服务器的 UDP 监听端口号
    [ConfigEntity setServerPort:[serverPort intValue]];

    // 向服务端发送登录信息
    [self __doLogin:username withPassword:password];
}

/**
  *  @brief   登录
  */
- (void)__doLogin:(NSString *)username withPassword:(NSString *)password
{
    // loading
    [self.loginProgress showProgress:YES onView:self.view];

    // 设置好服务端反馈的登录结果观察者（当客户端收到服务端反馈过来的登录消息时将被通知）
    [IMManager sharedInstance].loginBlock = self.loginSuccessObserver;

    // * 发送登录数据包(提交登录名和密码)
    int code = [[UDPDataSender sharedInstance] sendLogin:username withToken:password];

    if(code == COMMON_CODE_OK) {
        
    }
    else {
        // * 登录信息没有成功发出时当然无条件取消显示登录进度条
        [self.loginProgress showProgress:NO onView:self.view];
    }
}

- (void)__showPrompt:(NSString *)msg
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"友情提示"
                                                                      message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"知道了"
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - LoginProgressDelegate
/**
  *  @brief   登录超时
  */
- (void)loginTimeOut
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"超时了"
                                                   message:@"登录超时，可能是网络故障或服务器无法连接，是否重试？"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    WEAK_SELF;
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction * _Nonnull action) {
                                                  STRONG_SELF;
                                                  [strongSelf.loginProgress showProgress:NO
                                                                                  onView:self.view];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"重试"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
                                                  STRONG_SELF;
                                                  [strongSelf __doLogin:nil withPassword:nil];
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
