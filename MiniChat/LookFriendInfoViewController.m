//
//  LookFriendInfoViewController.m
//  MiniChat
//
//  Created by aatc on 8/28/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "LookFriendInfoViewController.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import "ChatSocket.h"
#import "MiniTalkViewController.h"
@interface LookFriendInfoViewController ()

@end

@implementation LookFriendInfoViewController

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
    userNameLabel.text = self.userFriendInfo.userName;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 100)];
    imageView.image = [UIImage imageNamed:@"Video_PlayReturnHL.png"];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [imageView release];
    [barItem setBackButtonBackgroundImage:[UIImage imageNamed:@"Video_PlayReturnHL.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    barItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barItem;
    [barItem release];
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//{“action”:”C-S-ASK-FRIEND-RES”,”userID”:”你自己的登陆的ID”,”userName”:”你自己登陆ID的昵称”,”TALKUserID”:”对方的ID”,”TALKUserName”:”对方的昵称”,” userResponse”:”YES|NO”}  userResponse ：YES 表示同意，NO表示不同意
- (IBAction)passAddFriend:(id)sender
{
    NSString *userID = [MainViewController sharedMainViewController].loginUser.userID;
    NSString *userName = [MainViewController sharedMainViewController].loginUser.userName;
    NSString *TALKUserName = self.friendMsg.msgFromUserID;
    NSString *TALKUserID = self.friendMsg.msgFromUserID;
    if (TALKUserID == nil) {
        return;
    }
    NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
    [dicC setObject:@"C-S-ASK-FRIEND-RES" forKey:@"action"];
    [dicC setObject:userID forKey:@"userID"];
    [dicC setObject:userName forKey:@"userName"];
    [dicC setObject:TALKUserID forKey:@"TALKUserID"];
    [dicC setObject:TALKUserName forKey:@"TALKUserName"];
    [dicC setObject:@"YES" forKey:@"userResponse"];
    
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:dicC options:NSJSONWritingPrettyPrinted error:nil];
    [[ChatSocket shareChatSocket].asynSocket writeData:data2 withTimeout:-1 tag:0];

}

- (IBAction)refuseAddFriend:(id)sender
{
    
}

- (IBAction)startTalkWithFriend:(id)sender
{
    self.hidesBottomBarWhenPushed = YES;
    MiniTalkViewController *miniTalkViewController = [[MiniTalkViewController alloc] initWithNibName:@"MiniTalkViewController" bundle:nil];
    miniTalkViewController.friendUserInfo = self.userFriendInfo;
    [self.navigationController pushViewController:miniTalkViewController animated:YES];
    [miniTalkViewController release];
}
- (void)dealloc {
    [userNameLabel release];
    [super dealloc];
}
@end
