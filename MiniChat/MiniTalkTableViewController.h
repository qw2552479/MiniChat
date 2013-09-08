//
//  MiniTalkTableViewController.h
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationName.h"
#import "OpenTalkView.h"
@interface MiniTalkTableViewController : UITableViewController<UIGestureRecognizerDelegate,OpenTalkView>
{
    NSMutableArray *sectionArrays;
    NSMutableArray *messageFromFriend;

    NSMutableArray *searchResults;
    float headSectionHeiht;
    
}


@end