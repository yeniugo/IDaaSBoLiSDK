//
//  TRUAuthAPI.m
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/12.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import "TRUUserAPI.h"
#import "YYModel.h"
static NSString *TRUUSERKEY = @"993d3d1eee762af60e2f13387ad18640";
static NSString *TRULASTUSEREMAILKEY = @"d5ec612335cd2c67bb3a4363e1d93bda";

@implementation TRUUserAPI

+ (void)saveUser:(TRUUserModel *)user{
    NSDictionary *mutableDic = [user yy_modelToJSONObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:mutableDic.copy forKey:TRUUSERKEY];
    [defaults setObject:user.email forKey:TRULASTUSEREMAILKEY];
    [defaults synchronize];
}
+ (TRUUserModel *)getUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id data = [defaults objectForKey:TRUUSERKEY];
    TRUUserModel *model;
    NSString *classNameStr = NSStringFromClass([data class]);
    if ([classNameStr isEqualToString:@"__NSCFData"]) {
        
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else{
        model = [TRUUserModel yy_modelWithDictionary:data];
    }
    if(model.userId.length==0){
        
    }
    return model;
}

+ (NSArray *)getSubUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id data = [defaults objectForKey:TRUUSERKEY];
    TRUUserModel *model;
    NSString *classNameStr = NSStringFromClass([data class]);
    if ([classNameStr isEqualToString:@"__NSCFData"]) {
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else{
        model = [TRUUserModel yy_modelWithDictionary:data];
    }
    NSArray *subUserArray = model.accounts;
    NSMutableArray *subMutArray = [NSMutableArray arrayWithArray:subUserArray];
    if (subUserArray.count>0) {
        [subMutArray removeObjectAtIndex:0];
    }
    return subUserArray;
//    return model;
}
+ (NSArray *)getAllUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id data = [defaults objectForKey:TRUUSERKEY];
    TRUUserModel *model;
    NSString *classNameStr = NSStringFromClass([data class]);
    if ([classNameStr isEqualToString:@"__NSCFData"]) {
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else{
        model = [TRUUserModel yy_modelWithDictionary:data];
    }
    NSArray *subUserArray = model.accounts;
    NSMutableArray *subMutArray = [NSMutableArray arrayWithArray:subUserArray];
    
    return subUserArray;
    //    return model;
}
+(int)subUserCount{
    TRUUserModel *user = [self getUser];
//    return user.accounts.count ? user.accounts.count - 1 : 0;
    int subuserCount = 0;
    for (int i = 0; i < user.accounts.count; i++) {
        NSString *userid = [TRUUserAPI getUser].userId;
        TRUSubUserModel *subUser = user.accounts[i];
        if (![subUser.userId isEqualToString:userid]) {
            subuserCount ++;
        }
    }
    return subuserCount;
}
+(BOOL)haveSubUser{
    TRUUserModel *user = [self getUser];
    if (user.accounts.count) {
        return YES;
    }else{
        return NO;
    }
}
+ (void)deleteUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:TRUUSERKEY];
    [defaults synchronize];
}

@end
