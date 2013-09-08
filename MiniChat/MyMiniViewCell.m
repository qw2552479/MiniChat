//
//  MyMiniViewCell.m
//  MiniChat
//
//  Created by aatc on 8/26/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "MyMiniViewCell.h"

@implementation MyMiniViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {
    [_userHeadImage release];
    [_userName release];
    [_userMsg release];
    [_userTime release];
    [_badgeImageView release];
    [_badgeValueLabel release];
    [super dealloc];
}
@end
