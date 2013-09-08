//
//  Utils.m
//  passwrod
//
//  Created by aatc on 8/5/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "Utils.h"

@implementation Utils

//验证帐号是否合法
- (BOOL) accountIsRight:(NSString *)account
{
    NSString *accountRule = @"^[a-zA-Z][a-zA-Z0-9_]{6,18}$";
    NSPredicate *accountTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", accountRule];
    return [accountTest evaluateWithObject:account];
}
//验证密码是否合法
- (BOOL) passwordIsRight:(NSString *)password
{
    NSString *passwordRule = @"^[a-zA-Z][a-zA-Z0-9]{6,18}$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRule];
    return [passwordTest evaluateWithObject:password];
}
- (BOOL) passwordIsSame:(NSString *)firstPassword secondPassword:(NSString *)secondPassword
{
    if (secondPassword.length == 0) {
        return false;
    }
    if ([firstPassword isEqualToString:secondPassword]) {
        return true;
    }
    return false;
}
- (BOOL) emailIsRight:(NSString *)email
{
    NSString *emailRule = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRule];
    return [emailTest evaluateWithObject:email];
}

@end
