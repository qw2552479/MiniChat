//
//  LookFriendInfoViewController.h
//  MiniChat
//
//  Created by aatc on 8/28/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserMsg;
@class UserInfo;
@interface LookFriendInfoViewController : UIViewController
{
    IBOutlet UILabel *userNameLabel;
}

@property (nonatomic, retain) UserMsg *friendMsg;
@property (nonatomic, retain) UserInfo *userFriendInfo;

- (IBAction)passAddFriend:(id)sender;
- (IBAction)refuseAddFriend:(id)sender;
- (IBAction)startTalkWithFriend:(id)sender;
@end
