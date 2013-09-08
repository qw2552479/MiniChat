//
//  MiniTalkViewController.m
//  MiniChat
//
//  Created by aatc on 8/27/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MiniTalkViewController.h"
#import "UserInfo.h"
#import "MainViewController.h"
#import "ASIFormDataRequest.h"
#import "ChatSocket.h"
#import "ChatCustomCell.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300


#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

@interface MiniTalkViewController ()

@end

@implementation MiniTalkViewController
@synthesize chatTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

-(void)keyboardWillShow:(NSNotification *)notification
{
 
 //   keyboardIsShow = YES;
    NSDictionary *info = [notification userInfo];
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyBoardFrameEndUser = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect rect ;
    [keyBoardFrameEndUser getValue:&rect];
    CGRect kerBoardRect = rect;
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    NSTimeInterval animation = animationDuration;

    int height = [[UIScreen mainScreen] bounds].origin.y - self.view.frame.origin.y;
    offY = kerBoardRect.size.height - height;
    
    [UIView animateWithDuration:animation delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
        tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, (float)(480.0 - kerBoardRect.size.height - 99));
    } completion:^(BOOL finished) {

    }];
    [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                         atScrollPosition: UITableViewScrollPositionBottom
                                 animated:NO];
}
-(void)keyboardShow:(NSNotification *)notification
{

}
-(void)keyboardWillHide:(NSNotification *)notification
{
  //  keyboardIsShow = NO;
    NSDictionary *info = [notification userInfo];
    
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    NSTimeInterval animation = animationDuration;
    
    [UIView animateWithDuration:animation delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
        tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480 - 99);
    } completion:^(BOOL finished) {
    }];
    [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                         atScrollPosition: UITableViewScrollPositionBottom
                                 animated:NO];
}
-(void)keyboardHide:(NSNotification *)notification
{
    
}
-(void)sendTextAction:(NSString *)inputText
{
    NSLog(@"sendTextAction%@",inputText);
    UserInfo *myInfo = [MainViewController sharedMainViewController].loginUser;
    
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:@"TEXT" forKey:@"msgType"];
    [msgDic setObject:@"text" forKey:@"Mediafile"];
    [msgDic setObject:inputText forKey:@"msgText"];
    
    NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
    
    [dicC setObject:@"C-S-ASK-TALKING" forKey:@"action"];
    [dicC setObject:myInfo.userID forKey:@"userID"];
    [dicC setObject:self.friendUserInfo.userID forKey:@"TALKUserID"];
    [dicC setObject:msgDic forKey:@"msg"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicC options:NSJSONWritingPrettyPrinted error:nil];
    
    [[ChatSocket shareChatSocket].asynSocket writeData:data withTimeout:-1 tag:0];
    
    UserMsg *userMsg = [[UserMsg alloc] init];
    [userMsg setIsRead:YES];
    [userMsg setMsgFromUserID:self.myUserInfo.userID];
    [userMsg setMsgType:@"TEXT"];
    [userMsg setMsgText:inputText];
    // [userMsg setMsgTime:msgTime];
    [userMsg setMsgID:self.myUserInfo.userID];
    [userMsg setMsgToUserID:self.friendUserInfo.userID];
    [self.friendUserMsgArray addObject:userMsg];
    [userMsg release];
    [self addMessageToChatArray];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/setting.php", MINI_CHAT_HTTP_SERVER];
    NSURL *url = [NSURL URLWithString:strUrl];
    //链接url
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    UIImage *uploadImage = aImage;
    //上传图片
    NSData *imageData = UIImagePNGRepresentation(uploadImage);
    [request setData:imageData withFileName:@"temp.png" andContentType:@"application/octet-stream" forKey:@"uploadFile"];
    //上传数据
    NSMutableDictionary *userRegisteInfoDic = [NSMutableDictionary dictionary];
    //    NSString *userID = [NSString stringWithString:[MainViewController sharedMainViewController].loginUser.userID];
    [userRegisteInfoDic setObject:@"uploadFile" forKey:@"action"];
    //action ＝ uploadFile
    NSData *data = [NSJSONSerialization dataWithJSONObject:userRegisteInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setPostValue:postString forKey:@"data"];
    
    [postString release];
    
    [request setCompletionBlock:^{
        NSLog(@"request.responseString = %@", request.responseString);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic objectForKey:@"statusID"] isEqualToString:@"0"]) {
                UserInfo *myInfo = [MainViewController sharedMainViewController].loginUser;
                
                NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
                [msgDic setObject:@"IMAGE" forKey:@"msgType"];
                [msgDic setObject:[NSString stringWithFormat:@"%@/%@", MINI_CHAT_HTTP_SERVER, [dic objectForKey:@"fileUrl"]] forKey:@"Mediafile"];
                [msgDic setObject:@"" forKey:@"msgText"];
                
                NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
                
                [dicC setObject:@"C-S-ASK-TALKING" forKey:@"action"];
                [dicC setObject:myInfo.userID forKey:@"userID"];
                [dicC setObject:self.friendUserInfo.userID forKey:@"TALKUserID"];
                [dicC setObject:msgDic forKey:@"msg"];
                NSData *data = [NSJSONSerialization dataWithJSONObject:dicC options:NSJSONWritingPrettyPrinted error:nil];
                
                [[ChatSocket shareChatSocket].asynSocket writeData:data withTimeout:-1 tag:0];
                UserMsg *userMsg = [[UserMsg alloc] init];
                [userMsg setIsRead:YES];
                [userMsg setMsgFromUserID:self.myUserInfo.userID];
                [userMsg setMsgType:@"IMAGE"];
                [userMsg setMsgID:self.myUserInfo.userID];
                [userMsg setMsgToUserID:self.friendUserInfo.userID];
                [userMsg setMsgMediaUrlFile:[[dic objectForKey:@"fileUrl"] substringWithRange:NSMakeRange(7, [[dic objectForKey:@"fileUrl"] length]-7)]];
                
                NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
                NSString *imageDir = [docPath stringByAppendingString:@"images/"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:NO attributes:nil error:nil];
                }
                //imageurl样式 images／image343243er.png
                NSString *imageFilePath = [imageDir stringByAppendingString:userMsg.msgMediaUrlFile];
                [imageData writeToFile:imageFilePath atomically:YES];
                
                [self.friendUserMsgArray addObject:userMsg];
                [userMsg release];
                [self addMessageToChatArray];
            } else {
                NSLog(@"registe failed");
            }
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"set post string failed");
    }];
    
    [request startAsynchronous];

    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)sendImage
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

