//
//  FriendInfoViewController.h
//  MiniChat
//
//  Created by aatc on 8/28/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserInfo;
@interface FriendInfoViewController : UIViewController
{
    UIImageView *friendHeadImageView;
    IBOutlet UILabel *friendNameLabel;
    IBOutlet UIImageView *friendSexImageView;
    IBOutlet UIButton *friendInfoButton;
    IBOutlet UIButton *friendAddToAddressButton;
}
@property (retain, nonatomic) IBOutlet UIButton *lookFromDetailInfo;
@property (nonatomic, retain) UserInfo *friendUserInfo;
- (IBAction)addFriendToAddress:(id)sender;
@end
