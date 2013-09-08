//
//  MeTableViewController.m
//  MiniChat
//
//  Created by aatc on 8/25/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MeTableViewController.h"
#import "UserInfoViewController.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "SettingTableViewController.h"
@interface MeTableViewController ()

@end

@implementation MeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.bounces = NO;
    self.navigationItem.title = @"我";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 100)];
    imageView.image = [UIImage imageNamed:@"Video_PlayReturnHL.png"];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [imageView release];
    [barItem setBackButtonBackgroundImage:[UIImage imageNamed:@"Video_PlayReturnHL.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    barItem.title = @"返回";
    self.navigationItem.backBarButtonItem = barItem;
    [barItem release];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    section1 = [[NSMutableArray alloc] initWithCapacity:1];
    section2 = [[NSMutableArray alloc] initWithCapacity:2];
    section3 = [[NSMutableArray alloc] initWithCapacity:1];
    section4 = [[NSMutableArray alloc] initWithCapacity:1];
    [section1 addObject:@"未获取用户名"];
    
    [section2 addObject:@"我的相册"];
    [section2 addObject:@"我的收藏"];
    
    [section3 addObject:@"表情商店"];
    
    [section4 addObject:@"设置"];
    
    sectionArrays = [[NSMutableArray alloc] initWithObjects:section1, section2, section3, section4, nil];
    
    myUserInfo = [MainViewController sharedMainViewController].loginUser;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[sectionArrays objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 60.0f;
    }
    
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            UIImageView *headimg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
            [headimg setImage:myUserInfo.userImage];
            headimg.layer.cornerRadius= 5;
            headimg.layer.masksToBounds= YES;
            //边框宽度及颜色设置
            [headimg.layer setBorderWidth:1];
            //自动适应,保持图片宽高比
            headimg.contentMode = UIViewContentModeScaleAspectFit;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(74, 15, 80, 20)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:15];
            label.text = myUserInfo.userName;
            [cell addSubview:label];
            [cell insertSubview:headimg atIndex:2];
            
            label.tag = 100;
            headimg.tag = 99;
            [label release];
            [headimg release];
        }
        UIView *view_bg = [[[UIView alloc]initWithFrame:cell.frame]autorelease];
        view_bg.backgroundColor = [UIColor colorWithRed:172.0/255 green:211.0/255 blue:115.0/255 alpha:1];
        view_bg.contentMode = UIViewContentModeScaleAspectFit;
        cell.selectedBackgroundView = view_bg;
    }
    // Configure the cell...
    [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:15]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIImageView *headimg;
    switch (indexPath.section) {
        case 0:
            headimg = (UIImageView *)[cell viewWithTag:99];
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
            [headimg setImage:myUserInfo.userImage];
            label.text = myUserInfo.userName;
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:@"MoreMyAlbum.png"];
                    break;
                case 1:
                    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:@"MoreMyFavorites.png"];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"MoreExpressionShops.png"];
            break;
        case 3:
            cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"MoreSetting.png"];
            break;
        default:
            break;
    }
    
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
    self.hidesBottomBarWhenPushed = YES;
    UserInfoViewController *userInfoVC;
    SettingTableViewController *settingTableVC;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                userInfoVC = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
                [self.navigationController pushViewController:userInfoVC animated:YES];
                [userInfoVC release];
            }
            break;
        case 1:
            if (indexPath.row == 0) {
                
            }
            if (indexPath.row == 1) {
                
            }
            break;
        case 2:
            if (indexPath.row == 0) {
                
            }
            break;
        case 3:
            if (indexPath.row == 0) {
                settingTableVC = [[SettingTableViewController alloc] initWithNibName:@"SettingTableViewController" bundle:nil];
                [self.navigationController pushViewController:settingTableVC animated:YES];
                [settingTableVC release];
            }
            break;
            
        default:
            break;
    }
}

-(void)dealloc
{
    [sectionArrays release];
    [section1 release];
    [section2 release];
    [section3 release];
    [section4 release];
    [myUserInfo release];
    
    [super dealloc];
}

@end
