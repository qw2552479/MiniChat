//
//  MeTableViewController.h
//  MiniChat
//
//  Created by aatc on 8/25/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserInfo;
@interface MeTableViewController : UITableViewController
{
    NSMutableArray *sectionArrays;
    NSMutableArray *section1;
    NSMutableArray *section2;
    NSMutableArray *section3;
    NSMutableArray *section4;
    
    UserInfo *myUserInfo;
}

@end
