//
//  RegisteViewController.h
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoveFromParentViewConTroller.h"
#import "SetValuesByOther.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD-Prefix.pch"

@interface RegisteViewController : UIViewController <RemoveFromParentViewConTroller, MBProgressHUDDelegate>
{
    IBOutlet UITextField *userIDTextField;
    IBOutlet UITextField *userPwdTextField;
    
    MBProgressHUD *HUD;//成功注册动画
}

@property (nonatomic, retain) id<SetValuesByOther>delegate;

- (IBAction)netxStepRegiste:(id)sender;
- (IBAction)tapBackground:(id)sender;

@end
