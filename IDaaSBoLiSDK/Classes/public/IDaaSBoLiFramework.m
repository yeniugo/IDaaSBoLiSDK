//
//  IDaaSBoLiSDK.m
//  IDaaSBoLiSDK
//
//  Created by hukai on 2018/12/18.
//  Copyright © 2018年 hukai. All rights reserved.
//

#import "IDaaSBoLiFramework.h"
#import "xindunsdk.h"
#import "TRUhttpManager.h"
#import "YYModel.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <UIKit/UIKit.h>
#import "TRUUserAPI.h"
#import "TRUPushAuthModel.h"
#import "TRUBaseViewController.h"

@implementation TrusfrotEtoekn


@end



@implementation IDaaSBoLiSDK

+ (void)initXdSDKwithServerURL:(NSString *)serverURL appid:(NSString *)appid withReusult:(void (^)(bool errorCode))result{
    //http://cloud.trusfort.com:8000/cims
    //http://192.168.1.115:8080/cims
#if TARGET_IPHONE_SIMULATOR
//    [[NSUserDefaults standardUserDefaults] setObject:@"http://192.168.1.214:8100/cims" forKey:@"CIMSURL"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    TRUCompanyModel *companymodel = [[TRUCompanyModel alloc] init];
//    //    companymodel.activation_mode = @"1";
//    [TRUCompanyAPI saveCompany:companymodel];
#endif
    
    if (serverURL.length==0) {
        serverURL = @"";
    }
    if (appid.length==0) {
        appid = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:@"CIMSURL"];
    [[NSUserDefaults standardUserDefaults] setObject:appid forKey:@"appid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    bool result1 = [xindunsdk initEnv:@"com.example.demo" url:serverURL];
    result(result1);
}

+ (void)activeSecondWithUserNo:(NSString *)userNo activeNumber:(NSString *)activeNumber type:(int)type success:(void (^)(NSString *token,NSString *phoneOrEmail))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushID = [stdDefaults objectForKey:@"TRUPUSHID"];
    if (pushID == nil || pushID.length == 0) {
        pushID = @"1234567890";
    }
    NSString *type1;
    switch (type) {
        case 1:
        {
            type1 = @"employeenumPhone";
        }
            break;
        case 2:
        {
            type1 = @"employeenumEmail";
        }
            break;
        default:
            break;
    }
    NSString *singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%@\",\"type\":\"%@\",\"authcode\":\"%@\"", [userNo UTF8String],pushID, type1,activeNumber];
    NSString *para = [xindunsdk encryptBySkey:userNo ctx:singStr isType:YES];
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/checkUserInfo"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message) {
        if (errorno==0) {
            if (responseBody!=nil) {
                NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
                dic = dic[@"resp"];
                NSString *phone = dic[@"phone"];
                NSString *email = dic[@"email"];
                NSString *backToken = dic[@"token"];
                switch (type) {
                    case 1:
                    {
                        success(backToken,phone);
                    }
                        break;
                    case 2:
                    {
                        success(backToken,email);
                    }
                        break;
                    default:
                        break;
                }
            }
        }else{
            error(errorno,message);
        }
    }];
}

+ (void)active4UserWithUserNo:(NSString *)userNo activeNumber:(NSString *)activeNumber pushID:(NSString *)pushID type:(NSString *)type secondVerifyToken:(NSString *)secondToken success:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    __weak typeof(self) weakSelf = self;
    NSString *singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%s\",\"type\":\"%s\",\"authcode\":\"%s\"", [userNo UTF8String],[pushID UTF8String], [type UTF8String],[activeNumber UTF8String]];
    if (secondToken.length) {
        singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%s\",\"type\":\"%s\",\"authcode\":\"%s\",\"token\":\"%s\"", [userNo UTF8String],[pushID UTF8String], [type UTF8String],[activeNumber UTF8String],[secondToken UTF8String]];
    }
    NSString *para = [xindunsdk encryptBySkey:userNo ctx:singStr isType:YES];
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/active"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message) {
        
        NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
        if (errorno == 0) {
            NSString *userId = nil;
            int err = [xindunsdk privateVerifyCIMSInitForUserNo:userNo response:dic[@"resp"] userId:&userId];
            
            if (err == 0) {
                //同步用户信息
                NSString *paras = [xindunsdk encryptByUkey:userId ctx:nil signdata:nil isDeviceType:NO];
                NSDictionary *dictt = @{@"params" : [NSString stringWithFormat:@"%@",paras]};
//                NSString *baseUrl1 = @"http://192.168.1.150:8004";
                [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/getuserinfo"] withParts:dictt onResult:^(int errorno, id responseBody) {
                    
                    NSDictionary *dicc = nil;
                    if (errorno == 0 && responseBody) {
                        dicc = [xindunsdk decodeServerResponse:responseBody];
                        
                        if ([dicc[@"code"] intValue] == 0) {
                            dicc = dicc[@"resp"];
                            TRUUserModel *model = [TRUUserModel yy_modelWithDictionary:dicc];
                            model.userId = userId;
                            [TRUUserAPI saveUser:model];
                            [weakSelf getUserToken:success error:error];
                        }
                    }
                }];
            }
        }else{
            error(errorno,message);
        }
    }];
    
}

