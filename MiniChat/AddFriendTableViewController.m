//
//  AddFriendTableViewController.m
//  MiniChat
//
//  Created by aatc on 8/28/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AddFriendTableViewController.h"
#import "ASIFormDataRequest.h"
#import "UserInfo.h"
#import "MainViewController.h"
#import "MyMiniViewCell.h"
#import "FriendInfoViewController.h"
#import "ChatSocket.h"
@interface AddFriendTableViewController ()

@end

@implementation AddFriendTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"添加朋友";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 100)];
    imageView.image = [UIImage imageNamed:@"Video_PlayReturnHL.png"];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [imageView release];
    [barItem setBackButtonBackgroundImage:[UIImage imageNamed:@"Video_PlayReturnHL.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    barItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barItem;
    [barItem release];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    sectionArrays = [[NSMutableArray alloc] initWithCapacity:1];
    onlineUserInfoSection = [[NSMutableArray alloc] initWithCapacity:0];
    [self getFriendOnlineListFromServer];
    [sectionArrays addObject:onlineUserInfoSection];
    imageUrlQueue = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getFriendOnlineListFromServer) name:NSNC_S_UPDATE_ONLINE_LIST object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getFriendOfflineListFromServer:) name:NSNC_S_UPDATE_OFFLINE_LIST object:nil];
}
-(void)getFriendOfflineListFromServer:(NSNotification *)notification
{
    NSDictionary *dic = notification.object;
    for (int i = 0; i < onlineUserInfoSection.count; i++) {
        UserInfo *userFriend = [onlineUserInfoSection objectAtIndex:i];
        if ([userFriend.userID isEqualToString:[dic objectForKey:@"userID"]]) {
            [onlineUserInfoSection removeObject:userFriend];
            [self.tableView reloadData];
            return;
        }
    }
}
-(void) getFriendOnlineListFromServer
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/login.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //上传数据
    NSMutableDictionary *dicByClient = [NSMutableDictionary dictionary];
    //注册动作
    [dicByClient setObject:@"getOnLineUsers" forKey:@"action"];
    //用户帐号
    [dicByClient setObject:[MainViewController sharedMainViewController].loginUser.userID forKey:@"userID"];
    
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
                    for (UserInfo *userInfo in onlineUserInfoSection) {
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

                        [onlineUserInfoSection addObject:onlineInfo];
                        [imageUrlQueue addObject:onlineInfo];
                        [onlineInfo release];
                    }
                }
                [self.tableView reloadData];
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
    
   // for (int i = 0; i < imageUrlQueue.count; i++) {
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
    }
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",MINI_CHAT_HTTP_SERVER, u.userImageUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        [request setFailedBlock:^{
            NSLog(@"%@", @"failed");
        }];
        
        [request setCompletionBlock:^{
            UIImage *image = [UIImage imageWithData:request.responseData];
            u.userImage = image;
            //保存图片
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[sectionArrays objectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
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
    UserInfo *userInfoAtCell = nil;

    userInfoAtCell = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.userName.text = userInfoAtCell.userName;
    //cell的好友发送消息内容
    cell.userMsg.text = userInfoAtCell.userName;
    //cell的好友时间
    cell.userTime.text = userInfoAtCell.userStatusTime;
    //未获取图像时设置默认头像
    if (userInfoAtCell.userImage == nil) {
        cell.userHeadImage.image = [UIImage imageNamed:@"image1.png"];
    } else {
        cell.userHeadImage.image = userInfoAtCell.userImage;
    }
    
    cell.userHeadImage.layer.cornerRadius= 5;
    
    cell.userHeadImage.layer.masksToBounds= YES;
    //边框宽度及颜色设置
    [cell.userHeadImage.layer setBorderWidth:1];
    //自动适应,保持图片宽高比
    cell.userHeadImage.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
    FriendInfoViewController *friendInfoViewController = [[FriendInfoViewController alloc] initWithNibName:@"FriendInfoViewController" bundle:nil];
    friendInfoViewController.friendUserInfo = [onlineUserInfoSection objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:friendInfoViewController animated:YES];
    [friendInfoViewController release];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)dealloc
{
    [sectionArrays release];
    sectionArrays = nil;
    [section1 release];
    section1 = nil;
    [onlineUserInfoSection release];
    onlineUserInfoSection = nil;
    [imageUrlQueue release];
    imageUrlQueue = nil;
    [super dealloc];
}

@end
