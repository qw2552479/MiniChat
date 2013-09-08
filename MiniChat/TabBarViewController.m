//
//  TabBarViewController.m
//  MiniChat
//
//  Created by aatc on 8/27/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "TabBarViewController.h"
#import "RegisteViewController.h"
#import "AddressTableViewController.h"
#import "MiniTalkTableViewController.h"
#import "FriendsTableViewController.h"
#import "MeTableViewController.h"
#import "ASIFormDataRequest.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import "ChatSocket.h"
@interface TabBarViewController ()

@end

@implementation TabBarViewController

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
	// Do any additional setup after loading the view.
    [self initViewControllers];
}

- (void) initViewControllers
{
    UITabBarItem *tabbaritem1 = [[UITabBarItem alloc] initWithTitle:@"微信" image:nil tag:1];
    [tabbaritem1 setFinishedSelectedImage:[UIImage imageNamed:@"tab_weixin_pressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_weixin_normal.png"]];
    
    UITabBarItem *tabbaritem2 = [[UITabBarItem alloc] initWithTitle:@"通讯录" image:nil tag:1];
    [tabbaritem2 setFinishedSelectedImage:[UIImage imageNamed:@"tab_address_pressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_address_normal.png"]];
    
    UITabBarItem *tabbaritem3 = [[UITabBarItem alloc] initWithTitle:@"发现" image:nil tag:1];
    [tabbaritem3 setFinishedSelectedImage:[UIImage imageNamed:@"tab_find_frd_pressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_find_frd_normal.png"]];
    
    UITabBarItem *tabbaritem4 = [[UITabBarItem alloc] initWithTitle:@"我" image:nil tag:1];
    [tabbaritem4 setFinishedSelectedImage:[UIImage imageNamed:@"tab_settings_pressed.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_settings_normal.png"]];
    
    //视图控制器tabbar控制器
    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tab_bg_halo.9.png"];
    //微信主视图
    MiniTalkTableViewController *miniTalkTVC = [[MiniTalkTableViewController alloc] init];
    UINavigationController *miniTalkNC = [[UINavigationController alloc] initWithRootViewController:miniTalkTVC];
    [miniTalkTVC release];
    miniTalkTVC.tabBarItem = tabbaritem1;
    //通讯录视图
    AddressTableViewController *addressTVC = [[AddressTableViewController alloc] initWithNibName:@"AddressTableViewController" bundle:nil];
    UINavigationController *addressNC = [[UINavigationController alloc] initWithRootViewController:addressTVC];
    [addressTVC release];
    addressTVC.tabBarItem = tabbaritem2;
    //朋友视图
    FriendsTableViewController *friendsTVC = [[FriendsTableViewController alloc] initWithNibName:@"FriendsTableViewController" bundle:nil];
    UINavigationController *friendsNC = [[UINavigationController alloc] initWithRootViewController:friendsTVC];
    [friendsTVC release];
    friendsTVC.tabBarItem = tabbaritem3;
    //设置视图
    MeTableViewController *meTVC = [[MeTableViewController alloc] initWithNibName:@"MeTableViewController" bundle:nil];
    UINavigationController *meNC = [[UINavigationController alloc] initWithRootViewController:meTVC];
    [meTVC release];
    meTVC.tabBarItem = tabbaritem4;
   //交给address托管
    addressTVC.openTalkDelege = miniTalkTVC;
    
    [tabbaritem1 release];
    [tabbaritem2 release];
    [tabbaritem3 release];
    [tabbaritem4 release];
    
    NSArray *allControllers = [NSArray arrayWithObjects:miniTalkNC, addressNC, friendsNC, meNC, nil];
    
    [miniTalkNC release];
    [addressNC release];
    [friendsNC release];
    [meNC release];
    
    [self setViewControllers:allControllers animated:YES];
    [self downLoadUserInfo];
}
- (void)downLoadUserInfo
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/setting.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //要上传的数据
    myUserInfo = [MainViewController sharedMainViewController].loginUser;
    NSString *userID = myUserInfo.userID;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"getUserProfile" forKey:@"action"];
    [dic setObject:userID forKey:@"userID"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [request setPostValue:postString forKey:@"data"];
    
    [postString release];
    
    [request setFailedBlock:^{
        NSLog(@"set post string failed");
    }];
    
    [request setCompletionBlock:^{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
        if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
            NSArray *reArray = [dic objectForKey:@"reArray"];
            NSDictionary *userDic = [reArray objectAtIndex:0];
            NSLog(@"%@",userDic);
            [myUserInfo setUserID:[userDic objectForKey:@"userID"]];
            [myUserInfo setUserName:[userDic objectForKey:@"userName"]];
            [myUserInfo setUserSign:[userDic objectForKey:@"userSign"]];
            [myUserInfo setUserSex:[userDic objectForKey:@"userSex"]];
            [myUserInfo setUserType:[userDic objectForKey:@"userType"]];
            [myUserInfo setUserAge:[userDic objectForKey:@"userAge"]];
            [myUserInfo setUserImageUrl:[userDic objectForKey:@"userImageUrl"]];

            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",MINI_CHAT_HTTP_SERVER, myUserInfo.userImageUrl];
            
            [self downLoadUserImage:imageUrl];
        }
        
    }];
    
    [request startAsynchronous];
}

//下载个人头像
- (void)downLoadUserImage:(NSString *)imageUrl
{
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    [request setFailedBlock:^{
        NSLog(@"%@", @"failed");
    }];
    
    [request setCompletionBlock:^{
        UIImage *image = [UIImage imageWithData:request.responseData];
        [myUserInfo setUserImage:image];
    }];
    
    [request startAsynchronous];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