#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
  //  talkTextField.delegate = self;
    keyboardIsShow = NO;
    facePageIsShow = NO;
    self.navigationItem.title = self.friendUserInfo.userName;
   
    self.myUserInfo = [MainViewController sharedMainViewController].loginUser;

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.chatArray = tempArray;
	[tempArray release];
	
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
    [tempStr release];
    
	NSDate   *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
	[tempDate release];
    
    [self addMessageToChatArray];
    //faceToolBar
    faceToolBar = [[FaceToolBar alloc]initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - toolBarHeight , self.view.frame.size.width, toolBarHeight) superView:self.view];
    faceToolBar.delegate = self;
    
    //表情按钮
    faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [faceButton setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotion.png"] forState:UIControlStateNormal];
    [faceButton setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotionHL.png"] forState:UIControlStateHighlighted];
    [faceButton addTarget:self action:@selector(disFaceKeyboard) forControlEvents:UIControlEventTouchUpInside];
    faceButton.frame = CGRectMake(faceToolBar.bounds.size.width - 70.0f, faceToolBar.bounds.size.height-38.0f, buttonWh, buttonWh);
    [faceToolBar.toolBar addSubview:faceButton];
    
    [self.view addSubview:faceToolBar];
    [faceToolBar release];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getMessageFromFriend:) name:NSNC_C_S_ASK_TALKING object:nil];
}
-(void)disFaceKeyboard{

    //如果键盘没有显示，点击表情了，隐藏表情，显示键盘
    if (facePageIsShow) {
        facePageIsShow = NO;
        [UIView animateWithDuration:Time animations:^{
            UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
            tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480 - toolBarHeight);
            [faceToolBar.scrollView setFrame:CGRectMake(0, 480, self.view.frame.size.width, keyboardHeight)];
        }];
        [UIView animateWithDuration:0.25 animations:^{
                faceToolBar.toolBar.frame = CGRectMake(0, 480 - faceToolBar.toolBar.frame.size.height - navigateBarHeight - 20,  self.view.bounds.size.width, toolBarHeight);
        }];
        [faceToolBar.textView resignFirstResponder];
        [faceToolBar.pageControl setHidden:YES];
        
    }else{
        
        faceToolBar.ifBeginVoice = YES;
        [faceToolBar.voiceButton setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoice.png"] forState:UIControlStateNormal];
        [faceToolBar.voiceButton setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoiceHL.png"] forState:UIControlStateHighlighted];
        faceToolBar.sendVoiceButton.hidden = YES;
        
        facePageIsShow = YES;
        [UIView animateWithDuration:Time animations:^{
            UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
            tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480 - keyboardHeight - toolBarHeight - navigateBarHeight - 20);
            faceToolBar.toolBar.frame = CGRectMake(0, self.view.frame.size.height - keyboardHeight - faceToolBar.toolBar.frame.size.height,  self.view.bounds.size.width, faceToolBar.toolBar.frame.size.height);
        }];
        
        [UIView animateWithDuration:Time animations:^{
            [faceToolBar.scrollView setFrame:CGRectMake(0, self.view.frame.size.height - keyboardHeight,self.view.frame.size.width, keyboardHeight)];
        }];
        [faceToolBar.pageControl setHidden:NO];
        [faceToolBar.textView resignFirstResponder];
    }
    [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                         atScrollPosition: UITableViewScrollPositionBottom
                                 animated:NO];
}

