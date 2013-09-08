//
//  SubRegisteViewController.h
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoveFromParentViewConTroller.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD-Prefix.pch"
@interface SubRegisteViewController : UIViewController <UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MBProgressHUDDelegate>
{
    
    IBOutlet UITextField *userNameTextField;
    IBOutlet UITextField *userAgeTextField;
    IBOutlet UITextField *userSexTextField;
    IBOutlet UITextField *userTypeTextField;
    IBOutlet UITextField *userSignTextField;
    IBOutlet UIImageView *headPortraitImg;
    
    UIView *choseHeadView;//选择系统头像视图
    id<RemoveFromParentViewConTroller> delegate;
    MBProgressHUD *HUD;//成功注册动画
}

@property (retain, nonatomic) id<RemoveFromParentViewConTroller> delegate;

- (IBAction)registeDone:(id)sender;
- (IBAction)tapBackground:(id)sender;
- (IBAction)searchFromSystem:(id)sender;//系统默认头像
- (IBAction)searchFromPhotos:(id)sender;//相册选择
- (IBAction)takePicture:(id)sender;

@end
