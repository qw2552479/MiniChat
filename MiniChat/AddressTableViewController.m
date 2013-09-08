//
//  AddressTableViewController.m
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "AddressTableViewController.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import "ASIFormDataRequest.h"
#import "AddFriendTableViewController.h"
#import "LookFriendInfoViewController.h"
#import "NewFriendsTableViewController.h"
#import "AddressCell.h"
#import <objc/runtime.h>
#import "ChatSocket.h"

const static CGFloat kDeleteButtonWidth = 100.f;
const static CGFloat kDeleteButtonHeight = 58.0f;

#define screenWidth() (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)


const static char * kYFJLeftSwipeDeleteTableViewCellIndexPathKey = "YFJLeftSwipeDeleteTableViewCellIndexPathKey";

@interface UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPath;

@end

@implementation UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, kYFJLeftSwipeDeleteTableViewCellIndexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)indexPath {
    id obj = objc_getAssociatedObject(self, kYFJLeftSwipeDeleteTableViewCellIndexPathKey);
    if([obj isKindOfClass:[NSIndexPath class]]) {
        return (NSIndexPath *)obj;
    }
    return nil;
}

@end


@interface AddressTableViewController ()
{
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    
    UIButton * _deleteButton;
    
    NSIndexPath * _editingIndexPath;
}

@end

@implementation AddressTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftGestureRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:_leftGestureRecognizer];
    
    _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _rightGestureRecognizer.delegate = self;
    _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:_rightGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
    // Don't add this yet
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(screenWidth(), 0, kDeleteButtonWidth, kDeleteButtonHeight);
    _deleteButton.backgroundColor = [UIColor colorWithRed:128.0/255 green:131.0/255 blue:133.0/255 alpha:1];
    _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:_deleteButton];
    
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    self.tableView.bounces = NO;
    self.navigationItem.title = @"地址";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [addressSearchBar setTintColor:[UIColor colorWithRed:195.0/255 green:196.0/255 blue:198.0/255 alpha:1.0]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 100)];
    imageView.image = [UIImage imageNamed:@"Video_PlayReturnHL.png"];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [imageView release];
    [barItem setBackButtonBackgroundImage:[UIImage imageNamed:@"Video_PlayReturnHL.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    barItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barItem;
    [barItem release];

    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    UIImage *rigthImage = [UIImage imageNamed:@"AlbumOperateMoreViewBkg.png"];
    rigthImage = [rigthImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [rightButton setBackgroundImage:rigthImage forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"contacts_add_friend.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];
    self.tableView.tableHeaderView = addressSearchBar;
    [addressSearchBar setTintColor:[UIColor colorWithRed:195.0/255 green:196.0/255 blue:198.0/255 alpha:1.0]];
    [addressSearchBar sizeToFit];
    addressSearchBar.delegate = self;
    
    _addressSearchBarController = [[UISearchDisplayController alloc] initWithSearchBar:addressSearchBar contentsController:self];
    searchResults = [[NSMutableArray alloc] init];
    _addressSearchBarController.delegate = self;
    _addressSearchBarController.searchResultsDataSource = self;
    _addressSearchBarController.searchResultsDelegate = self;
    [addressSearchBar release];
      
    //数据处理
    sectionArrays = [[NSMutableArray alloc] init];
    newFriendArray = [[NSMutableArray alloc] init];//1
    starFriendArray= [[NSMutableArray alloc] init];//2
    //保存每个section里面的信息
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    userFrinedSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];//3 
    [sectionArrays insertObject:newFriendArray atIndex:0];
    [sectionArrays insertObject:starFriendArray atIndex:1];
    [sectionArrays insertObject:userFrinedSections atIndex:2];
   
    userFriendInfoArray = [[NSMutableArray alloc] init];
    
    [newFriendArray release];
    [starFriendArray release];

    newFriends = [[NSMutableArray alloc] init];
    publicUser = [[NSMutableArray alloc] init];
    [newFriendArray insertObject:newFriends atIndex:0];
    [newFriendArray insertObject:publicUser atIndex:1];
    [newFriends release];
    [publicUser release];
     
    UserInfo *starUser = [[UserInfo alloc] init];
    [starUser setIsYourFriend:YES];
    [starUser setUserName:@"公共帐号"];
    [starUser setUserSign:@"哈哈"];
    [starUser setUserSex:@"男"];
    [starUser setUserType:@"男"];
    [starUser setUserAge:@"16"];
    [starUser setUserImageUrl:@"dsa"];
    [starUser setUserImage:[UIImage imageNamed:@"dsa"]];
    [starFriendArray addObject:starUser];
    [starUser release];

    [self getFriendListFromServer];
    //test

     imageUrlQueue = [[NSMutableArray alloc] init];
    //收到别人请求加好友信息
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getResquestAddFriend:) name:NSNC_S_C_ASK_FRIEND_TO object:nil];
   //对方接受加好友
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getFriendListFromServer) name:NSNC_S_C_ASK_FRIEND_RES_YES object:nil];
     //对方拒绝加好友
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(askAddFriendFailed:) name:NSNC_S_C_ASK_FRIEND_RES_NO object:nil];
}

