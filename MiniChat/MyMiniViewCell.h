//
//  MyMiniViewCell.h
//  MiniChat
//
//  Created by aatc on 8/26/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMiniViewCell : UITableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UIImageView *userHeadImage;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UILabel *userMsg;
@property (retain, nonatomic) IBOutlet UILabel *userTime;
@property (retain, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (retain, nonatomic) IBOutlet UILabel *badgeValueLabel;


@end
