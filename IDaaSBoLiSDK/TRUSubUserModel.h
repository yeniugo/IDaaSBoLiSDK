//
//  TRUSubUserModel.h
//  Good_IdentifyAuthentication
//
//  Created by hukai on 2018/12/20.
//  Copyright © 2018 zyc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRUSubUserModel : NSObject
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *img;
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *activation;
@property (nonatomic,copy) NSString *appId;
//+ (instancetype)modelWithDic:(NSDictionary *)dic;
@end
