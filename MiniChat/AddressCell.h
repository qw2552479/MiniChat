//
//  AddressCell.h
//  MiniChat
//
//  Created by aatc on 8/29/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *headImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UITextView *userSignText;
@property (retain, nonatomic) IBOutlet UILabel *numOfMessageLabel;
@property (retain, nonatomic) IBOutlet UIImageView *redImageView;

@end
