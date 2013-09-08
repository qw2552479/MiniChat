//
//  AddressCell.m
//  MiniChat
//
//  Created by aatc on 8/29/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "AddressCell.h"

@implementation AddressCell

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
    self.nameLabel = nil;
    self.headImageView = nil;
    self.nameLabel = nil;
    self.userSignText = nil;
    self.headImageView = nil;
    [_numOfMessageLabel release];
    [_redImageView release];
    [super dealloc];
}
@end
