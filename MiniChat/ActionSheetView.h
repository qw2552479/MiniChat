//
//  ActionSheetView.h
//  MiniChat
//
//  Created by aatc on 8/27/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionSheetViewDelegate <NSObject>

-(void) pickPhotoForMe;

@end

@interface ActionSheetView : UIView
{
    UIButton *takePictuerButton;
    UIButton *localPictureButton;
    UIButton *cancelButton;
    UIImageView *buttonBG;
    
}

@property (nonatomic, retain) id <ActionSheetViewDelegate> delegate;

@end
