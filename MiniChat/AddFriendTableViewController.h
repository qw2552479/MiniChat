//
//  AddFriendTableViewController.h
//  MiniChat
//
//  Created by aatc on 8/28/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationName.h"

@interface AddFriendTableViewController : UITableViewController
{
    NSMutableArray *sectionArrays;
    NSMutableArray *section1;
    NSMutableArray *onlineUserInfoSection;
    NSMutableArray *imageUrlQueue;
}
@end
