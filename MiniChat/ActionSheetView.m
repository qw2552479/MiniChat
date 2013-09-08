//
//  ActionSheetView.m
//  MiniChat
//
//  Created by aatc on 8/27/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "ActionSheetView.h"

@implementation ActionSheetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize frame = [[UIScreen mainScreen] bounds].size;
        
        UIImage *actionButtonImage = [UIImage imageNamed:@"login_welcome_green_btn.9.png"];
        actionButtonImage = [actionButtonImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        UIImage *cancelButtonImage = [UIImage imageNamed:@"login_welcome_green_btn.9.png"];
        cancelButtonImage = [cancelButtonImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        UIImage *buttonBGImage = [UIImage imageNamed:@"VoipMessagePromptBtnBkg.png"];
        buttonBGImage = [buttonBGImage stretchableImageWithLeftCapWidth:(int)(buttonBGImage.size.width)>>1 topCapHeight:10];
        
        takePictuerButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.width - 260) / 2, frame.height + 230, 260, 40)];
        localPictureButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.width - 260) / 2, frame.height + 180, 260, 40)];
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.width - 260) / 2, frame.height + 120, 260, 40)];
        buttonBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.height + 245, 320, 280)];
        
        [takePictuerButton setTintColor:[UIColor blackColor]];
        [localPictureButton setTintColor:[UIColor blackColor]];
        [cancelButton setTintColor:[UIColor blackColor]];
        
        [takePictuerButton setTitle:@"拍照" forState:UIControlStateNormal];
        [localPictureButton setTitle:@"选择本地图片" forState:UIControlStateNormal];
        [cancelButton setTitle: @"取消" forState:UIControlStateNormal];
        
        [takePictuerButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        [localPictureButton addTarget:self action:@selector(takePictureFromSystem) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonBG setImage:buttonBGImage];
        [self addSubview:buttonBG];
        [takePictuerButton setBackgroundImage:actionButtonImage forState:UIControlStateNormal];
        [self addSubview:takePictuerButton];
        [takePictuerButton release];
        [localPictureButton setBackgroundImage:actionButtonImage forState:UIControlStateNormal];
        [self addSubview:localPictureButton];
        [localPictureButton release];
        [cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
        [self addSubview:cancelButton];
        [cancelButton release];
        [buttonBG release];
        
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    [self buttonAnimation];

    return self;
}

-(void) buttonAnimation
{
    CGSize frame = [[UIScreen mainScreen] bounds].size;
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    [bg setBackgroundColor:[UIColor blackColor]];
    bg.alpha = 0;
    [self insertSubview:bg atIndex:1];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        bg.alpha = 0.5;
        takePictuerButton.frame = CGRectMake((frame.width - 260) / 2, frame.height - 230, 260, 40);
        localPictureButton.frame = CGRectMake((frame.width - 260) / 2, frame.height - 180, 260, 40);
        cancelButton.frame = CGRectMake((frame.width - 260) / 2, frame.height - 120, 260, 40);
        buttonBG.frame = CGRectMake(0, frame.height - 265, 320, 280);
    } completion:^(BOOL finished) {
    
    }];
}

-(void)cancel
{
    NSLog(@"das");
    [(UITableView *)[self superview] setScrollEnabled:YES];
    [self removeFromSuperview];
}


-(void)takePictureFromSystem
{
    [self.delegate pickPhotoForMe];
    [self removeFromSuperview];
}

-(void)tekePicture
{
    NSLog(@"没有相机");
    [self removeFromSuperview];
}

- (void)dealloc {
    [takePictuerButton release];
    [localPictureButton release];
    [cancelButton release];
    [buttonBG release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