+(void)verifyJpushIdwithUserNO:(NSString *)userNo type:(NSString *)type withVerifyCodeOrPassword:(NSString *)code secondVerifyToken:(NSString *)secondToken success:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
//    NSString *activeNumber = code;
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushID = [stdDefaults objectForKey:@"TRUPUSHID"];
    
    if (!pushID || pushID.length == 0) {//说明pushid获取失败
        if ([type isEqualToString:@"employeenum"]) {
            [self active4UserWithUserNo:userNo activeNumber:code pushID:@"1234567890" type:type secondVerifyToken:secondToken success:success error:error];
        }else{
            [self active4UserWithUserNo:userNo activeNumber:code pushID:@"1234567890" type:type secondVerifyToken:secondToken success:success error:error];
        }
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        [stdDefaults setObject:@"1234567890" forKey:@"TRUPUSHID"];
        [stdDefaults synchronize];
        //#endif
    }else{
        if ([type isEqualToString:@"employeenum"]) {
            [self active4UserWithUserNo:userNo activeNumber:code pushID:@"1234567890" type:type secondVerifyToken:secondToken success:success error:error];
        }else{
            [self active4UserWithUserNo:userNo activeNumber:code pushID:@"1234567890" type:type secondVerifyToken:secondToken success:success error:error];
        }
    }
}

+(void)activeByEmployeenumWithUserNo:(NSString *)userNo withPwd:(NSString *)password secondVerifyToken:(NSString *)secondToken success:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    __weak typeof(self) weakSelf = self;
    [self getVerifyCodeWithUserNo:userNo withType:3 secondVerifyToken:nil success:^(BOOL isSuccess) {
        [weakSelf verifyJpushIdwithUserNO:userNo type:@"employeenum" withVerifyCodeOrPassword:password secondVerifyToken:secondToken success:success error:error];
    } error:error];
}

+(void)activeByPhoneOrEmailWithUserNo:(NSString *)userNo withVerifyCode:(NSString *)verifyCode withType:(int)type secondVerifyToken:(NSString *)secondToken success:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *typeStr;
    __weak typeof(self) weakSelf = self;
    switch (type) {
        case 1://手机号
        {
            typeStr = @"email";
        }
            break;
        case 2://邮箱
        {
            typeStr = @"phone";
        }
            break;
        case 3://工号
        {
            typeStr = @"employeenum";
        }
            break;
        case 4:
        {
            typeStr = @"employeenumPhone";
        }
            break;
        case 5:
        {
            typeStr = @"employeenumEmail";
        }
            break;
        default:
            break;
    }
    [self verifyJpushIdwithUserNO:userNo type:typeStr withVerifyCodeOrPassword:verifyCode secondVerifyToken:secondToken success:success error:error];
}

+(void)getVerifyCodeWithUserNo:(NSString *)userNo withType:(int)type secondVerifyToken:(NSString *)secondToken success:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *typeStr;
    switch (type) {
        case 1://手机号
        {
            typeStr = @"email";
        }
            break;
        case 2://邮箱
        {
            typeStr = @"phone";
        }
            break;
        case 3://工号
        {
            typeStr = @"employeenum";
        }
            break;
        case 4:
        {
            typeStr = @"employeenumPhone";
        }
            break;
        case 5:
        {
            typeStr = @"employeenumEmail";
        }
            break;
        default:
            break;
    }
    NSString *signStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"type\":\"%s\"}", [userNo UTF8String], [typeStr UTF8String]];
    if (secondToken.length) {
         signStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"type\":\"%s\",\"token\":\"%s\"}", [userNo UTF8String], [typeStr UTF8String],[secondToken UTF8String]];
    }
    NSString *para = [xindunsdk encryptBySkey:userNo ctx:signStr isType:NO];
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/apply4active"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message) {
        if (0 == errorno){
            success(YES);
        }else{
            error(errorno,message);
        }
    }];
}