-(NSData *)downLoadFile:(UserMsg *)userMsg
{
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",MINI_CHAT_HTTP_SERVER, userMsg.msgMediaUrlFile];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];

    [request setFailedBlock:^{
        NSLog(@"%@", @"failed");
    }];
    
    [request setCompletionBlock:^{
        
    }];
    
    [request startAsynchronous];

    return nil;
}

-(void) addMessageToChatArray
{
    [self.chatArray removeAllObjects];
    NSDate *nowTime = [NSDate date];
	if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >5) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}

    for (UserMsg *userMsg in self.friendUserMsgArray) {
        if (self.friendUserMsgArray.count == 0) {
            return;
        }
        [userMsg setIsRead:YES];
        if ([userMsg.msgFromUserID isEqualToString:self.friendUserInfo.userID]) {
            UIView *chatView = [self bubbleView:userMsg from:NO];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:userMsg.msgType, @"msgType", @"other", @"speaker", chatView, @"view", nil]];
        } else
        {
            UIView *chatView = [self bubbleView:userMsg from:YES];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:userMsg.msgType, @"msgType", @"self", @"speaker", chatView, @"view", nil]];
        }
        
        [chatTableView reloadData];
        [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                             atScrollPosition: UITableViewScrollPositionBottom
                                     animated:NO];
    }
}

