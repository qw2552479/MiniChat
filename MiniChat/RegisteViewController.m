//
//  RegisteViewController.m
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "RegisteViewController.h"
#import "ASIFormDataRequest.h"
#import "SubRegisteViewController.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import <unistd.h>
#import "ChatSocket.h"
@interface RegisteViewController ()

@end

@implementation RegisteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [userIDTextField becomeFirstResponder];
    self.navigationItem.title = @"填写帐号密码";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
   // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(testLeftBarButton)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(testLeftBarButton)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
}
-(void)testLeftBarButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeFromParentViewConTroller
{
    [self.delegate setDoubleValues:[MainViewController sharedMainViewController].loginUser.userID];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)netxStepRegiste:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.dimBackground = YES;
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}

- (void)myTask {
    sleep(1.0f);
	NSString *strUrl = [NSString stringWithFormat:@"%@/setting.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //上传数据
    NSMutableDictionary *userRegisteInfoDic = [NSMutableDictionary dictionary];
    NSString *userID = [NSString stringWithString:userIDTextField.text];
    NSString *userPwd = [NSString stringWithString:userPwdTextField.text];
    //注册用户动作
    [userRegisteInfoDic setObject:@"registUser" forKey:@"action"];
    //用户帐号
    [userRegisteInfoDic setObject:userID forKey:@"userID"];
    //用户密码
    [userRegisteInfoDic setObject:userPwd forKey:@"userPwd"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:userRegisteInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setPostValue:postString forKey:@"data"];
    
    [postString release];
    
    [request setCompletionBlock:^{
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
                SubRegisteViewController *subRegisteViewController = [[SubRegisteViewController alloc] initWithNibName:@"SubRegisteViewController" bundle:nil];
                subRegisteViewController.delegate = self;
                
                UserInfo *userInfo = [[UserInfo alloc] init];
                [userInfo setUserID:userID];
                [MainViewController sharedMainViewController].loginUser = userInfo;
                [userInfo release];
                
                [userIDTextField resignFirstResponder];
                [userPwdTextField resignFirstResponder];
                [self.navigationController pushViewController:subRegisteViewController animated:YES];
                
                [subRegisteViewController release];
            } else {
                NSLog(@"registe failed");
            }
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"set poststring failed");
    }];
    
    
    [request startAsynchronous];

}
- (IBAction)tapBackground:(id)sender
{
    [userIDTextField resignFirstResponder];
    [userPwdTextField resignFirstResponder];
    
}
- (void)dealloc {
    self.delegate = nil;
    [userIDTextField release];
    [userPwdTextField release];
    [super dealloc];
}
@end