+ (float)getPersentWithTime:(int)etokenTime{
    NSDate *date = [NSDate date];
    double time = [date timeIntervalSince1970];
    double timeDifference = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GS_DETAL_KEY"] doubleValue];
    return (long long)((time-timeDifference)*100)%(etokenTime*100)/100.0;
}

+ (void)getETokenwithTime:(int)etokenTime WithSuccess:(void (^)(TrusfrotEtoekn *EToken))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    TrusfrotEtoekn *EToken = [[TrusfrotEtoekn alloc] init];
    NSString *userid = [TRUUserAPI getUser].userId;
    EToken.password = [xindunsdk getCIMSDynamicCode:userid capacity:6 interval:etokenTime];
    EToken.time = [self getPersentWithTime:etokenTime];
    success(EToken);
}

+(NSString *)ret33bitString{
    char data[33];
    for (int x=0; x <33; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}

+ (void)syncETokenWithSuccess:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
        NSString *userId = [TRUUserAPI getUser].userId;
        NSString *seed = [self ret33bitString];
        NSArray *ctxx = @[@"randa",seed];
        NSString *para = [xindunsdk encryptByUkey:userId ctx:ctxx signdata:seed isDeviceType:NO];
    // 添加了一个防崩溃
        int i = 0;
        while (para.length==0) {
            i++;
            if (i>4) {
                return;
            }
            seed = [self ret33bitString];
            ctxx = @[@"randa",seed];
            para = [xindunsdk encryptByUkey:userId ctx:ctxx signdata:seed isDeviceType:NO];
        }
        NSDictionary *paramsDic = @{@"params" : para};
        __block long seconds_cli = (long)time((time_t *)NULL);
        [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/totp/sync"] withParts:paramsDic onResult:^(int errorno, id responseBody) {
            if (errorno!=0) {
                error(errorno,nil);
                return;
            }
            NSDictionary *dic = nil;
            dic = [xindunsdk decodeServerResponse:responseBody];
            if ([dic[@"code"] intValue] == 0) {
                dic = dic[@"resp"];
                NSString *shmac = dic[@"hmac"];
                NSString *timestamp = [shmac substringToIndex:(shmac.length - 44 - 3)];
                long time = [timestamp longLongValue];
                //hmac=timestamp+hmac（userkey，randa+timestamp）;
                if( [xindunsdk checkCIMSHmac:userId randa:seed shmac:shmac]){
                    seconds_cli = seconds_cli - time ;
                    [[NSUserDefaults standardUserDefaults] setObject:@(seconds_cli) forKey:@"GS_DETAL_KEY"];
    // 添加了一个数据保存
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    success(YES);
                }else{
                    error(-5001,nil);
                }
            }else{
                error(errorno,nil);
            }
        }];
}

+ (void)scanQrCode:(NSString *)result withSuccess:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    if (result.length >0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSArray *arr = [result componentsSeparatedByString:@"?"];
        NSString *str;
        if (arr.count>0) {
            str = [arr lastObject];
        }
        arr = [str componentsSeparatedByString:@"&"];
        if (arr.count >0) {
            for (NSString *str in arr) {
                NSArray *tmp = [str componentsSeparatedByString:@"="];
                NSString *key = [tmp firstObject];
                NSArray *value = [tmp lastObject];
                if (key && value) {
                    dic[key] = value;
                }
            }
        }
        
        NSString *op = dic[@"op"];
        NSString *authcode = dic[@"authcode"];
        
        
        if ([op isEqualToString:@"login"]) {
            NSString *userNo = [TRUUserAPI getUser].userId;
            if (userNo){
                success(authcode);
            }else{
                error(-1000,@"无效二维码");
            }
        }else{
            error(-2000,@"无效二维码，请确认二维码来源！");
        }
    }
}

