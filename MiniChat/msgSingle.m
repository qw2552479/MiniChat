//
//  msgSingle.m
//  MiniChat
//
//  Created by aatc on 9/3/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "msgSingle.h"

@implementation msgSingle
@synthesize msgChatArray;


+(msgSingle *)shareObject
{
    static msgSingle *ssmsgSingle = nil;
   if (ssmsgSingle == nil)
   {
        ssmsgSingle = [[msgSingle alloc] initWithNibName:@"msgSingle" bundle:nil];
     
    }
    return ssmsgSingle;
}

-(void)msg
{
    NSMutableDictionary *msgSingleDic = [[NSMutableDictionary alloc] init];
     
    [msgSingleDic objectForKey:@"talkUserID"];
    [msgSingleDic objectForKey:@"chatArray"];
    
    [msgChatArray addObject:msgSingleDic];
    
    
}


@end
