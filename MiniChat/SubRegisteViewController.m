//
//  SubRegisteViewController.m
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "SubRegisteViewController.h"
#import "ASIFormDataRequest.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import <unistd.h>
#import "ChatSocket.h"
@interface SubRegisteViewController ()

@end

@implementation SubRegisteViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"详细信息";
    userNameTextField.delegate = self;
    userAgeTextField.delegate = self;
    userSexTextField.delegate = self;
    userTypeTextField.delegate = self;
    userSignTextField.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    headPortraitImg.image = [UIImage imageNamed:@"image1.png"];
  //  self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
}
//委托实现方法全部在此
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registeDone:(id)sender
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/setting.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    UIImage *uploadImage = headPortraitImg.image;
    //上传图片
    NSData *imageData = UIImagePNGRepresentation(uploadImage);
    [request setData:imageData withFileName:@"temp.png" andContentType:@"image/png" forKey:@"uploadImage"];
    
    //上传数据
    NSMutableDictionary *userRegisteInfoDic = [NSMutableDictionary dictionary];
    NSString *userID = [NSString stringWithString:[MainViewController sharedMainViewController].loginUser.userID];
    NSLog(@"[MainViewController sharedMainViewController].loginUser.userID :%@", [MainViewController sharedMainViewController].loginUser.userID);
    NSString *userName = [NSString stringWithString:userNameTextField.text];
    NSString *userAge = [NSString stringWithString:userAgeTextField.text];
    NSString *userSex = [NSString stringWithString:userSexTextField.text];
    NSString *userType = [NSString stringWithString:userTypeTextField.text];
    NSString *userSign = [NSString stringWithString:userSignTextField.text];
    
    [userRegisteInfoDic setObject:@"updateUser" forKey:@"action"];
    [userRegisteInfoDic setObject:userID forKey:@"userID"];
    [userRegisteInfoDic setObject:userName forKey:@"userName"];
    [userRegisteInfoDic setObject:userAge forKey:@"userAge"];
    [userRegisteInfoDic setObject:userSex forKey:@"userSex"];
    [userRegisteInfoDic setObject:userType forKey:@"userType"];
    [userRegisteInfoDic setObject:userSign forKey:@"userSign"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:userRegisteInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setPostValue:postString forKey:@"data"];
    
    [postString release];
    
    
    [request setCompletionBlock:^{
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
                UIImageView *registeSuccessView = [[UIImageView alloc] initWithFrame:self.view.frame];
                //引用库，界面等待动画效果
                HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view]; 
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                
                // Set custom view mode
                HUD.mode = MBProgressHUDModeCustomView;
                
                HUD.delegate = self;
                HUD.labelText = @"注册成功..";
                
                [HUD show:YES];
                [HUD hide:YES afterDelay:1.4f];
                
                [registeSuccessView setBackgroundColor:[UIColor blackColor]];
                [self.view addSubview:registeSuccessView];
                [self.view insertSubview:HUD aboveSubview:registeSuccessView];
                registeSuccessView.alpha = 0.1f;
                [UIView animateWithDuration:1.5f animations:^{
                    registeSuccessView.alpha = 0.50f;
                } completion:^(BOOL finished) {
                    [registeSuccessView removeFromSuperview];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self.delegate removeFromParentViewConTroller];
                }];

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



- (IBAction)searchFromSystem:(id)sender
{
//    CGRectMake(60, 140, 190, 120)
    CGSize frameSize = self.view.frame.size;
    int offY = (frameSize.height - (40 * 2)) / 2;
    int offX = (frameSize.width - (40 * 4)) / 2;
    
    choseHeadView = [[UIView alloc] initWithFrame:self.view.frame];
    [choseHeadView setBackgroundColor:[UIColor clearColor]];
    UIImageView *choseBgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [choseHeadView insertSubview:choseBgImageView belowSubview:choseHeadView];
    [choseBgImageView setBackgroundColor:[UIColor blackColor]];

    choseBgImageView.alpha = 0.7;
    [choseBgImageView release];
    
    UIImageView *chooseviewbg = [[UIImageView alloc] initWithFrame:self.view.frame];
    chooseviewbg.frame = CGRectMake(offX - 12, offY - 46, 184, 117);
    [choseHeadView insertSubview:chooseviewbg aboveSubview:choseBgImageView];
    [chooseviewbg setImage:[UIImage imageNamed:@"chooseviewbg.png"]];
    [chooseviewbg release];
   
    for (int i = 0; i < 8; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((i % 4) * 40 + offX, (i<=3?0:1) * 40 + offY - 20, 40, 40)];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.png", i+1]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(setSystemImage:) forControlEvents:UIControlEventTouchUpInside];
        [choseHeadView addSubview:button];
        [button release];
    }
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offX + 40 * 4 - 2, offY - 50, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelChooseImage) forControlEvents:UIControlEventTouchUpInside];
    [choseHeadView addSubview:button];
    [button release];
    choseHeadView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        choseHeadView.alpha = 1;
    }];
   
    [self.view addSubview:choseHeadView];
}

-(void)cancelChooseImage
{
    [choseHeadView removeFromSuperview];
}

- (void)setSystemImage:(id)sender
{
    UIButton *button = (UIButton *)sender;
    headPortraitImg.image = button.currentBackgroundImage;
    [choseHeadView removeFromSuperview];
}

- (IBAction)searchFromPhotos:(id)sender
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    headPortraitImg.image = aImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)takePicture:(id)sender
{
//    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
//    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//    //    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
//    //        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    //    }
//    //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
//    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
//    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
//    picker.delegate = self;
//    picker.allowsEditing = YES;//设置可编辑
//    picker.sourceType = sourceType;
//    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
//    [picker release];
    NSLog(@"take picture");
}

- (IBAction)tapBackground:(id)sender
{
    [userNameTextField resignFirstResponder];
    [userAgeTextField resignFirstResponder];
    [userSexTextField resignFirstResponder];
    [userTypeTextField resignFirstResponder];
    [userSignTextField resignFirstResponder];
}
- (void)dealloc {
    
    self.delegate = nil;
    [userNameTextField release];
    [userAgeTextField release];
    [userSexTextField release];
    [userTypeTextField release];
    [userSignTextField release];
    [headPortraitImg release];
    
    [super dealloc];
}

@end
