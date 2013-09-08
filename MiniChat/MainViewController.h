//
//  MainViewController.h
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfo;
@interface MainViewController : UIViewController

@property (nonatomic, retain) UINavigationController *mainNavigationController;
//登录用户
@property (nonatomic, retain) UserInfo *loginUser;

+(MainViewController *) sharedMainViewController;

@end