+ (void)authInfoWithToken:(NSString *)token success:(void (^)(TRUPushAuthModel *authInfo))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    if ([TRUUserAPI getUser].userId) {
            NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
            NSString *sign = token;
            NSArray *ctxx = @[@"token",sign];
            NSString *para = [xindunsdk encryptByUkey:[TRUUserAPI getUser].userId ctx:ctxx signdata:sign isDeviceType:YES];
            NSDictionary *paramsDic = @{@"params" : para};
            [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/push/fetch"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message){
                NSDictionary *dic = nil;
                if (errorno == 0 && responseBody) {
                    dic = [xindunsdk decodeServerResponse:responseBody];
                    if ([dic[@"code"] intValue] == 0) {
                        dic = dic[@"resp"];
                        TRUPushAuthModel *model = [TRUPushAuthModel yy_modelWithDictionary:dic];
                        model.token = token;
                        success(model);
                    }
                }else{
                    error(errorno,message);
                }
            }];
            
        }
}

+ (void)checkToken:(NSString *)token withOpType:(int)type success:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    NSString *user = [TRUUserAPI getUser].userId;
    NSString *userStr = user;
    NSString *typeStr = [NSString stringWithFormat:@"%d",type];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@", token,typeStr,userStr];
    NSArray *ctxx = @[@"token",token,@"confirm",typeStr,@"userid",userStr];
    NSString *userId = [TRUUserAPI getUser].userId;
    NSString *para = [xindunsdk encryptByUkey:userId ctx:ctxx signdata:sign isDeviceType:NO];
    NSDictionary *paramsDic = @{@"params" : para};
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/verify/checktoken"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody,NSString *message) {
        if (errorno == 0) {
            success(YES);
        }else{
            error(errorno,message);
        }
    }];
}


+(void)deleteBindsuccess:(void (^)(BOOL isSuccess))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *userid = [TRUUserAPI getUser].userId;
    NSString *uuid = [xindunsdk getCIMSUUID:userid];
    //    NSString *phone = [TRUUserAPI getUser].phone;
    NSArray *deleteDevices = @[uuid];
    NSString *deldevs = nil;
    if (!deleteDevices || deleteDevices.count == 0) {
        deldevs = @"";
    }else{
        deldevs = [deleteDevices componentsJoinedByString:@","];
    }
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    NSArray *ctx = @[@"del_uuids",deldevs];
    NSString *sign = [NSString stringWithFormat:@"%@",deldevs];
    NSString *params = [xindunsdk encryptByUkey:userid ctx:ctx signdata:sign isDeviceType:NO];
    NSDictionary *paramsDic = @{@"params" : params};
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/device/delete"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody,NSString *message) {
        if (errorno == 0) {
            [xindunsdk deactivateUser:[TRUUserAPI getUser].userId];
            [TRUUserAPI deleteUser];
            success(YES);
        }else{
            error(errorno,message);
        }
    }];
}

+(void)getUserToken:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"refresh_token"];
    if (refreshToken.length==0) {
        [self getUserTokenWithRefreshToken:success error:error];
    }else{
        NSString *userid = [TRUUserAPI getUser].userId;
        NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
        NSString *appid = [[NSUserDefaults standardUserDefaults] objectForKey:@"appid"];
        NSString *sign = [NSString stringWithFormat:@"%@%@%@",userid,refreshToken,appid];
        NSArray *ctxx = @[@"userId",userid,@"refreshToken",refreshToken,@"appId",appid];
        NSString *paras = [xindunsdk encryptByUkey:userid ctx:ctxx signdata:sign isDeviceType:NO];
        NSDictionary *dictt = @{@"params" : [NSString stringWithFormat:@"%@",paras]};
        [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/token/refresh"] withParts:dictt onResultWithMessage:^(int errorno, id responseBody,NSString *message){
            if (errorno==0) {
                if (responseBody!=nil) {
                    NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
                    if ([dic[@"code"] intValue]==0) {
                        dic = dic[@"resp"];
                        NSString *token = dic[@"access_token"];
                        success(token);
                    }
                }
            }else if(errorno == 90037){
                [self getUserTokenWithRefreshToken:success error:error];
            }else{
                error(errorno,message);
            }
        }];
    }
}

