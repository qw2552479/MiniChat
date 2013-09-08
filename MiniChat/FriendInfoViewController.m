//
//  FriendInfoViewController.m
//  MiniChat
//
//  Created by aatc on 8/28/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "FriendInfoViewController.h"
#import "UserInfo.h"
#import "MainViewController.h"
#import "ChatSocket.h"
@interface FriendInfoViewController ()

@end

@implementation FriendInfoViewController

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
    
    friendHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 48, 48)];
    friendHeadImageView.image = self.friendUserInfo.userImage;
    friendHeadImageView.layer.cornerRadius= 5;
    
    friendHeadImageView.layer.masksToBounds= YES;
    //边框宽度及颜色设置
    [friendHeadImageView.layer setBorderWidth:0];
    //自动适应,保持图片宽高比
    friendHeadImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:friendHeadImageView atIndex:1];
   // SignUpAddfriend_Btn@2x.png
    //SignUpEnterBar@2x.png
    friendNameLabel.text = self.friendUserInfo.userName;

    UIImage *friendInfoButtonImage = [UIImage imageNamed:@"SignUpEnterBar.png"];
    friendInfoButtonImage = [friendInfoButtonImage stretchableImageWithLeftCapWidth:(int)friendInfoButtonImage.size.width>>1 topCapHeight:0];
    
    UIImage *friendAddToAddressButtonImage = [UIImage imageNamed:@"SignUpAddfriend_Btn.png"];
    friendAddToAddressButtonImage = [friendAddToAddressButtonImage stretchableImageWithLeftCapWidth:(int)friendAddToAddressButtonImage.size.width>>1 topCapHeight:0];
    
    [friendInfoButton setBackgroundImage:friendInfoButtonImage forState:UIControlStateNormal];
    [friendAddToAddressButton setBackgroundImage:friendAddToAddressButtonImage forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [friendHeadImageView release];
    [friendNameLabel release];
    [friendSexImageView release];
    [friendInfoButton release];
    [friendAddToAddressButton release];
    [_lookFromDetailInfo release];
    [super dealloc];
}
//C-S-ASK-FRIEND-RES  - 增加某人后对方的回应 {“action”:”C-S-ASK-FRIEND-RES”,”userID”:”你自己的登陆的ID”,”userName”:”你自己登陆ID的昵称”,”TALKUserID”:”对方的ID”,”TALKUserName”:”对方的昵称”,” userResponse”:”YES|NO”}
- (IBAction)addFriendToAddress:(id)sender
{
//    C-S-ASK-FRIEND  -请求增加某人为好友 {“action”:”C-S-ASK-FRIEND”,”userID”:”登陆的ID”,”userName”:”登陆ID的昵称”,”TALKUserID”:”对方的ID”,”TALKUserName”:”对方的昵称”,  “askMsg”:”请求的信息”}
    NSString *userID = [MainViewController sharedMainViewController].loginUser.userID;
    NSString *userName = [MainViewController sharedMainViewController].loginUser.userName;
    NSString *TALKUserName = self.friendUserInfo.userName;
    NSString *TALKUserID = self.friendUserInfo.userID;
    if (TALKUserID == nil) {
        return;
    }
    NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
    [dicC setObject:@"C-S-ASK-FRIEND" forKey:@"action"];
    [dicC setObject:userID forKey:@"userID"];
    [dicC setObject:userName forKey:@"userName"];
    [dicC setObject:TALKUserID forKey:@"TALKUserID"];
    [dicC setObject:TALKUserName forKey:@"TALKUserName"];
    [dicC setObject:@"askMsg" forKey:@"askMsg"];
    
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:dicC options:NSJSONWritingPrettyPrinted error:nil];
    [[ChatSocket shareChatSocket].asynSocket writeData:data2 withTimeout:-1 tag:0];
}
@end
