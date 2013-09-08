//
//  MiniTalkViewController.h
//  MiniChat
//
//  Created by aatc on 8/27/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceToolBar.h"

@class UserInfo;
@class UserMsg;

@interface MiniTalkViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, FaceToolBarDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
//    IBOutlet UITextField *talkTextField;
//    IBOutlet UIButton *textButton;
//    IBOutlet UIButton *vedioButton;
//    IBOutlet UIButton *sendVoiceButton;
    UIButton *faceButton ;
    IBOutlet UITableView *chatTableView;
    FaceToolBar *faceToolBar;
    int offY;
    BOOL keyboardIsShow;//键盘是否显示
    BOOL facePageIsShow;//表情视图是否显示
}
@property (nonatomic, retain) UserInfo *myUserInfo;
@property (nonatomic, retain) UserInfo *friendUserInfo;
@property (nonatomic, retain) NSMutableArray *friendUserMsgArray;

@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;

@property (nonatomic, retain) NSDate                 *lastTime;
@property (nonatomic, retain) IBOutlet UITableView *chatTableView;

- (IBAction)switchTextOrVedio:(id)sender;
- (IBAction)tapBackground:(id)sender;
- (IBAction)sendVoice:(id)sender;

@end
