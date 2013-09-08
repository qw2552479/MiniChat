//
//  SettingTableViewController.m
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "SettingTableViewController.h"
#import "UserInfoViewController.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import "MyAnimation.h"
#import "ChatSocket.h"
@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //关闭顶部滚动
    self.tableView.bounces = NO;
    self.navigationItem.title = @"设置";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    
    section1 = [[NSMutableArray alloc] initWithCapacity:4];
    section2 = [[NSMutableArray alloc] initWithCapacity:1];
    section3 = [[NSMutableArray alloc] initWithCapacity:1];
    
    [section1 addObject:@"新消息提醒"];
    [section1 addObject:@"隐私"];
    [section1 addObject:@"通用"];
    [section1 addObject:@"流量统计"];
    
    [section2 addObject:@"关于微信"];
    
    [section3 addObject:@"退出"];
    
    sectionArrays = [[NSMutableArray alloc] initWithObjects:section1, section2, section3, nil];
    
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
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        UIView *view_bg = [[[UIView alloc]initWithFrame:cell.frame]autorelease];
        view_bg.backgroundColor = [UIColor colorWithRed:172.0/255 green:211.0/255 blue:115.0/255 alpha:1];
        cell.selectedBackgroundView = view_bg;
    }
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageviewNormal = [[UIImageView alloc] initWithFrame:cell.frame];
        UIImage *buttonImageNormal = [UIImage imageNamed:@"btn_style_zero_normal.9.png"];     
        UIImage *stretchableButtonImageNormal = [buttonImageNormal resizableImageWithCapInsets:insets];
        [imageviewNormal setImage:stretchableButtonImageNormal];
        
        UIImageView *imageviewPressed = [[UIImageView alloc] initWithFrame:cell.frame];
        UIImage *buttonImagePressed = [UIImage imageNamed:@"btn_style_zero_pressed.9.png"];
        UIImage *stretchableButtonImagePressed = [buttonImagePressed resizableImageWithCapInsets:insets];
        [imageviewPressed setImage:stretchableButtonImagePressed];

        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        [cell setBackgroundView:imageviewNormal];
        cell.selectedBackgroundView = imageviewPressed;
        
        [imageviewNormal release];
        [imageviewPressed release];
    } else {
        cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:15]];
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
    if (indexPath.section == 2 && indexPath.row == 0) {
        [[ChatSocket shareChatSocket].asynSocket disconnect];
      //  [[MainViewController sharedMainViewController].loginUser release];
        [MainViewController sharedMainViewController].loginUser = nil;
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];     
    }
}

-(void)dealloc
{
    [sectionArrays release];
    [section1 release];
    [section2 release];
    [section3 release];
    [section4 release];
    [section5 release];
    [section6 release];
    [section7 release];
    
    [super dealloc];
}

@end