-(void)test
{
    [userFrinedSections removeAllObjects];
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index, sectionTitlesCount = [[theCollation sectionTitles] count];
    //设置 每个section数组
    for (index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [userFrinedSections addObject:array];
        [array release];
    }
    //将名字按头字母放入对应的section数组中（每个section数组对应一个字母）
    for (UserInfo *userInfo in userFriendInfoArray) {
        NSInteger sect = [theCollation sectionForObject:userInfo collationStringSelector:@selector(getFirstString)];
        //记录下对象的section id
        [[userFrinedSections objectAtIndex:sect] addObject:userInfo];
    }
    ////将每个setion数组排序，其实这步可以不用
    for (index = 0; index < sectionTitlesCount; index++) {
    
        NSMutableArray *newSection = [userFrinedSections objectAtIndex:index];
    //    //获得排序结果
        NSArray *sortedSectionArray = [theCollation sortedArrayFromArray:newSection collationStringSelector:@selector(description)];
        //替换原来数组
        [userFrinedSections replaceObjectAtIndex:index withObject:sortedSectionArray];
    }
    [self.tableView reloadData];
}

//    {"statusID":"0","msg":"【你爸爸】 想加你为好友！ 请选择？","action":"S-C-ASK-FRIEND-TO","reArray":[],"reTime":"2013-08-28 09:08:32","askMsg":"\u4f60\u7238\u7238","userIDFrom":"xiaoxiao","userNameFrom":null}
//显示这条消息
//C-S-ASK-FRIEND-RES  - 增加某人后对方的回应 {“action”:”C-S-ASK-FRIEND-RES”,”userID”:”你自己的登陆的ID”,”userName”:”你自己登陆ID的昵称”,”TALKUserID”:”对方的ID”,”TALKUserName”:”对方的昵称”,” userResponse”:”YES|NO”}
-(void)askAddFriendFailed:(NSNotification *)notification
{
    //    NSDictionary *dicS = (NSDictionary *)notification;
    //    NSAssert([(NSDictionary *)notification isKindOfClass:[NSDictionary class]], @"(NSDictionary *)notification must be a diciionart");
    //    NSString *actionString = [dicS objectForKey:@"action"];
}

