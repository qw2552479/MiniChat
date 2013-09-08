//
//  msgSingle.h
//  MiniChat
//
//  Created by aatc on 9/3/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface msgSingle : NSObject


@property (nonatomic,retain)    NSMutableArray *msgChatArray;



+(msgSingle *)shareObject;

@end
