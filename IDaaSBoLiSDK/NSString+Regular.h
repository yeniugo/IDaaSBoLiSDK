//
//  NSString+Regular.h
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/29.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regular)
- (BOOL)isEmail;
//仅验证大陆手机号 11位 具体号段不做校验
- (BOOL)isPhone;
- (BOOL)isIP;
- (BOOL)isLinuxUser;
- (BOOL)isBase64Str;

@end
