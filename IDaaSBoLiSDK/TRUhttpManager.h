//
//  TRUhttpManager.h
//  Good_IdentifyAuthentication
//
//  Created by zyc on 2018/8/6.
//  Copyright © 2018年 zyc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRUhttpManager : NSObject
//+ (instancetype)share;

+ (void)getCIMSRequestWithUrl:(NSString *)url withParts:(NSDictionary *)parts onResult:(void (^)(int errorno, id responseBody))onResult;
/**
 * CIMS数据请求
 */
+ (void)sendCIMSRequestWithUrl:(NSString *)url withParts:(NSDictionary *)parts onResult:(void (^)(int errorno, id responseBody))onResult;

+ (void)sendCIMSRequestWithUrl:(NSString *)url withParts:(NSDictionary *)parts onResultWithMessage:(void (^)(int errorno, id responseBody,NSString *message))onResult;

//+ (void)cancelALLHttp;
//+ (void)startALLHttp;
@end
