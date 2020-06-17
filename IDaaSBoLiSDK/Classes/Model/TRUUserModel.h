//
//  TRUUserModel.h
//  UniformIdentityAuthentication
//
//  Created by Trusfort on 2016/12/21.
//  Copyright © 2016年 Trusfort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRUSubUserModel.h"
@interface TRUUserModel : NSObject<NSCoding>
/** 用户名 */
@property (nonatomic, copy) NSString *userId;
/** 用户手机 */
@property (nonatomic, copy) NSString *phone;
/** 姓名 */
@property (nonatomic, copy) NSString *realname;
/** 部门 */
@property (nonatomic, copy) NSString *department;
/** 工号 */
@property (nonatomic, copy) NSString *employeenum;
/** 邮箱 */
@property (nonatomic, copy) NSString *email;
/** 公司id */
@property (nonatomic, copy) NSString *spid;
/** 公司名 */
@property (nonatomic, copy) NSString *spname;
/** 声纹ID */
@property (nonatomic, copy) NSString *voiceid;
/** 人脸 */
@property (nonatomic, copy) NSString *faceinfo;
/** 子账号 */
@property (nonatomic, strong) NSArray *accounts;
+ (instancetype)modelWithUserId:(NSString *)userId;
+ (instancetype)modelWithDic:(NSDictionary *)dic;


@end
