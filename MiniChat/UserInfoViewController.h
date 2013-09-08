//
//  UserInfoViewController.h
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActionSheetView.h"
@class UserInfo;
@interface UserInfoViewController : UITableViewController <UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ActionSheetViewDelegate>
{
    UserInfo *myUserInfo;
    NSMutableArray *sectionArrays;
    NSMutableArray *section1;
    NSMutableArray *section2;
    NSMutableArray *section3;
}

@end