+(void)getUserTokenWithRefreshToken:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
    NSString *userid = [TRUUserAPI getUser].userId;
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    NSString *paras = [xindunsdk encryptByUkey:userid ctx:nil signdata:nil isDeviceType:NO];
    NSDictionary *dictt = @{@"params" : [NSString stringWithFormat:@"%@",paras]};
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/token/gen"] withParts:dictt onResultWithMessage:^(int errorno, id responseBody,NSString *message){
        if(errorno==0){
            if (responseBody!=nil) {
                NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
                if([dic[@"code"] intValue]==0){
                    dic = dic[@"resp"];
                    NSString *refreshToken = dic[@"refresh_token"];
                    [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:@"refresh_token"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString *appid = [[NSUserDefaults standardUserDefaults] objectForKey:@"appid"];
                    NSString *sign = [NSString stringWithFormat:@"%@%@%@",userid,refreshToken,appid];
                    NSArray *ctxx = @[@"userId",userid,@"refreshToken",refreshToken,@"appId",appid];
                    NSString *paras = [xindunsdk encryptByUkey:userid ctx:ctxx signdata:sign isDeviceType:NO];
                    NSDictionary *dictt = @{@"params" : [NSString stringWithFormat:@"%@",paras]};
                    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/token/refresh"] withParts:dictt onResultWithMessage:^(int errorno, id responseBody,NSString *message){
                        if (errorno==0) {
                            if (responseBody!=nil) {
                                NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
                                if ([dic[@"code"] intValue]==0) {
                                    dic = dic[@"resp"];
                                    NSString *token = dic[@"access_token"];
                                    success(token);
                                }
                            }
                        }else{
                            error(errorno,message);
                        }
                    }];
                }
            }
        }else{
            error(errorno,message);
        }
    }];
}

+(NSString *)encryptValue:(NSString *)value{
    NSString *userId = [TRUUserAPI getUser].userId;
    return [xindunsdk encryptData:value ForUser:userId];
}

+(NSString *)decrypValue:(NSString *)value{
    NSString *userId = [TRUUserAPI getUser].userId;
    return [xindunsdk decryptData:value ForUser:userId];
}

+(void)fingerVerifyWithMaxTime:(int)maxTimes Withsuccess:(void (^)(BOOL isSuccess))successverify error:(void (^)(int errorCode, NSString *errorMsg))errorverify{
    __weak typeof(self) weskSelf = self;
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        NSString *errormessage = @"该设备暂时不支持TouchID验证，请去设置开启";
        errorverify(-1000,errormessage);
        return;
    }
    LAContext *ctx = [[LAContext alloc] init];
    if ([ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]) {
        if (@available(iOS 9.0, *)) {
            ctx.localizedFallbackTitle = @"密码登录";
            [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"使用指纹进行登录验证" reply:^(BOOL success, NSError * _Nullable error) {
                NSString *info = nil;
                if (success) {
                    info = @"验证成功";
                }else{
                    switch (error.code) {
                        case LAErrorUserFallback:
                            info = @"再试一次";
                            break;
                        case LAErrorUserCancel:
                        {
                            info = @"取消验证";
                            break;
                        }
                        case LAErrorTouchIDLockout:{
                            info = @"指纹验证失败";
                            break;
                        }
                        default:
                        {
                            if (maxTimes >= 0) {
                                info = @"再试一次";
                            }else{
                                info = @"指纹验证失败";
                            }
                            break;
                        }
                    }
                    
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([@"验证成功" isEqualToString:info]) {
                        successverify(YES);
                    }else if ([@"再试一次" isEqualToString:info]) {
                        [weskSelf fingerVerifyWithMaxTime:(maxTimes-1) Withsuccess:successverify error:errorverify];
                    }else if ([@"取消验证" isEqualToString:info]) {
                        errorverify(error.code,@"取消验证");
                    } else if ([@"指纹验证失败" isEqualToString:info]){
                        errorverify(error.code,@"指纹验证失败");
                    }
                });
            }];
        }else{
            ctx.localizedFallbackTitle = @"密码登录";
            [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"使用指纹进行登录验证" reply:^(BOOL success, NSError * _Nullable error) {
                NSString *info = nil;
                if (success) {
                    info = @"验证成功";
                }else{
                    switch (error.code) {
                        case LAErrorUserFallback:
                            info = @"再试一次";
                            break;
                        case LAErrorUserCancel:
                        {
                            info = @"取消验证";
                            break;
                        }
                        case LAErrorTouchIDLockout:{
                            info = @"指纹验证失败";
                            break;
                        }
                        default:
                        {
                            if (maxTimes >= 0) {
                                info = @"再试一次";
                            }else{
                                info = @"指纹验证失败";
                            }
                            break;
                        }
                    }
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([@"验证成功" isEqualToString:info]) {
                        successverify(YES);
                    }else if ([@"再试一次" isEqualToString:info]) {
                        [weskSelf fingerVerifyWithMaxTime:(maxTimes-1) Withsuccess:successverify error:errorverify];
                    }else if ([@"取消验证" isEqualToString:info]) {
                        errorverify(error.code,@"取消验证");
                    } else if ([@"指纹验证失败" isEqualToString:info]){
                        errorverify(error.code,@"指纹验证失败");
                    }
                });
            }];
        }
    } else {
        NSString *errormessage = @"该设备暂时不支持TouchID验证，请去设置开启";
        errorverify(-1000,errormessage);
    }
}

