//
//  TRUAuthModel.m
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/16.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import "TRUAuthModel.h"
#import "YYModel.h"
static NSString *TRUAUTHLISTKEY = @"bc637a613f52f26462264ea4cca5ecb5";
static NSString *TRUAUTHARRAYKEY = @"acce4b6c75b9c8130f56175560d08a13";
@implementation TRUAuthModel

+ (instancetype)modelWithDic:(NSDictionary *)dic{
    id model = [[self alloc] init];
    [model yy_modelSetWithDictionary:dic];
    return model;
}
//兼容错误
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