-(void)askAddFriendSucess:(NSNotification *)notification
{
    NSLog(@"yes");
    return;
    NSDictionary *dicS = (NSDictionary *)notification;
    // NSAssert([(NSDictionary *)notification isKindOfClass:[NSDictionary class]], @"(NSDictionary *)notification must be a diciionart");
    NSString *actionString = [dicS objectForKey:@"action"];
    //S-LOGIN-2表示服务器发给客户端 需要立即传递userID
    if ([actionString isEqualToString:@"S-C-ASK-FRIEND-RES-YES"]) {
        //要上传的数据
        NSString *userID = [MainViewController sharedMainViewController].loginUser.userID;
        
        NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
        [dicC setObject:@"C-LOGIN-2" forKey:@"action"];
        [dicC setObject:userID forKey:@"userID"];

    }
}
#pragma mark - getResquestAddFriend
-(void)getResquestAddFriend:(NSNotification *)notification
{
    NSDictionary *dicS = notification.object;
    NSAssert([notification.object isKindOfClass:[NSDictionary class]], @"(NSDictionary *)notification must be a diciionart");
    NSString *actionString = [dicS objectForKey:@"statusID"];
    if ([actionString isEqualToString:@"0"]) {
        //要上传的数据
        UserMsg *userMsg = [[UserMsg alloc] init];
        [userMsg setIsRead:NO];
        [userMsg setMsgFromUserID:[dicS objectForKey:@"userIDFrom"]];
        [userMsg setMsgType:[dicS objectForKey:@"msg"]];
        [userMsg setMsgText:[dicS objectForKey:@"askMsg"]];
        [userMsg setMsgTime:[dicS objectForKey:@"reTime"]];
        [newFriends addObject:userMsg];
        [userMsg release];
        if (newFriends.count > 0) {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", newFriends.count];
        }
        [self.tableView reloadData];
    }
}
-(void) getFriendListFromServer
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/login.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //上传数据
    NSMutableDictionary *dicByClient = [NSMutableDictionary dictionary];
    //注册动作
    NSString *loginUserID_ = [MainViewController sharedMainViewController].loginUser.userID;
    [dicByClient setObject:@"getMyFriends" forKey:@"action"];
    //用户帐号
    [dicByClient setObject:loginUserID_ forKey:@"userID"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicByClient options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [request setPostValue:postString forKey:@"data"];
    [postString release];
    
    [request setCompletionBlock:^{
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dicFromPHP = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dicFromPHP) {
            if ([[dicFromPHP objectForKey:@"statusID"] isEqualToString:@"0"]) {     
                UserInfo *onlineInfo;
                for (NSDictionary *onlineUserInfoDic in [dicFromPHP objectForKey:@"reArray"]) {
                    BOOL isSame = NO;
                    for (UserInfo *userInfo in userFriendInfoArray) {
                        if ([userInfo.userID isEqualToString:[onlineUserInfoDic objectForKey:@"userID"]]) {
                            isSame = YES;
                            break;
                        }
                    }
                    if (isSame == NO) {
                        onlineInfo = [[UserInfo alloc] init];
                        [onlineInfo setUserID:[onlineUserInfoDic objectForKey:@"userID"]];
                        [onlineInfo setUserName:[onlineUserInfoDic objectForKey:@"userName"]];
                        [onlineInfo setUserStatusTime:[dicFromPHP objectForKey:@"reTime"]];
                        [onlineInfo setUserSex:[onlineUserInfoDic objectForKey:@"userSex"]];
                        [onlineInfo setUserType:[onlineUserInfoDic objectForKey:@"userType"]];
                        [onlineInfo setUserAge:[onlineUserInfoDic objectForKey:@"userAge"]];
                        [onlineInfo setUserImageUrl:[onlineUserInfoDic objectForKey:@"userImage"]];
                        [onlineInfo setUserStatusLogo:[onlineUserInfoDic objectForKey:@"userStatusLogo"]];
                        [onlineInfo setUserImage:[UIImage imageNamed:@"DefaultHead.png"]];
                        [userFriendInfoArray addObject:onlineInfo];
                        [imageUrlQueue addObject:onlineInfo];
                        [onlineInfo release];
                    }
                }
                [self test];
                [self downLoadImage];

            } else {
                NSLog(@"registe failed");
            }
            
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"set poststring failed");
    }];
    
    [request startAsynchronous];
}
-(void)downLoadImage
{
    if (imageUrlQueue.count <= 0) {
        return;
    }
    UserInfo *u = [imageUrlQueue objectAtIndex:0];
    NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    NSString *imageFilePath = [docPath stringByAppendingString:u.userImageUrl];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        u.userImage = [UIImage imageWithContentsOfFile:imageFilePath];
        [imageUrlQueue removeObject:u];
        [self.tableView reloadData];
        [self downLoadImage];
        
        return;
    } else {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",MINI_CHAT_HTTP_SERVER, u.userImageUrl];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        [request setFailedBlock:^{
            NSLog(@"%@", @"failed");
        }];
        
        [request setCompletionBlock:^{
            UIImage *image = [UIImage imageWithData:request.responseData];
            //[[NSFileManager defaultManager] createFileAtPath:localURL contents:data attributes:nil];
            u.userImage = image;
            NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
            NSString *imageDir = [docPath stringByAppendingString:@"images"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:NO attributes:nil error:nil];
            }
            //imageurl样式 images／image343243er.png
            NSString *imageFilePath = [docPath stringByAppendingString:u.userImageUrl];
            [request.responseData writeToFile:imageFilePath atomically:YES];
            [imageUrlQueue removeObject:u];
            [self.tableView reloadData];
            
            [self downLoadImage];
        }];
        [request startAsynchronous];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addFriend
{
    self.hidesBottomBarWhenPushed = YES;
    AddFriendTableViewController *addFriendTVC = [[AddFriendTableViewController alloc] initWithNibName:@"AddFriendTableViewController" bundle:nil];
    [self.navigationController pushViewController:addFriendTVC animated:YES];
    [addFriendTVC release];
}
#pragma - UISearchDisplayController delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	[searchResults removeAllObjects]; // First clear the filtered array.
	
	for (UserInfo *userinfo in userFriendInfoArray)
	{
        NSRange range = [[userinfo.userName lowercaseString] rangeOfString:[searchText lowercaseString]];
		
        if (range.location != NSNotFound)
		{
			[searchResults addObject:userinfo];
		}
	}
}
#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:_addressSearchBarController.searchResultsTableView]) {
        return 0.f;
    }
    if (section == 0) {
        return 0.f;
    }
    if (section == 1) {
        return 20.0f;
    }
    if ([[userFrinedSections objectAtIndex:(section - 2)] count] == 0) {
        return 0.f;
    }
    
    return 20.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if ([tableView isEqual:_addressSearchBarController.searchResultsTableView]) {
        return 1;
    }
    return (1 + starFriendArray.count + userFrinedSections.count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_addressSearchBarController.searchResultsTableView]) {
        return 50.f;
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (newFriends.count == 0) {
            return 0;
        }
    }
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([tableView isEqual:_addressSearchBarController.searchResultsTableView]) {
        return searchResults.count;
    }
    
    if (section == 0) {
        return newFriendArray.count;
    }
    if (section == 1) {
        return starFriendArray.count;
    }
    return [[userFrinedSections objectAtIndex:(section - 2)] count];
}

