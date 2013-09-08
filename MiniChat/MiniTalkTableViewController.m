//
//  MiniTalkTableViewController.m
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MiniTalkTableViewController.h"
#import "ASIFormDataRequest.h"
#import "UserInfo.h"
#import "MainViewController.h"
#import "MyMiniViewCell.h"
#import <objc/runtime.h>
#import "MiniTalkViewController.h"
#import "LookFriendInfoViewController.h"
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
@interface MiniTalkTableViewController ()
{
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    
    UIButton * _deleteButton;
    
    NSIndexPath * _editingIndexPath;
}
@end

@implementation MiniTalkTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - view Will appear or disappear
-(void)viewWillAppear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
#pragma mark - gestureRecognizer 
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
    
    //tableview的设置
    self.tableView.bounces = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    //set tableview style and layout
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mm_title_btn_compose_normal.png"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 100)];
    imageView.image = [UIImage imageNamed:@"Video_PlayReturnHL.png"];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [imageView release];
    [barItem setBackButtonBackgroundImage:[UIImage imageNamed:@"Video_PlayReturnHL.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    barItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barItem;
    [barItem release];
#pragma mark - datasorce 
    // [self.navigationController.navigationBar setTitleTextAttributes:dictText];
    sectionArrays = [[NSMutableArray alloc] initWithCapacity:1];
    //请求验证好友消息数组
    messageFromFriend = [[NSMutableArray alloc] initWithCapacity:1];//存放字典，字典存放一个{userInfo:"userInfo"}存放一个消息数组{msgArray:"{array1,array2}"}
    [sectionArrays insertObject:messageFromFriend atIndex:0];
    [self setNavigationItemTitle];
    
    //socket断开连接
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(mySocketDidDisconnect:) name:NSNC_SocketDidDisconnect object:nil];
    //socket连接
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(mySocketDidConnectToHost:) name:NSNC_SocketDidConnectToHost object:nil];
    //收到好友消息
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getMessageFromFriend:) name:NSNC_C_S_ASK_TALKING object:nil];
}