-(void)getMessageFromFriend:(NSNotification *)notification
{
    [self addMessageToChatArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchTextOrVedio:(id)sender
{
    UIButton *button  = (UIButton *)sender;
    if (button.tag == 1) {//切换成文本输入
       // textButton.hidden = YES;
      //  vedioButton.hidden = NO;
      //  talkTextField.hidden = NO;
      //  sendVoiceButton.hidden = YES;
        
    } else if (button.tag == 2) {//切换成语音输入
        //textButton.hidden = NO;
        //vedioButton.hidden = YES;
        //talkTextField.hidden = YES;
       // sendVoiceButton.hidden = NO;
    }
    
}

- (IBAction)tapBackground:(id)sender
{
   // [talkTextField resignFirstResponder];
}

- (IBAction)sendVoice:(id)sender
{
    
}

- (void)dealloc
{
   // [talkTextField release];
    self.myUserInfo = nil;
    self.friendUserInfo = nil;
   // [textButton release];
   // [vedioButton release];
   // [sendVoiceButton release];
    [chatTableView release];
    [super dealloc];
}
#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		return 30;
	}else {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height+10;
	}
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CommentCellIdentifier = @"CommentCell";
	ChatCustomCell *cell = (ChatCustomCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCustomCell" owner:self options:nil] lastObject];
	}
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		// Set up the cell...
		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
		[formatter release];
        
		[cell.dateLabel setText:timeString];
	}else {
		// Set up the cell...
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		UIView *chatView = [chatInfo objectForKey:@"view"];
		[cell.contentView addSubview:chatView];
	}
    return cell;

}
#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [faceToolBar.textView resignFirstResponder];
    [faceToolBar dismissKeyBoard];
}
/*
 生成对话框UIView
 文本:大小自动调整view的frame
 图片:固定高宽80*100
 语音:语音时间最长60秒, 根据语音时间／60 * 150来决定长度, 高度固定40
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(UserMsg *)userMsg from:(BOOL)fromSelf {
    
	UIImage *talkimage;
    UIImage *talkimagePressed;
    UIImageView *bubbleImageView;
    UIImageView *headImageView = [[UIImageView alloc] init];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
	// build single chat bubble cell with given text
    UIView *returnView;
    if(fromSelf){
        if ([userMsg.msgType isEqualToString:@"TEXT"]) {
            talkimage = [UIImage imageNamed:@"SenderTextNodeBkg.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            talkimagePressed = [UIImage imageNamed:@"SenderTextNodeBkgHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            returnView =  [self assembleMessageAtIndex:userMsg.msgText from:fromSelf];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            [bubbleImageView setHighlightedImage:talkimagePressed];
            bubbleImageView.frame = CGRectMake(3.0f, 14.0f, returnView.frame.size.width+41.0f, returnView.frame.size.height+41.0f );
        } else if ([userMsg.msgType isEqualToString:@"IMAGE"]) {
            talkimage = [UIImage imageNamed:@"SenderImageNodeBorder.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            talkimagePressed = [UIImage imageNamed:@"SenderImageNodeBorderHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            returnView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 100)];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 86)];
            button.layer.cornerRadius= 5;
            button.layer.masksToBounds= YES;
            button.contentMode = UIViewContentModeScaleAspectFit;
            [returnView addSubview:button];
            [button release];
            NSString *docPath = [NSString stringWithFormat:@"%@/Documents/images/", NSHomeDirectory()];
            NSString *imageFilePath = [docPath stringByAppendingString:userMsg.msgMediaUrlFile];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            [bubbleImageView setHighlightedImage:talkimagePressed];
            bubbleImageView.frame = CGRectMake(3.0f, 14.0f, returnView.frame.size.width+7.0f, returnView.frame.size.height+7.0f );

        } else if ([userMsg.msgType isEqualToString:@"AUDIO"]) {
            talkimage = [UIImage imageNamed:@"SenderTextNodeBkg.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            talkimagePressed = [UIImage imageNamed:@"SenderTextNodeBkgHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            returnView =  [self assembleMessageAtIndex:userMsg.msgText from:fromSelf];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            [bubbleImageView setHighlightedImage:talkimagePressed];
            bubbleImageView.frame = CGRectMake(3.0f, 14.0f, returnView.frame.size.width+7.0f, returnView.frame.size.height+7.0f );
        } else {
            return nil;
        }
        
        if ([MainViewController sharedMainViewController].loginUser.userImage!=nil) {
            [headImageView setImage:[MainViewController sharedMainViewController].loginUser.userImage];
        } else {
            [headImageView setImage:[UIImage imageNamed:@"NoHeaderImge.png"]];
        }
        returnView.frame= CGRectMake(12.0f, 7.0f, returnView.frame.size.width, returnView.frame.size.height);
        
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+10.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width + 7, 15.0f, 40.0f, 40.0f);
    }
	else{
        //fromfriend
        if ([userMsg.msgType isEqualToString:@"TEXT"]) {
            talkimage = [UIImage imageNamed:@"ReceiverTextNodeBkg.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:40 topCapHeight:30];
            talkimagePressed = [UIImage imageNamed:@"ReceiverTextNodeBkgHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            returnView =  [self assembleMessageAtIndex:userMsg.msgText from:fromSelf];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            [bubbleImageView setHighlightedImage:talkimagePressed];
            bubbleImageView.frame = CGRectMake(55.0f, 14.0f, returnView.frame.size.width+41.0f, returnView.frame.size.height+41.0f );
        } else if ([userMsg.msgType isEqualToString:@"IMAGE"]) {
            talkimage = [UIImage imageNamed:@"ReceiverImageNodeBorder.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            talkimagePressed = [UIImage imageNamed:@"ReceiverImageNodeBorderHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            returnView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 100)];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 86)];
            button.layer.cornerRadius= 5;
            button.layer.masksToBounds= YES;
            button.contentMode = UIViewContentModeScaleAspectFit;
            [returnView addSubview:button];
            [button release];
            
            NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
            NSString *imageFilePath = [docPath stringByAppendingString:[userMsg.msgMediaUrlFile substringWithRange:NSMakeRange(35, userMsg.msgMediaUrlFile.length - 35)]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
                UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
                [button setImage:image forState:UIControlStateNormal];
            } else {       
                NSString *imageUrl = [NSString stringWithFormat:@"%@",userMsg.msgMediaUrlFile];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
            
                [request setFailedBlock:^{
                    NSLog(@"%@", @"failed");
                }];
                
                [request setCompletionBlock:^{
                    UIImage *image = [UIImage imageWithData:request.responseData];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    NSString *docPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
                    NSString *imageDir = [docPath stringByAppendingString:@"images"];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:NO attributes:nil error:nil];
                    }
                    //imageurl样式 images／image343243er.png
                    NSString *imageFilePath = [docPath stringByAppendingString:[userMsg.msgMediaUrlFile substringWithRange:NSMakeRange(35, userMsg.msgMediaUrlFile.length - 35)]];
                    [request.responseData writeToFile:imageFilePath atomically:YES];
                }];
                [request startAsynchronous];
            }
           // bubbleImageView.frame = CGRectMake(3.0f, 14.0f, returnView.frame.size.width+4.0f, returnView.frame.size.height+4.0f );
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            [bubbleImageView setHighlightedImage:talkimagePressed];
            bubbleImageView.frame = CGRectMake(55.0f, 14.0f, returnView.frame.size.width+7.0f, returnView.frame.size.height+7.0f );
        } else if ([userMsg.msgType isEqualToString:@"AUDIO"]) {
            
            talkimage = [UIImage imageNamed:@"ReceiverTextNodeBkg.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:40 topCapHeight:30];
            talkimagePressed = [UIImage imageNamed:@"ReceiverTextNodeBkgHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            returnView =  [self assembleMessageAtIndex:userMsg.msgText from:fromSelf];
            bubbleImageView.frame = CGRectMake(55.0f, 14.0f, returnView.frame.size.width+7.0f, returnView.frame.size.height+7.0f);
        } else {
            
            talkimage = [UIImage imageNamed:@"ReceiverTextNodeBkg.png"];
            talkimage = [talkimage stretchableImageWithLeftCapWidth:40 topCapHeight:30];
            talkimagePressed = [UIImage imageNamed:@"ReceiverTextNodeBkgHL.png"];
            talkimagePressed = [talkimagePressed stretchableImageWithLeftCapWidth:(int)talkimage.size.width>>1 topCapHeight:(int)talkimage.size.width>>1];
            bubbleImageView = [[UIImageView alloc] initWithImage:talkimage];
            returnView =  [self assembleMessageAtIndex:@"" from:fromSelf];
            bubbleImageView.frame = CGRectMake(55.0f, 14.0f, returnView.frame.size.width+7.0f, returnView.frame.size.height+7.0f);
        }

        if (self.friendUserInfo.userImage!=nil) {
            [headImageView setImage:self.friendUserInfo.userImage];
        } else
        {
            [headImageView setImage:[UIImage imageNamed:@"default_head_online.png"]];
        }
        
        returnView.frame= CGRectMake(15.0f, 7.0f, returnView.frame.size.width, returnView.frame.size.height);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+50.0f,bubbleImageView.frame.size.height+10.0f);
        headImageView.frame = CGRectMake(10.0f, 15.f, 40.0f, 40.0f);
    }
    returnView.backgroundColor = [UIColor clearColor];
    //设置圆角图片
    headImageView.layer.cornerRadius= 5;
    headImageView.layer.masksToBounds= YES;
    headImageView.contentMode = UIViewContentModeScaleAspectFit;
 
    bubbleImageView.userInteractionEnabled = YES;
    [cellView addSubview:bubbleImageView];
    [bubbleImageView addSubview:returnView];
    [cellView addSubview:headImageView];
    [bubbleImageView release];
    [returnView release];
    [headImageView release];
	return [cellView autorelease];
    
}

#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
     // MAX_WIDTH KFacialSizeHeight KFacialSizeWidth
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(5, 10, 150, 20);
    label.text = message;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [returnView addSubview:label];
    [label sizeToFit];
    returnView.frame = CGRectMake(15.0f,1.0f, label.frame.size.width, label.frame.size.height); //@ 需要将该view的尺寸记下，方便以后使用
    return returnView;

}

@end
