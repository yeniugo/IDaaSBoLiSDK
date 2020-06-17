//
//  NSString+Regular.m
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/29.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import "NSString+Regular.h"

@implementation NSString (Regular)
- (BOOL)isEmail{
    NSString *regExp = @"\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}";
    return [self validateWithRegExp:regExp];
}
- (BOOL)isPhone{
    NSString * regExp = @"^1\\d{10}$";
    return [self validateWithRegExp:regExp];
}
- (BOOL)isIP{
    NSString * regExp = @"(2(5[0-5]{1}|[0-4]\\d{1})|[0-1]?\\d{1,2})(\\.(2(5[0-5]{1}|[0-4]\\d{1})|[0-1]?\\d{1,2})){3}";
    return [self validateWithRegExp:regExp];
}
- (BOOL)isLinuxUser{
    NSString * regExp = @"^[a-zA-Z0-9~!@#$%^&*()_{}:;<>?]{0,20}$";
    return [self validateWithRegExp:regExp];
}
- (BOOL)validateWithRegExp: (NSString *)regExp
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExp];
    return [predicate evaluateWithObject:self];
    
}

- (BOOL)isBase64Str{
    NSString *regExp = @"^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$";
    return [self validateWithRegExp:regExp];
    
}

@end
