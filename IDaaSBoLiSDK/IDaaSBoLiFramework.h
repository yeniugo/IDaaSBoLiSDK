//
//  IDaaSBoLiSDK.h
//  IDaaSBoLiSDK
//
//  Created by hukai on 2018/12/18.
//  Copyright © 2018年 hukai. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "TRUBaseViewController.h"

#import "TRUPushAuthModel.h"

@interface TrusfrotEtoekn : NSObject
@property (copy,nonatomic) NSString *password;
@property (assign,nonatomic) float time;
@end


@interface IDaaSBoLiSDK : NSObject

+ (void)initXdSDKwithServerURL:(NSString *)serverURL appid:(NSString *)appid withReusult:(void (^)(bool errorCode))result;

//- (void)scanCodeFromCameraWithResult:(NSString *)result onResult:(void (^)(NSDictionary *returnDic))onResult;
//
//- (void)requestCodeForAccount:(NSString *)user type:(NSString *)type onResult:(void (^)(NSDictionary *returnDic))onResult;
//
//- (void)verifyWithAccount:(NSString *)user type:(NSString *)type withVerifyCodeOrPassword:(NSString *)verifyCodeOrPassword onResult:(void (^)(NSDictionary *returnDic))onResult;
+ (void)activeSecondWithUserNo:(NSString *)userNo activeNumber:(NSString *)activeNumber type:(int)type success:(void (^)(NSString *token,NSString *phoneOrEmail))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+(void)activeByEmployeenumWithUserNo:(NSString *)userNo withPwd:(NSString *)password secondVerifyToken:(NSString *)secondToken success:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+(void)activeByPhoneOrEmailWithUserNo:(NSString *)userNo withVerifyCode:(NSString *)verifyCode withType:(int)type secondVerifyToken:(NSString *)secondToken success:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+(void)getVerifyCodeWithUserNo:(NSString *)userNo withType:(int)type secondVerifyToken:(NSString *)secondToken success:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+ (void)getETokenwithTime:(int)etokenTime WithSuccess:(void (^)(TrusfrotEtoekn *EToken))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+ (void)syncETokenWithSuccess:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+ (void)scanQrCode:(NSString *)qrCode withSuccess:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+ (void)authInfoWithToken:(NSString *)token success:(void (^)(TRUPushAuthModel *authInfo))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+ (void)checkToken:(NSString *)token withOpType:(int)type success:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+(void)deleteBindsuccess:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+(void)getUserToken:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error;

+(NSString *)encryptValue:(NSString *)value;

+(NSString *)decrypValue:(NSString *)value;

+(void)fingerVerifyWithMaxTime:(int)maxTimes Withsuccess:(void (^)(BOOL isSuccess))successverify error:(void (^)(int errorCode, NSString *errorMsg))errorverify;

+(void)faceidVerifyWithsuccess:(void (^)(BOOL isSuccess))successverify error:(void (^)(int errorCode, NSString *errorMsg))errorverify;

+ (BOOL)checkFingerAvailable;

+ (BOOL)checkFaceIDAvailable;

+ (void)isNeedShowAuth:(void (^)(BOOL isNeedShowAuth,NSString *token,int error))needShowAuth;

+ (BOOL)isActive;

@end
