//
//  TRUAuthModel.h
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/16.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRUAuthModel : NSObject
/** 应用type */
@property (nonatomic, copy) NSString *appType;
/** 应用id */
@property (nonatomic, copy) NSString *appid;
/** 应用名 */
@property (nonatomic, copy) NSString *appname;
/** 应用的绑定用户账号 */
@property (nonatomic, copy) NSString *username;
/** 应用简称 */
@property (nonatomic, copy) NSString *shortname;
/** 应用图标颜色 */
@property (nonatomic, copy) NSString *iconcolor;
/** 是否已激活 */
@property (nonatomic, assign) NSInteger isactive;
/** 是否系统应用 */
@property (nonatomic, assign) NSInteger issys;
/** 是否已激活 */
@property (nonatomic, assign) BOOL isActive;
/** 是否系统应用 */
@property (nonatomic, assign) BOOL isSys;
/** 图片url地址 */
@property (nonatomic, copy) NSString *iconurl;

+ (instancetype)modelWithDic:(NSDictionary *)dic;


@end