//将消息存在userMsgDic数组中，然后将这个数组存在messageFromFriend数组中
//每次存消息，先比对messageFromFriend数组中有无对应msgFromUserID。有则插入到相应的userMsgArray中，
//无则新建字典,插入到messageFromFriend数组中
-(void)getMessageFromFriend:(NSNotification *)notification
{   
    NSDictionary *dicS = notification.object;
    NSAssert([notification.object isKindOfClass:[NSDictionary class]], @"(NSDictionary *)notification must be a diciionart");
    NSString *msgText;
    NSString *mstType;
    NSDictionary *msgFromS;
    if ([[dicS objectForKey:@"msg"] isKindOfClass:[NSDictionary class]]) {
        msgFromS = [dicS objectForKey:@"msg"];//消息字典
        mstType = [msgFromS objectForKey:@"msgType"];//消息类型
        msgText = [msgFromS objectForKey:@"msgText"];//消息文本内容
    } else {
        return;
    }
    NSString *TALKUserID = [dicS objectForKey:@"TALKUserID"];//好友
    NSString *msgTime = [dicS objectForKey:@"msgTime"];//发送时间
    NSString *userID = [dicS objectForKey:@"userID"];//自己ID
    //确认是否相同好友的信息
    for (NSMutableDictionary *userMsgDic in messageFromFriend) {
        if ([[[userMsgDic objectForKey:@"userInfo"] userID] isEqualToString:TALKUserID]) {
            UserMsg *userMsg = [[UserMsg alloc] init];
            [userMsg setIsRead:NO];
            [userMsg setMsgFromUserID:TALKUserID];
            [userMsg setMsgTime:msgTime];
            [userMsg setMsgID:TALKUserID];
            [userMsg setMsgToUserID:userID];
            [userMsg setMsgType:mstType];
            
            if ([mstType isEqualToString:@"IMAGE"]) {
                [userMsg setMsgMediaUrlFile:[msgFromS objectForKey:@"Mediafile"]];
            } else if ([mstType isEqualToString:@"TEXT"]) {
                [userMsg setMsgText:msgText];
            } else if ([mstType isEqualToString:@"AUDIO"]) {
                [userMsg setMsgMediaUrlFile:[msgFromS objectForKey:@"Mediafile"]];
            }
            [[userMsgDic objectForKey:@"msgArray"] addObject:userMsg];
            [userMsg release];
            [self setNavigationItemTitle];
            [self.tableView reloadData];
            return;
        }
    }
    UserMsg *userMsg = [[UserMsg alloc] init];
    [userMsg setIsRead:NO];
    [userMsg setMsgFromUserID:TALKUserID];
    [userMsg setMsgTime:msgTime];
    [userMsg setMsgID:TALKUserID];
    [userMsg setMsgToUserID:userID];
    [userMsg setMsgType:mstType];
    
    if ([mstType isEqualToString:@"IMAGE"]) {
        [userMsg setMsgMediaUrlFile:[msgFromS objectForKey:@"Mediafile"]];
    } else if ([mstType isEqualToString:@"TEXT"]) {
        [userMsg setMsgText:msgText];
    } else if ([mstType isEqualToString:@"AUDIO"]) {
        [userMsg setMsgMediaUrlFile:[msgFromS objectForKey:@"Mediafile"]];
    }
    //用来存放消息的数组
    NSMutableDictionary *userMsgDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *msgArray = [NSMutableArray array];
    [msgArray addObject:userMsg];
    [userMsgDic setObject:msgArray forKey:@"msgArray"];
    [userMsg release];
    
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.userID = TALKUserID;
    [userMsgDic setObject:userInfo forKey:@"userInfo"];
    [userInfo release];
    
    [self downLoadUserInfo:userInfo];
    [messageFromFriend addObject:userMsgDic];
    [self.tableView reloadData];
    [self setNavigationItemTitle];
 
}
- (void)downLoadUserInfo:(UserInfo *)userInfo
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/setting.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //要上传的数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"getUserProfile" forKey:@"action"];
    [dic setObject:userInfo.userID forKey:@"userID"];
    
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
            [userInfo setUserID:[userDic objectForKey:@"userID"]];
            [userInfo setUserName:[userDic objectForKey:@"userName"]];
            [userInfo setUserSign:[userDic objectForKey:@"userSign"]];
            [userInfo setUserSex:[userDic objectForKey:@"userSex"]];
            [userInfo setUserType:[userDic objectForKey:@"userType"]];
            [userInfo setUserAge:[userDic objectForKey:@"userAge"]];
            [userInfo setUserImageUrl:[userDic objectForKey:@"userImageUrl"]];
            [self downLoadUserImage:userInfo];
        }
    }];
    [request startAsynchronous];
}

