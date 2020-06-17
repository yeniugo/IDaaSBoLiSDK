//
//  TRUhttpManager.m
//  Good_IdentifyAuthentication
//
//  Created by zyc on 2018/8/6.
//  Copyright © 2018年 zyc. All rights reserved.
//

#import "TRUhttpManager.h"
#import "AFNetworking.h"
#import "TRUMacros.h"
@interface TRUhttpManager()
@property (nonatomic,strong) AFHTTPSessionManager *manager;
//@property (nonatomic,assign) BOOL canRequest;
@end

@implementation TRUhttpManager

+ (instancetype)share{
    static TRUhttpManager *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
        sharedInstance.manager = [AFHTTPSessionManager manager];
        sharedInstance.manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 上传JSON格式
        sharedInstance.manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式
        // 超时时间
        sharedInstance.manager.requestSerializer.timeoutInterval = 30.0f;
        
        // 设置接收的Content-Type
        sharedInstance.manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
        
//        sharedInstance.canRequest = YES;
    }
    return sharedInstance;
}

+ (void)getCIMSRequestWithUrl:(NSString *)url withParts:(NSDictionary *)parts onResult:(void (^)(int errorno, id responseBody))onResult{
    TRUhttpManager *trumanager = [self share];
    AFHTTPSessionManager *manager = trumanager.manager;
//    if (!trumanager.canRequest) {
//        return;
//    }
    
    [manager GET:url parameters:parts progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (!trumanager.canRequest) {
//            return;
//        }
        onResult(0,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (!trumanager.canRequest) {
//            return;
//        }
        onResult(-5004, nil);
    }];
}


/**
 * CIMS数据请求
 */
+ (void)sendCIMSRequestWithUrl:(NSString *)url withParts:(NSDictionary *)parts onResult:(void (^)(int errorno, id responseBody))onResult{
    
    TRUhttpManager *trumanager = [self share];
    AFHTTPSessionManager *manager = trumanager.manager;
//    if (!trumanager.canRequest) {
//        return;
//    }
    YCLog(@"url = %@",url);
    [manager POST:url parameters:parts progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (!trumanager.canRequest) {
//            return;
//        }
        YCLog(@" response = %@",responseObject);
        if (onResult) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                int status = [dic[@"status"] intValue];
                int result = status == 1000 ? 0 : status;
                id response_body = nil;
                if ([dic.allKeys containsObject:@"response_body"]) {
                    response_body = dic[@"response_body"];
                    response_body = [response_body isKindOfClass:[NSNull class]] ? nil : response_body;
                }
                onResult(result, response_body);
                if (result!=0) {
                    YCLog(@"url = %@ afn result = %d",url,result);
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (!trumanager.canRequest) {
//            return;
//        }
        onResult(-5004, nil);
    }];
    
    
}

+ (void)sendCIMSRequestWithUrl:(NSString *)url withParts:(NSDictionary *)parts onResultWithMessage:(void (^)(int errorno, id responseBody,NSString *message))onResult{
    
    TRUhttpManager *trumanager = [self share];
    AFHTTPSessionManager *manager = trumanager.manager;
//    if (!trumanager.canRequest) {
//        return;
//    }
    YCLog(@"url = %@",url);
    [manager POST:url parameters:parts progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (!trumanager.canRequest) {
//            return;
//        }
        YCLog(@" response = %@",responseObject);
        if (onResult) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                int status = [dic[@"status"] intValue];
                int result = status == 1000 ? 0 : status;
                id response_body = nil;
                if ([dic.allKeys containsObject:@"response_body"]) {
                    response_body = dic[@"response_body"];
                    response_body = [response_body isKindOfClass:[NSNull class]] ? nil : response_body;
                }
                NSString *message=nil;
                if ([dic.allKeys containsObject:@"msg"]) {
                    message = dic[@"msg"];
                    message = [message isKindOfClass:[NSNull class]] ? nil : message;
                }
                onResult(result, response_body,message);
                if (result!=0) {
                    YCLog(@"url = %@ afn result = %d",url,result);
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onResult(-5004, nil,nil);
    }];
    
    
}

+ (void)cancelALLHttp{
    TRUhttpManager *trumanager = [self share];
//    trumanager.canRequest = NO;
//    [trumanager.manager.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
//        for (NSURLSessionDataTask *task in dataTasks) {
//            [task cancel];
//        }
//    }];
}

+ (void)startALLHttp{
    TRUhttpManager *trumanager = [self share];
//    trumanager.canRequest = YES;
}

@end
