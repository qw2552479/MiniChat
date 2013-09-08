//
//  UserInfo.h
//  MiniChat
//
//  Created by aatc on 8/23/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, copy) NSString *userID;//登录帐号
@property (nonatomic, copy) NSString *userName;//昵称
@property (nonatomic, copy) NSString *userPwd;//密码
@property (nonatomic, copy) NSString *userAge;//年龄
@property (nonatomic, copy) NSString *userSex;//性别
@property (nonatomic, copy) NSString *userType;//类型
@property (nonatomic, copy) NSString *userSign;//签名
@property (nonatomic, copy) NSString *userImageUrl;//头像
@property (nonatomic, copy) NSString *userStatusTime;//时间
@property (nonatomic, copy) NSString *userStatusLogo;
@property (nonatomic, retain) UIImage *userImage;

@property (nonatomic, assign) BOOL isYourFriend;
-(NSString *)getFirstString;
@end
//-------------------------msg 信息类-----------------------------

@interface UserMsg : NSObject

@property (nonatomic, copy) NSString *msgID;
@property (nonatomic, copy) NSString *msgFromUserID;
@property (nonatomic, copy) NSString *msgToUserID;
@property (nonatomic, copy) NSString *msgType;//text, audio, image
@property (nonatomic, copy) NSString *msgText;
//媒体路径
@property (nonatomic, copy) NSString *msgMediaUrlFile;//网络
@property (nonatomic, copy) NSString *msgMediaLocalFile;//本地
@property (nonatomic, copy) NSString *msgTime;
@property (nonatomic, assign) BOOL isRead;//已读 未读

@end