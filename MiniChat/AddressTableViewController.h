//
//  AddressTableViewController.h
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenTalkView.h"
@interface AddressTableViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UISearchDisplayController *_addressSearchBarController;
    IBOutlet UISearchBar *addressSearchBar;
    NSMutableArray *sectionArrays;
    NSMutableArray *newFriendArray;//存newFriends和publicUser
    NSMutableArray *newFriends;//存好友邀请
    NSMutableArray *publicUser;//存公共帐号
    NSMutableArray *starFriendArray;//存新标好友
    NSMutableArray *userFriendInfoArray;//存所有好友
    NSMutableArray *userFrinedSections;
    NSMutableArray *imageUrlQueue;
    
    NSMutableArray *searchResults;
    id<OpenTalkView> _openTalkDelege;
    
}

@property (nonatomic, copy) NSString *documentsPath;
@property (nonatomic, assign) id<OpenTalkView>openTalkDelege;

@end
