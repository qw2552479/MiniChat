//
//  FaceToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//
#define Time  0.25
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define  keyboardHeight 216
#define  toolBarHeight 45
#define  navigateBarHeight 44
#define  choiceBarHeight 35
#define  facialViewWidth 300
#define facialViewHeight 170
#define  buttonWh 34
#import <UIKit/UIKit.h>
#import "FacialView.h"
#import "UIExpandingTextView.h"

@protocol FaceToolBarDelegate <NSObject>
-(void)sendTextAction:(NSString *)inputText;
-(void)sendImage;
@end
@interface FaceToolBar : UIToolbar<facialViewDelegate,UIExpandingTextViewDelegate,UIScrollViewDelegate>
{
    UIToolbar *toolBar;//工具栏
    UIExpandingTextView *textView;//文本输入框
    
    UIButton *voiceButton;
    UIButton *sendButton;
    UIButton *sendVoiceButton;
    BOOL keyboardIsShow;//键盘是否显示
    BOOL ifBeginVoice;
    
    UIScrollView *scrollView;//表情滚动视图
    UIPageControl *pageControl;
    
    UIView *theSuperView;

    NSObject <FaceToolBarDelegate> *delegate;
}

@property (nonatomic, retain) UIButton *voiceButton;
@property (nonatomic, assign) BOOL ifBeginVoice;
@property (nonatomic, retain) UIButton *sendVoiceButton;
@property (nonatomic, retain) UIView *theSuperView;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIExpandingTextView *textView;

@property (assign) NSObject<FaceToolBarDelegate> *delegate;
-(void)dismissKeyBoard;
-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView;
@end
