//
//  UserInfo.m
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize userID;
@synthesize userName;
@synthesize userPwd;
@synthesize userAge;
@synthesize userSex;
@synthesize userType;
@synthesize userSign;
@synthesize userImageUrl;
@synthesize userImage;
@synthesize userStatusTime;
@synthesize userStatusLogo;
-(id)init
{
    if ( (self = [super init]) ) {
        
        self.isYourFriend = NO;
        
    }
    
    return self;
}

-(NSString *)getFirstString
{
    return [[userName lowercaseString] substringToIndex:1];
}

-(void)dealloc
{
    self.userID = nil;
    self.userName = nil;
    self.userAge = nil;
    self.userImage = nil;
    self.userImageUrl = nil;
    self.userPwd = nil;
    self.userSex = nil;
    self.userType = nil;
    self.userSign = nil;
    
    [super dealloc];
}

@end


//-------------------------msg 信息类-----------------------------
@implementation UserMsg

-(id)init
{
    if ( (self = [super init]) ) {
        
        self.isRead = NO;
    
    }
    
    return self;
}

-(void)dealloc
{
    self.msgID = nil;
    self.msgText = nil;
    self.msgType = nil;
    self.msgTime = nil;
    self.msgToUserID = nil;
    self.msgFromUserID = nil;
    self.msgMediaUrlFile = nil;
    self.msgMediaLocalFile = nil;

    [super dealloc];
}



@end