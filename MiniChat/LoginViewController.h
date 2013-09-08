//
//  LoginViewController.h
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSocket.h"
#import "SetValuesByOther.h"
#import "MBProgressHUD-Prefix.pch"
#import "MBProgressHUD.h"
#import "Utils.h"
typedef enum {
    
    L_DEFAULT = 0,
    L_PASSWROD_ERROR = 1,
    L_USERID_ERROR = 2,
    L_USERID_NULL = 3,
    L_PASSWROD_NULL = 4,
    L_USERID_PASSWROD_NULL = 5,
    L_USERID_PASSWROD_ERROR = 6,
    L_DOUBLEPASSWORD_NOTSAME = 7,
    L_SERVER_ERROR = 8
    
} LoginStatus;


@interface LoginViewController : UIViewController <ClientConnectServerSuccess, SetValuesByOther, MBProgressHUDDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *userIDTextField;
    IBOutlet UITextField *userPwdTextField;
    IBOutlet UILabel *userIDLabel;
    IBOutlet UILabel *userPwdLabel;
    IBOutlet UIImageView *userPwdImageView;
    IBOutlet UIButton *loginButton;
    MBProgressHUD *HUD;//等待动画
    
    LoginStatus loginStatus;//登录验证状态
}
- (IBAction)login:(id)sender;
- (IBAction)tapBackground:(id)sender;
- (IBAction)registe:(id)sender;
- (IBAction)forgetPwd:(id)sender;

@end
