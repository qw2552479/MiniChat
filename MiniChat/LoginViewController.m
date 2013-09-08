//
//  LoginViewController.m
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisteViewController.h"
#import "ASIFormDataRequest.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import <unistd.h>
#import "TabBarViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initializatio
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    self.navigationItem.title = @"微信";
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 81, 32)];
    [rightButton setTitle:@"切换帐号" forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"blackbt.png"] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:14]];
    [rightButton.titleLabel setHighlighted:YES];
    [rightButton addTarget:self action:@selector(changeUserID) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightButton release];
    
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIImage *buttonImage = [UIImage imageNamed:@"login_welcome_green_btn.9.png"];
    UIImage *stretchableImage = [buttonImage resizableImageWithCapInsets:insets];
    [loginButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    //重置位置
    [self resetLocation];
    loginStatus = L_DEFAULT;

    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(mySocketDidDisconnect:) name:NSNC_SocketDidDisconnect object:nil];
}

-(void)mySocketDidDisconnect:(NSNotification *)notification
{
    [HUD removeFromSuperview];
    loginStatus = L_SERVER_ERROR;
    [self showErrorAnimationByLoginStatus:loginStatus];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSNC_SocketDidDisconnect object:nil];
    [HUD removeFromSuperview];
}

-(void) resetLocation
{
    if (userIDTextField.text.length > 0) {
        [userIDTextField setEnabled:NO];
        [userIDLabel setHidden:NO];
        [userPwdLabel setHidden:NO];
        [userPwdImageView setHidden:NO];
        
        userIDLabel.frame = CGRectMake(20, 15, 42, 20);
        userIDTextField.frame = CGRectMake(65, 10, 235, 30);
        userIDTextField.borderStyle = UITextBorderStyleNone;
        userIDTextField.placeholder = @"";
        userPwdImageView.frame = CGRectMake(10, 45, 300, 50);
        userPwdLabel.frame = CGRectMake(20, 60, 35, 20);
        userPwdTextField.frame = CGRectMake(65, 55, 235, 30);
        userPwdTextField.borderStyle = UITextBorderStyleNone;
        userPwdTextField.placeholder = @"";
        
    } else {
        [userIDTextField becomeFirstResponder];
        [userIDTextField setEnabled:YES];
        [userIDLabel setHidden:YES];
        [userPwdLabel setHidden:YES];
        [userPwdImageView setHidden:YES];
        
        userIDTextField.frame = CGRectMake(10, 20, 300, 30);
        userIDTextField.borderStyle = UITextBorderStyleRoundedRect;
        userIDTextField.placeholder = @"QQ号/微信号/手机号";
        userPwdTextField.frame = CGRectMake(10, 65, 300, 30);
        userPwdTextField.borderStyle = UITextBorderStyleRoundedRect;
        userPwdTextField.placeholder = @"密码";
    }
}
//subregiste类的代理方法
-(void)setDoubleValues:(NSString *)firstString
{
    userIDTextField.text = firstString;

}
#pragma mark - socket连接
//登录3步骤
//1.验证用户名密码
//2.socket链接
//3.传socket
- (void)myTask
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/login.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //要上传的数据
    NSString *userID = userIDTextField.text;
    NSString *userPwd = userPwdTextField.text;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"login" forKey:@"action"];
    [dic setObject:userID forKey:@"userID"];
    [dic setObject:userPwd forKey:@"userPwd"];
    NSLog(@"%@,%@", userID, userPwd);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [request setPostValue:postString forKey:@"data"];
    
    [postString release];
    
    [request setFailedBlock:^{
        [HUD removeFromSuperview];
        loginStatus = L_SERVER_ERROR;
        [self showErrorAnimationByLoginStatus:loginStatus];
    }];
    
    [request setCompletionBlock:^{
        
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
                NSString *userIDStr = [[[dic objectForKey:@"reArray"] objectAtIndex:0] objectForKey:@"userID"];
                
                UserInfo *userInfo = [[UserInfo alloc] init];
                [userInfo setUserID:userIDStr];
                [userInfo setUserPwd:userPwdTextField.text];
                [MainViewController sharedMainViewController].loginUser = userInfo;
                [userInfo release];
                
                [self connectToMiniServer];
            } else if ([[dic objectForKey:@"statusID"] isEqualToString:@"-1"]) {
                [HUD removeFromSuperview];
                loginStatus = L_PASSWROD_ERROR;
                [self showErrorAnimationByLoginStatus:loginStatus];
            }
        }
    }];
    
    [request startAsynchronous];
    sleep(10.0f);
}

