//
//  TRUUserModel.m
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/21.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import "TRUUserModel.h"
#import "YYModel.h"
#import "TRUSubUserModel.h"
#import <objc/runtime.h>

static TRUUserModel *userModel=nil;

@implementation TRUUserModel



+ (instancetype)modelWithUserId:(NSString *)userId{
    TRUUserModel *model = [[self alloc] init];
    model.userId = userId;
    return model;
}

+ (instancetype)modelWithDic:(NSDictionary *)dic{
    id model = [[self alloc] init];
    [model yy_modelSetWithDictionary:dic];
    return model;
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"accounts" : [TRUSubUserModel class]
             };
}

//兼容
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *nameStr = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:nameStr];
        [aCoder encodeObject:value forKey:nameStr];
    }
    free(ivars);
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i ++) {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
        
    }
    return self;
}
@end
