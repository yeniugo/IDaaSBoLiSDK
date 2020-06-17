//
//  TRUPushAuthModel.h
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/27.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRUPushAuthModel : NSObject

/** 应用ID */
@property (nonatomic, copy) NSString *appid;
/** 应用名 */
@property (nonatomic, copy) NSString *appname;
/** 登录IP */
@property (nonatomic, copy) NSString *ip;
/** 位置 */
@property (nonatomic, copy) NSString *location;
/** token */
@property (nonatomic, copy) NSString *token;
/** 用户名 */
@property (nonatomic, copy) NSString *username;
/** 序列码 */
@property (nonatomic, copy) NSString *serialNumber;
/** 操作时间 */
@property (nonatomic, copy) NSString *dateTime;

@property (nonatomic, strong) NSArray *displayFields;

/** 验证类型
 0:二维码
 1:推送
 2:软令牌
 3:短信
 4:语音
 5:授权码
 6:人脸
 7:声纹
 */
@property (nonatomic, copy) NSString *authtype;
@property (nonatomic, assign) NSInteger ttl;

+ (instancetype)modelWithDic:(NSDictionary *)dic;
@end