#pragma mark - title of section

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    }
    if (section == 1) {
        return @"星标帐号";
    }
    
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section - 2];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSLog(@"%i",[[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index]);
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddressCell";
    AddressCell *cell = (AddressCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddressCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ([tableView isEqual:_addressSearchBarController.searchResultsTableView]) {
        //取搜索结果的好友
        cell.redImageView.image = nil;
        cell.numOfMessageLabel.text = nil;
        UserInfo *userinfo = [searchResults objectAtIndex:indexPath.row];
        cell.nameLabel.text = userinfo.userName;
        cell.headImageView.image = userinfo.userImage;
        cell.userSignText.text = userinfo.userSign;
        return cell;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (newFriends.count > 0) {
                cell.headImageView.image = [UIImage imageNamed:@"Plugins_FriendAssist_avatar.png"];
                cell.redImageView.image = [UIImage imageNamed:@"friendactivity_newnotice.png"];
                cell.numOfMessageLabel.text = [NSString stringWithFormat:@"%d", newFriends.count];
                cell.nameLabel.text = @"新的朋友";
            } 
        } else if (indexPath.row == 1) {
            cell.headImageView.image = [UIImage imageNamed:@"Plugins_groupsms_avatar.png"];
            cell.redImageView.image = nil;
            cell.numOfMessageLabel.text = nil;
            cell.nameLabel.text = @"公共帐号";
        }
    } else if (indexPath.section == 1) {
        cell.nameLabel.text = @"腾讯新闻";
        cell.headImageView.image = [UIImage imageNamed:@"plugins_Note.png"];
    } else {
        cell.redImageView.image = nil;
        cell.numOfMessageLabel.text = nil;
        UserInfo *userinfo = [[userFrinedSections objectAtIndex:(indexPath.section - 2)] objectAtIndex:indexPath.row];
        cell.nameLabel.text = userinfo.userName;
        cell.headImageView.image = userinfo.userImage;
       // cell.userSignText.text = userinfo.userStatusLogo;
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidesBottomBarWhenPushed = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0 && indexPath.row == 0) {
        self.tabBarItem.badgeValue = nil;

        NewFriendsTableViewController *newFriendsTVC = [[NewFriendsTableViewController alloc] initWithNibName:@"NewFriendsTableViewController" bundle:nil];
        newFriendsTVC.newfriends =  [[NSMutableArray alloc] initWithArray:newFriends];
        [newFriends removeAllObjects];
        [self.tableView reloadData];
        [self.navigationController pushViewController:newFriendsTVC animated:YES];
        [newFriendsTVC release];
    }

    if (indexPath.section != 0 && indexPath.section !=1) {
        [self.tabBarController setSelectedIndex:0];
        [self.openTalkDelege openTalkView:[[userFrinedSections objectAtIndex:(indexPath.section - 2)] objectAtIndex:indexPath.row]];
//        LookFriendInfoViewController *lookFriendInfoViewController = [[LookFriendInfoViewController alloc] initWithNibName:@"LookFriendInfoViewController" bundle:nil];
//        lookFriendInfoViewController.userFriendInfo = [[userFrinedSections objectAtIndex:(indexPath.section - 2)] objectAtIndex:indexPath.row];
//        [self.navigationController pushViewController:lookFriendInfoViewController animated:YES];
    }
}

#pragma mark - UISwipeGestureRecognizer

- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    
    if(![self.tableView.dataSource tableView:self.tableView canEditRowAtIndexPath:indexPath]) {
        return;
    }
    if (indexPath.section == 0 || indexPath.section == 1) {
        return;
    }
    //左滑
    if(gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(_editingIndexPath) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
}
//获取indexpath根据手势落点save
- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    UIView * view = gestureRecognizer.view;
    if(![view isKindOfClass:[UITableView class]]) {
        return nil;
    }
    
    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    return indexPath;
}

//save
- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell {
    
    if(editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [self.tableView cellForRowAtIndexPath:_editingIndexPath];
            [self setEditing:NO atIndexPath:_editingIndexPath cell:editingCell];
        }
        //获得单击
        [self.tableView addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self.tableView removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    CGRect frame = cell.frame;
    
    CGFloat cellXOffset;
    CGFloat deleteButtonXOffsetOld;
    CGFloat deleteButtonXOffset;
    
    if(editing) {
        cellXOffset = -kDeleteButtonWidth;
        deleteButtonXOffset = screenWidth() - kDeleteButtonWidth;
        deleteButtonXOffsetOld = screenWidth();
        _editingIndexPath = indexPath;
    } else {
        cellXOffset = 0;
        deleteButtonXOffset = screenWidth();
        deleteButtonXOffsetOld = screenWidth() - kDeleteButtonWidth;
        _editingIndexPath = nil;
    }
    
    CGFloat cellHeight = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:indexPath] - 3;
    _deleteButton.frame = (CGRect) {deleteButtonXOffsetOld, frame.origin.y, _deleteButton.frame.size.width, cellHeight};
    _deleteButton.indexPath = indexPath;
    
    [UIView animateWithDuration:0.2f animations:^{
        cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
        _deleteButton.frame = (CGRect) {deleteButtonXOffset, frame.origin.y, _deleteButton.frame.size.width, cellHeight};
    }];
}

#pragma mark - delete Friend
- (void)deleteItem:(id)sender {
    UIButton * deleteButton = (UIButton *)sender;
    NSIndexPath * indexPath = deleteButton.indexPath;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-2)];
    NSString *TALKUserID = [[[userFrinedSections objectAtIndex:newIndexPath.section] objectAtIndex:newIndexPath.row] userID];
    NSAssert([[[userFrinedSections objectAtIndex:newIndexPath.section] objectAtIndex:newIndexPath.row] isKindOfClass:[UserInfo class]], @"it must be UserInfo");
    [self delete:TALKUserID];
    [userFriendInfoArray removeObject:[[userFrinedSections objectAtIndex:newIndexPath.section] objectAtIndex:newIndexPath.row]];
       
    _editingIndexPath = nil;
    [self.tableView removeGestureRecognizer:_tapGestureRecognizer];

    CGRect frame = _deleteButton.frame;
    CGRect frame1 = [self.tableView cellForRowAtIndexPath:indexPath].frame;
    _deleteButton.frame = (CGRect){frame.origin, frame.size.width, 0};
    [self.tableView cellForRowAtIndexPath:indexPath].frame = (CGRect){frame1.origin, frame1.size.width, 0};
    
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
        CGRect frame = _deleteButton.frame;
        CGRect frame1 = [self.tableView cellForRowAtIndexPath:indexPath].frame;
        _deleteButton.frame = (CGRect){screenWidth(), frame.origin.y, frame.size.width, kDeleteButtonHeight};
        [self.tableView cellForRowAtIndexPath:indexPath].frame = (CGRect){screenWidth(),frame1.origin.y,frame1.size.width,50};

    } completion:^(BOOL finished) {
        [self test];
    }];
}
//客户端 传送 {“action”:”C-S-DELETE-FRIEND”,”userID”:”你自己的登陆的ID” ,”TALKUserID”:”对方的ID”}
-(void)delete:(NSString *)TALKUserID
{
    UserInfo *myInfo = [MainViewController sharedMainViewController].loginUser;
    NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
    [dicC setObject:@"C-S-DELETE-FRIEND" forKey:@"action"];
    [dicC setObject:myInfo.userID forKey:@"userID"];
    [dicC setObject:TALKUserID forKey:@"TALKUserID"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicC options:NSJSONWritingPrettyPrinted error:nil];
    
    [[ChatSocket shareChatSocket].asynSocket writeData:data withTimeout:-1 tag:0];
  
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO; // Recognizers of this class are the first priority
}

- (void)dealloc {
    [sectionArrays release];
    [newFriendArray release];
    [newFriends release];
    [publicUser release];
    [starFriendArray release];
    [userFriendInfoArray release];
    [addressSearchBar release];
    self.openTalkDelege = nil;
    [super dealloc];
}
@end