//建立与服务器的连接
-(void) connectToMiniServer
{
    ChatSocket *chatSocket = [ChatSocket shareChatSocket];
    chatSocket.degelate = self;
    if ([chatSocket connectMiniChatSocketServer]) {
        NSLog(@"ok");
    } else {
        loginStatus = L_SERVER_ERROR;
        [self showErrorAnimationByLoginStatus:loginStatus];
    }
}
//二次验证成功
-(void)sentSuccessInfoToClient:(NSData *)data
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([[dic objectForKey:@"action"] isEqualToString:@"S-LOGIN-SUCESS"]) {
        [HUD removeFromSuperview];
        TabBarViewController *tabBarVC = [[TabBarViewController alloc] init];
        [self presentViewController:tabBarVC animated:YES completion:nil];
        [tabBarVC release];
    }
}
//初始化所有控制器

#pragma mark - ButtonFunction

- (IBAction)login:(id)sender
{
    if (![self checkUserIDAndPwd]) {
        return;
    }
    //  [self showErrorAnimationByLoginStatus:loginStatus];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //HUD.frame = CGRectMake(frame.origin.x, frame.origin.y - 150, frame.size.width, frame.size.height - 150);
    HUD.yOffset = -100;
	[self.navigationController.view addSubview:HUD];
	HUD.dimBackground = YES;
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}

-(void)changeUserID
{
    userIDTextField.text = nil;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self resetLocation];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)registe:(id)sender
{
    [self hideKeyBoard];
    RegisteViewController *registeVC = [[RegisteViewController alloc] initWithNibName:@"RegisteViewController" bundle:nil];
    UINavigationController *registeNC = [[UINavigationController alloc] initWithRootViewController:registeVC];
    [registeVC release];
    registeVC.delegate = self;
    [self presentViewController:registeNC animated:YES completion:nil];
    [registeNC release];
}

- (IBAction)forgetPwd:(id)sender
{
    
}

- (IBAction)tapBackground:(id)sender
{
    [self hideKeyBoard];
}

-(void) hideKeyBoard
{
    [userIDTextField resignFirstResponder];
    [userPwdTextField resignFirstResponder];
}

#pragma mark - uiTextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(BOOL)checkUserIDAndPwd
{
    if (userIDTextField.text.length == 0) {
        loginStatus = L_USERID_NULL;
        [self showErrorAnimationByLoginStatus:loginStatus];
        return false;
    }
    if (userPwdTextField.text.length == 0) {
        loginStatus = L_PASSWROD_NULL;
        [self showErrorAnimationByLoginStatus:loginStatus];
        return false;
    }
    
    Utils *u = [[Utils alloc] init];
    if (![u accountIsRight:userIDTextField.text]) {
        loginStatus = L_USERID_ERROR;
        [u release];
        [self showErrorAnimationByLoginStatus:loginStatus];
        return false;
    }
//    if (![u passwordIsRight:userPwdTextField.text]) {
//        loginStatus = L_PASSWROD_ERROR;
//        [u release];
//        [self showErrorAnimationByLoginStatus:loginStatus];
//        return false;
//    }
    [u release];
    return true;
}

-(void)showErrorAnimationByLoginStatus:(LoginStatus) status
{
    MBProgressHUD *hud;
    switch (loginStatus) {
        case L_DEFAULT:
            break;
        case L_PASSWROD_ERROR:
        case L_USERID_ERROR:
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"帐号或者密码错误";
            hud.margin = 10.f;
            hud.yOffset = -100.f;
            hud.dimBackground = YES;
            hud.removeFromSuperViewOnHide = YES;
            loginStatus = L_DEFAULT;
            [hud hide:YES afterDelay:1];
            return;
            break;
        case L_USERID_NULL:
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"帐号不能为空";
            hud.margin = 10.f;
            hud.yOffset = -100.f;
            hud.dimBackground = YES;
            hud.removeFromSuperViewOnHide = YES;
            loginStatus = L_DEFAULT;
            [hud hide:YES afterDelay:1];
            return;
            break;
        case L_PASSWROD_NULL:
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"密码不能为空";
            hud.margin = 10.f;
            hud.yOffset = -100.f;
            hud.dimBackground = YES;
            hud.removeFromSuperViewOnHide = YES;
            loginStatus = L_DEFAULT;
            [hud hide:YES afterDelay:1];
            return;
            break;
        case L_SERVER_ERROR:
            hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"网络出现问题";
            hud.margin = 10.f;
            hud.yOffset = -100.f;
            hud.dimBackground = YES;
            hud.removeFromSuperViewOnHide = YES;
            loginStatus = L_DEFAULT;
            [hud hide:YES afterDelay:1];
            return;
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [userIDTextField release];
    [userPwdTextField release];
    [userIDLabel release];
    [userPwdLabel release];
    [userPwdImageView release];
    [loginButton release];
    [HUD release];
    HUD = nil;
    [super dealloc];
}

@end
