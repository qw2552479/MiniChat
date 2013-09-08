//
//  FriendsTableViewController.m
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "FriendsTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

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
    self.tableView.bounces = NO;
    self.navigationItem.title = @"朋友们";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    section1 = [[NSMutableArray alloc] initWithCapacity:1];
    section2 = [[NSMutableArray alloc] initWithCapacity:2];
    section3 = [[NSMutableArray alloc] initWithCapacity:2];
    section4 = [[NSMutableArray alloc] initWithCapacity:1];
    
    [section1 addObject:@"朋友圈"];
  
    [section2 addObject:@"扫一扫"];
    [section2 addObject:@"摇一摇"];
 
    [section3 addObject:@"附近的人"];
    [section3 addObject:@"漂流瓶"];
    
    [section4 addObject:@"游戏中心"];
    
    sectionArrays = [[NSMutableArray alloc] initWithObjects:section1, section2, section3, section4, nil];
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
    [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:15]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"ff_IconShowAlbum.png"];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:@"ff_IconQRCode.png"];
                    break;
                case 1:
                    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:@"ff_IconShake.png"];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:@"ff_IconLocationService.png"];
                    break;
                case 1:
                    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:@"ff_IconBottle.png"];
                    break;
                default:
                    break;
            }
            break;
        case 3:
            cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"MoreGame.png"];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)dealloc {
    [super dealloc];
}
@end
