//
//  TRUAuthAPI.h
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/12.
//  Copyright © 2016年 Trusfort. All rights reserved.
//  用户接口

#import <Foundation/Foundation.h>
#import "TRUUserModel.h"

@interface TRUUserAPI : NSObject
//保存用户
+ (void)saveUser:(TRUUserModel *)user;
//获取用户
+ (TRUUserModel *)getUser;
//删除用户
+ (void)deleteUser;
+(BOOL)haveSubUser;
+ (NSArray *)getSubUser;
+ (NSArray *)getAllUser;
+(int)subUserCount;
@end