+(void)faceidVerifyWithsuccess:(void (^)(BOOL isSuccess))successverify error:(void (^)(int errorCode, NSString *errorMsg))errorverify{
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        NSString *errormessage = @"该设备暂时不支持TouchID验证，请去设置开启";
        errorverify(-1000,errormessage);
        return;
    }
    __weak typeof(self) weskSelf = self;
    if (@available(iOS 11.0, *)) {
        LAContext *ctx = [[LAContext alloc] init];
        if ([ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]) {
            ctx.localizedFallbackTitle = @"密码登录";
            [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"使用FaceID进行登录验证" reply:^(BOOL success, NSError * _Nullable error) {
                NSString *info = nil;
                if (success) {
                    info = @"验证成功";
                }else{
                    switch (error.code) {
                        case LAErrorUserFallback:
                            info = @"再试一次";
                            break;
                        case LAErrorUserCancel:
                        {
                            info = @"取消验证";
                            break;
                        }
                        case LAErrorBiometryLockout:{
                            info = @"人脸验证失败";
                            break;
                        }
                        case LAErrorSystemCancel:
                            break;
                        default:
                            info = @"再试一次";
                            break;
                    }
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    if ([@"验证成功" isEqualToString:info]) {
                        successverify(YES);
                    }else if ([@"再试一次" isEqualToString:info]) {
                        [weskSelf faceidVerifyWithsuccess:successverify error:errorverify];
                    } else if ([@"取消验证" isEqualToString:info]) {
                        errorverify(error.code,@"取消验证");
                    }else if ([@"人脸验证失败" isEqualToString:info]){
                        errorverify(error.code,@"人脸验证失败");
                    }
                });
            }];
        } else {
            NSString *errormessage = @"该设备暂时不支持FaceID验证，请去设置开启";
            errorverify(-1000,errormessage);
        }
    } else {
        NSString *errormessage = @"该系统不支持FaceID验证";
        errorverify(-1000,errormessage);
        return;
    }
}

+ (BOOL)checkFingerAvailable{
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        return NO;
    }
    LAContext *ctx = [[LAContext alloc] init];
    if (![ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]){
        return NO;
    }
    return YES;
}

+ (BOOL)checkFaceIDAvailable{
    LAContext *ctx = [[LAContext alloc] init];
    if (@available(iOS 11.0, *)) {
        if ([ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]){
            if (ctx.biometryType == LABiometryTypeFaceID) {
                return YES;
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    } else {
        return NO;
    }
}

+ (void)isNeedShowAuth:(void (^)(BOOL isNeedShowAuth,NSString *token,int error))needShowAuth{
    NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"refresh_token"];
    NSString *userid = [TRUUserAPI getUser].userId;
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    NSString *appid = [[NSUserDefaults standardUserDefaults] objectForKey:@"appid"];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@",userid,refreshToken,appid];
    NSArray *ctxx = @[@"userId",userid,@"refreshToken",refreshToken,@"appId",appid];
    NSString *paras = [xindunsdk encryptByUkey:userid ctx:ctxx signdata:sign isDeviceType:NO];
    NSDictionary *dictt = @{@"params" : [NSString stringWithFormat:@"%@",paras]};
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/token/refresh"] withParts:dictt onResultWithMessage:^(int errorno, id responseBody,NSString *message){
        if (errorno==0) {
            if (responseBody!=nil) {
                NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
                if ([dic[@"code"] intValue]==0) {
                    dic = dic[@"resp"];
                    NSString *token = dic[@"access_token"];
                    needShowAuth(NO,token,0);
                }
            }
        }else if(errorno ==90037){
            needShowAuth(YES,nil,90037);
        }else{
            needShowAuth(NO,nil,errorno);
        }
    }];
}

+ (BOOL)isActive{
    NSString *currentUserId = [TRUUserAPI getUser].userId;
    if (!currentUserId || currentUserId.length == 0 || [xindunsdk isUserInitialized:currentUserId] == false){
        return NO;
    }else{
        return YES;
    }
}

@end