//下载个人头像
- (void)downLoadUserImage:(UserInfo *)userInfo
{
    NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    NSString *imageFilePath = [docPath stringByAppendingString:userInfo.userImageUrl];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        userInfo.userImage = [UIImage imageWithContentsOfFile:imageFilePath];
        [self setNavigationItemTitle];
        [self.tableView reloadData];
        return;
    }
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",MINI_CHAT_HTTP_SERVER, userInfo.userImageUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    [request setFailedBlock:^{
        NSLog(@"%@", @"failed");
    }];
    
    [request setCompletionBlock:^{
        UIImage *image = [UIImage imageWithData:request.responseData];
        userInfo.userImage = image;
        NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
        NSString *imageDir = [docPath stringByAppendingString:@"images"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        //imageurl样式 images／image343243er.png
        NSString *imageFilePath = [docPath stringByAppendingString:userInfo.userImageUrl];
        [request.responseData writeToFile:imageFilePath atomically:YES];
        [self setNavigationItemTitle];
        [self.tableView reloadData];
    }];
    [request startAsynchronous];
}
//改变navigationitem的title
-(void) setNavigationItemTitle
{
    if (messageFromFriend.count == 0) {
        self.navigationItem.title = @"微信";
    } else {
        if (messageFromFriend.count > 0) {
            int num = 0;
            for (NSMutableDictionary *msgDic in messageFromFriend) {
                //计算未读消息数量
                for (UserMsg *msg in [msgDic objectForKey:@"msgArray"]) {
                    if ([msg isKindOfClass:[UserMsg class]]) {
                        if (!msg.isRead) {
                            num++;
                        }
                    }
                }
            }
            if (num == 0) {
                self.tabBarItem.badgeValue = nil;
                self.navigationItem.title = @"微信";
            } else {
                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", num];
                self.navigationItem.title = [NSString stringWithFormat:@"微信(%d)", num];
            }
        }
    }
}
#pragma mark - Socket
-(void)mySocketDidDisconnect:(NSNotification *)notification
{
    headSectionHeiht = 50.0f;
    [self.tableView reloadData];
}
-(void)mySocketDidConnectToHost:(NSNotification *)notification
{
    headSectionHeiht = 0.0f;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [sectionArrays count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[sectionArrays objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return headSectionHeiht;
    }
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
        UIButton *errorBT = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [errorBT setBackgroundColor:[UIColor colorWithRed:249.0/255 green:173.0/255 blue:129.0/255 alpha:1.0]];
        [errorBT addTarget:self action:@selector(reConnectToHost) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:errorBT];
        [errorBT release];
    
        UIImageView *errorIV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
        errorIV.image = [UIImage imageNamed:@"confirm_dialog_failweb.png"];
        [v insertSubview:errorIV aboveSubview:errorBT];
        [errorIV release];
        
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 240, 20)];
        errorLabel.font = [UIFont systemFontOfSize:15];
      
        errorLabel.textColor = [UIColor blackColor];
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.text = @"网络出现问题,点击尝试断线重连";
        [v insertSubview:errorLabel aboveSubview:errorBT];
        
        [errorLabel release];

        return v;
    }
    return nil;
}
//建立与服务器的连接
- (void)reConnectToHost
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/login.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //要上传的数据
    NSString *userID = [MainViewController sharedMainViewController].loginUser.userID;
    NSString *userPwd = [MainViewController sharedMainViewController].loginUser.userPwd;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"login" forKey:@"action"];
    [dic setObject:userID forKey:@"userID"];
    [dic setObject:userPwd forKey:@"userPwd"];
    NSLog(@"%@,%@", userID, userPwd);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [request setPostValue:postString forKey:@"data"];
    
    [postString release];
    
    [request setFailedBlock:^{
    }];
    
    [request setCompletionBlock:^{
        
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
                ChatSocket *chatSocket = [ChatSocket shareChatSocket];
                [chatSocket connectMiniChatSocketServer];
            }
        }
    }];
    
    [request startAsynchronous];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"MyMiniViewCell";
    
    MyMiniViewCell *cell = (MyMiniViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyMiniViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
//
    UserMsg *userMsgAtCell = nil;
                            //取到messagefromfriend数组                 //取道msgDic                  //msgDic的消息数组
    userMsgAtCell = [[[[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"msgArray"] lastObject];
    UserInfo *userInfo = [[[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"userInfo"];
    int num = 0;
    for (UserMsg *msg in [[[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"msgArray"]) {
        if ([msg isKindOfClass:[UserMsg class]]) {
            if (!msg.isRead) {
                num++;
            }
        }
    }
    if (num == 0) {
        cell.badgeImageView.image = nil;
        cell.badgeValueLabel.text = nil;
    } else {
        cell.badgeImageView.image = [UIImage imageNamed:@"AlbumNewNotify.png"];
        cell.badgeValueLabel.text = [NSString stringWithFormat:@"%d", num];
    }
    cell.userName.text = userInfo.userID;
    //cell的好友发送消息内容
    cell.userMsg.text = userMsgAtCell.msgText;
    //cell的好友时间
    cell.userTime.text = userMsgAtCell.msgTime;
    //未获取图像时设置默认头像
    if (userInfo.userImage == nil) {
        cell.userHeadImage.image = [UIImage imageNamed:@"DefaultHead.png"];
    } else {
        cell.userHeadImage.image = userInfo.userImage;
    }
    cell.userHeadImage.layer.cornerRadius= 5;
    
    cell.userHeadImage.layer.masksToBounds= YES;
    
    
    [cell.userHeadImage.layer setBorderWidth:1];
    //自动适应,保持图片宽高比
    cell.userHeadImage.contentMode = UIViewContentModeScaleAspectFit;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    MiniTalkViewController *miniTalkViewController = [[MiniTalkViewController alloc] initWithNibName:@"MiniTalkViewController" bundle:nil];
    miniTalkViewController.friendUserMsgArray = [[messageFromFriend objectAtIndex:indexPath.row] objectForKey:@"msgArray"];
    miniTalkViewController.friendUserInfo = [[messageFromFriend objectAtIndex:indexPath.row] objectForKey:@"userInfo"];
    for (id msg in [[messageFromFriend objectAtIndex:indexPath.row] objectForKey:@"msgArray"]) {
        if ([msg isKindOfClass:[UserMsg class]]) {
            [msg setIsRead:YES];
        }
    }
    [self setNavigationItemTitle];
    [self.tableView reloadData];
    [self.navigationController pushViewController:miniTalkViewController animated:YES];
    [miniTalkViewController release];
}

#pragma mark - openTalkView代理打开聊天窗口
-(void)openTalkView:(UserInfo *)userInfo
{
    self.hidesBottomBarWhenPushed = YES;
    MiniTalkViewController *miniTalkViewController;
    
    for (NSMutableDictionary *userMsgDic in messageFromFriend) {
        if ([userInfo.userID isEqualToString:[[userMsgDic objectForKey:@"userInfo"] userID]]) {
            for (id msg in [userMsgDic objectForKey:@"msgArray"]) {
                if ([msg isKindOfClass:[UserMsg class]]) {
                    [msg setIsRead:YES];
                }
            }
            
            miniTalkViewController = [[MiniTalkViewController alloc] initWithNibName:@"MiniTalkViewController" bundle:nil];
            miniTalkViewController.friendUserMsgArray = [userMsgDic objectForKey:@"msgArray"];
            miniTalkViewController.friendUserInfo = [userMsgDic objectForKey:@"userInfo"];
            [self.navigationController pushViewController:miniTalkViewController animated:YES];
            [miniTalkViewController release];
            return;
        }  
    }
    
    miniTalkViewController = [[MiniTalkViewController alloc] initWithNibName:@"MiniTalkViewController" bundle:nil];
    miniTalkViewController.friendUserInfo = userInfo;
   
    //用来存放消息的数组
    NSMutableDictionary *userMsgDic = [NSMutableDictionary dictionary];
    [userMsgDic setObject:userInfo forKey:@"userInfo"];
    
    NSMutableArray *msgArray = [NSMutableArray arrayWithCapacity:0];
    [userMsgDic setObject:msgArray forKey:@"msgArray"];
    
    [messageFromFriend addObject:userMsgDic];
    miniTalkViewController.friendUserMsgArray = msgArray;
    [self.navigationController pushViewController:miniTalkViewController animated:YES];
    [miniTalkViewController release];
    [self setNavigationItemTitle];
    [self.tableView reloadData];
}
#pragma mark - UISwipeGestureRecognizer

- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer {
    //通过手势落点获取indexpath
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    
    if(![self.tableView.dataSource tableView:self.tableView canEditRowAtIndexPath:indexPath]) {
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
    //判断偏移量
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
    //cell左滑，deletebutton在cell右端出现
    [UIView animateWithDuration:0.2f animations:^{
        cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
        _deleteButton.frame = (CGRect) {deleteButtonXOffset, frame.origin.y, _deleteButton.frame.size.width, cellHeight};
    }];
}

#pragma mark - Interaciton
- (void)deleteItem:(id)sender {
    UIButton * deleteButton = (UIButton *)sender;
    NSIndexPath * indexPath = deleteButton.indexPath;
    //删除之后移除tap手势
    [[sectionArrays objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    _editingIndexPath = nil;
    [self.tableView removeGestureRecognizer:_tapGestureRecognizer];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = _deleteButton.frame;
        _deleteButton.frame = (CGRect){frame.origin, frame.size.width, 0};
    } completion:^(BOOL finished) {
        CGRect frame = _deleteButton.frame;
        //判断横屏还是竖屏的高度
        _deleteButton.frame = (CGRect){screenWidth(), frame.origin.y, frame.size.width, kDeleteButtonHeight};
        [self setNavigationItemTitle];
        [self.tableView reloadData];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO; // Recognizers of this class are the first priority
}

- (void)dealloc {
    [messageFromFriend release];
    messageFromFriend = nil;
//    [requsetMessageArray release];
//    requsetMessageArray = nil;
    [sectionArrays release];
    sectionArrays = nil;
    [searchResults release];
    searchResults = nil;
    [super dealloc];
}
@end
