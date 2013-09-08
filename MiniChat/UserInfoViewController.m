//
//  UserInfoViewController.m
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MainViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "UserInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatSocket.h"
@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

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
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.bounces = NO;
    //加载信息
    myUserInfo = [MainViewController sharedMainViewController].loginUser;
    section1 = [[NSMutableArray alloc] initWithCapacity:5];
    section2 = [[NSMutableArray alloc] initWithCapacity:3];
    section3 = [[NSMutableArray alloc] initWithCapacity:1];
    
    [section1 addObject:@"头像"];
    [section1 addObject:@"名字"];
    [section1 addObject:@"我的帐号"];
    [section1 addObject:@"二维码名片"];
    [section1 addObject:@"我的银行卡"];
    
    [section2 addObject:@"性别"];
    [section2 addObject:@"类型"];
    [section2 addObject:@"个性签名"];

    [section3 addObject:@"腾讯微博"];
    sectionArrays = [[NSMutableArray alloc] initWithObjects:section1, section2, section3, nil];
    
//     [self.tableView reloadData];
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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 80, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Verdana" size:13];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentRight;
        label.tag = 100;
        label.backgroundColor = [UIColor clearColor];
        [cell addSubview:label];
        [label release];
        if (indexPath.section == 0 && indexPath.row == 0) {       
            UIImageView *headimg = [[UIImageView alloc] initWithFrame:CGRectMake(240, 10, 40, 40)];
            //设置圆角图片
            headimg.layer.cornerRadius= 5;
            headimg.layer.masksToBounds= YES;
            //边框宽度及颜色设置
            [headimg.layer setBorderWidth:1];
            //自动适应,保持图片宽高比
            headimg.contentMode = UIViewContentModeScaleAspectFit;
            headimg.tag = 99;
            [cell addSubview:headimg];
            [headimg release];
        }
        UIView *view_bg = [[[UIView alloc]initWithFrame:cell.frame]autorelease];
        view_bg.backgroundColor = [UIColor colorWithRed:172.0/255 green:211.0/255 blue:115.0/255 alpha:1];
        cell.selectedBackgroundView = view_bg;
    }
    
    // Configure the cell...
    [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:15]];
    cell.textLabel.text = [[sectionArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    NSAssert([(UILabel *)[cell viewWithTag:100] isKindOfClass:[UILabel class]], @"label must be label");
    UIImageView *headimg;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    headimg = (UIImageView *)[cell viewWithTag:99];
                    if (myUserInfo.userImage == nil) {
                        [headimg setImage:[UIImage imageNamed:@"image1.png"]];
                    } else {
                        [headimg setImage:myUserInfo.userImage];
                    }      ;
                    break;
                case 1:
                    label.text = myUserInfo.userName;
                    break;
                case 2:
                    label.text = myUserInfo.userID;
                    break;
                default:
                    break;
            }
            
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    label.text = myUserInfo.userSex;
                    break;
                case 1:
                    label.text = myUserInfo.userType;
                    break;
                case 2:
                    label.text = myUserInfo.userSign;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            
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

-(void)showMyActionSheetAnimation
{
    ActionSheetView *asvc = [[ActionSheetView alloc] init];
    asvc.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:asvc];
    self.tableView.scrollEnabled = NO;
    asvc.delegate = self;
    UIImageView *blackView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [asvc insertSubview:blackView atIndex:0];
    [blackView release];
    
    blackView.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        blackView.alpha = 0.2;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            blackView.alpha = 0.6;
        }];
    }];
}

-(void)pickPhotoForMe
{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    
    [self presentViewController:pickerImage animated:YES completion:nil];
    [pickerImage release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self showMyActionSheetAnimation];
                    break;
                case 1:
                    
                    break;
                case 2:
                    
                    break;
                case 3:
                    
                    break;
                case 4:
                    
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    
                    break;
                case 1:
                    
                    break;
                case 2:
                    
                    break;
                default:
                    break;
            }
            break;
        case 2:

            break;
        default:
            break;
    }
}

-(void) updateUserInfo
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/setting.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    UIImage *uploadImage = [MainViewController sharedMainViewController].loginUser.userImage;
    //上传图片
    NSData *imageData = UIImagePNGRepresentation(uploadImage);
    [request setData:imageData withFileName:@"temp.png" andContentType:@"image/png" forKey:@"uploadImage"];
    //上传数据
    NSMutableDictionary *userUpdateInfoDic = [NSMutableDictionary dictionary];
    
    [userUpdateInfoDic setObject:@"updateUser" forKey:@"action"];
    [userUpdateInfoDic setObject:myUserInfo.userID forKey:@"userID"];
    [userUpdateInfoDic setObject:myUserInfo.userName forKey:@"userName"];
    [userUpdateInfoDic setObject:myUserInfo.userAge forKey:@"userAge"];
    [userUpdateInfoDic setObject:myUserInfo.userSex forKey:@"userSex"];
    [userUpdateInfoDic setObject:myUserInfo.userType forKey:@"userType"];
    [userUpdateInfoDic setObject:myUserInfo.userSign forKey:@"userSign"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:userUpdateInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];    
    [request setPostValue:postString forKey:@"data"];
    [postString release];
    [request setCompletionBlock:^{
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
                [self.tableView reloadData];
            } else {
                NSLog(@"registe failed");
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"set post string failed");
    }];
    [request startAsynchronous];

}

#pragma mark - photosdelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    [myUserInfo setUserImage:aImage];
    [self updateUserInfo];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

-(void)dealloc
{
    [sectionArrays release];
    [section1 release];
    [section2 release];
    [section3 release];
    
    [super dealloc];
}
@end
