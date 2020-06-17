//
//  TRUPushingViewController.h
//  Good_IdentifyAuthentication
//
//  Created by hukai on 2018/10/30.
//  Copyright © 2018年 zyc. All rights reserved.
//

#import "TRUBaseViewController.h"
//@class TRUBaseViewController;
#import <IDaaSBoLiSDK/TRUPushAuthModel.h>
@interface TRUPushingViewController : TRUBaseViewController
/** 用户ID */
@property (nonatomic, copy) NSString *userNo;
/** token */
@property (nonatomic, copy) NSString *token;
/** 正文提示内容 */
@property (nonatomic, copy) NSString *alert;

@property (nonatomic, strong) TRUPushAuthModel *pushModel;

/** 回调 */
@property (nonatomic, copy) void (^dismissBlock)(BOOL corfirm);

/** 人脸 */
@property (nonatomic, copy) void (^popFaceBlock)();

/** 声纹 */
@property (nonatomic, copy) void (^popVoiceBlock)();
@end
