//
//  Utils.h
//  passwrod
//
//  Created by aatc on 8/5/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

- (BOOL) accountIsRight:(NSString *)account;
//验证密码是否合法
- (BOOL) passwordIsRight:(NSString *)account;
//两次密码是否相同
- (BOOL) passwordIsSame:(NSString *)firstPassword secondPassword:(NSString *)secondPassword;
//邮箱是否正确
- (BOOL) emailIsRight:(NSString *)account;

@end
