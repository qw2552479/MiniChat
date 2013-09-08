//
//  MyAnimation.m
//  MiniChat
//
//  Created by aatc on 8/25/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "MyAnimation.h"

@implementation MyAnimation

-(void)tapCellChangeColorToGreen:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.25f animations:^{
       // cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:78.0/255 green:228.0/255 blue:59.0/255 alpha:0.9];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f animations:^{
            cell.backgroundColor = [UIColor whiteColor];
        }];
       // cell.backgroundColor = [UIColor colorWithRed:78.0/255 green:228.0/255 blue:59.0/255 alpha:0.9];
       // cell.backgroundColor = [UIColor whiteColor];

    }];
}

@end
