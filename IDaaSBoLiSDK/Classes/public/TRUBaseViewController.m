//
//  TRUBaseViewController.m
//  Good_IdentifyAuthentication
//
//  Created by zyc on 2017/9/25.
//  Copyright © 2017年 zyc. All rights reserved.
//
#import "TRUMacros.h"
#import "TRUBaseViewController.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>
#import "xindunsdk.h"
#import <AVFoundation/AVFoundation.h>
#import "TRUUserAPI.h"
#import "TRUhttpManager.h"
#import "UIView+FrameExt.h"
//#import "UIViewController+LSNavigationController.h"
@interface TRUBaseViewController ()<UIAlertViewDelegate>
@property (nonatomic, assign) __block BOOL showed9019Error;
/** hud */
@property (nonatomic, weak) MBProgressHUD *hud;

@property (copy, nonatomic) NSString *cancelTitleStr;

@property (copy, nonatomic) NSString *comfirmTitleStr;

@property (strong, nonatomic) void(^alertComfirm)(void);

@property (strong, nonatomic) void(^alertCancel)(void);

@property (assign, nonatomic) BOOL isRight;//alert方向,YES时，右边是确定，左边是取消，NO时，左边确定，右边取消
//@property (nonatomic, strong) 

@property (nonatomic, assign) BOOL isCurrentPage;

@property (assign,nonatomic) NSTimeInterval lastTouchTime;
@property (assign,nonatomic) int clickAllTime;

@end

@implementation TRUBaseViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
    self.isCurrentPage = YES;
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIImage *shadowImage = [[UIImage alloc] init];
    
    self.view.clipsToBounds = YES;
    self.showed9019Error = NO;
//    self.isCurrentPage = YES;
    self.view.backgroundColor = RGBCOLOR(247, 249, 250);
    //黑线 (maybe change image)
    if (kDevice_Is_iPhoneX) {
        _linelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64 + 25, SCREENW, 1.f)];
    }else{
        _linelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, SCREENW, 1.f)];
    }
    _linelabel.backgroundColor = RGBCOLOR(180, 180, 180);
    [self.view addSubview:_linelabel];
    _linelabel.backgroundColor = [UIColor clearColor];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.isCurrentPage = NO;
}



- (void)showConfrimCancelDialogViewWithTitle:(NSString *)title msg:(NSString *)msg confrimTitle:(NSString *)confrimTitle cancelTitle:(NSString *)cancelTitle confirmRight:(BOOL)confirmRight confrimBolck:(void (^)())confrimBlock cancelBlock:(void (^)())cancelBlock{
    
    
    UIAlertController *alertVC =  [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:confrimTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        if (confrimBlock) {
            confrimBlock();
        }
    }];
    if (cancelTitle && cancelTitle.length > 0) {
        UIAlertAction *cancelAction =  [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock) {
                cancelBlock();
            }

        }];
        if (confirmRight) {
            [alertVC addAction:cancelAction];
            [alertVC addAction:confrimAction];
        }else{
            [alertVC addAction:confrimAction];
            [alertVC addAction:cancelAction];
        }
    }else{
        [alertVC addAction:confrimAction];
    }

    UIViewController *controler = !self.navigationController ? self : self.navigationController;

    if (controler.presentedViewController && [controler.presentedViewController isKindOfClass:[UIAlertController class]]) {
        [controler.presentedViewController dismissViewControllerAnimated:NO completion:^{
            [controler presentViewController:alertVC animated:YES completion:nil];
        }];
    }else{
        [controler presentViewController:alertVC animated:YES completion:nil];
    }
}



- (void)showConfrimCancelDialogAlertViewWithTitle:(NSString *)title msg:(NSString *)msg confrimTitle:(NSString *)confrimTitle cancelTitle:(NSString *)cancelTitle confirmRight:(BOOL)confirmRight confrimBolck:(void (^)())confrimBlock cancelBlock:(void (^)())cancelBlock{
//    self.alertCancel = nil;
//    self.alertComfirm = nil;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.alertComfirm = confrimBlock;
        strongSelf.alertCancel = cancelBlock;
        strongSelf.isRight = confirmRight;
        strongSelf.cancelTitleStr = cancelTitle;
        strongSelf.comfirmTitleStr = confrimTitle;
        UIAlertView *alert;
        if (confirmRight) {
            alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:strongSelf cancelButtonTitle:cancelTitle otherButtonTitles:confrimTitle, nil];
        }else{
            //        alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:confrimTitle otherButtonTitles:cancelTitle, nil];
            if (cancelTitle && cancelTitle.length>0) {
                alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:strongSelf cancelButtonTitle:confrimTitle otherButtonTitles:cancelTitle, nil];
            }else{
                alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:strongSelf cancelButtonTitle:confrimTitle otherButtonTitles:nil];
            }
        }
        if (strongSelf.isCurrentPage) {
            //        UIWindow *window = self.view.window;
            //        if ([[[UIApplication sharedApplication] windows] lastObject]==window) {
            //
            //        }
            [alert show];
        }
    });
    
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.isRight) {
        if (self.cancelTitleStr.length==0) {
            if (self.alertComfirm) {
                self.alertComfirm();
            }
        }else{
            switch (buttonIndex) {
                case 0:
                {
                    if (self.alertCancel) {
                        self.alertCancel();
                    }
                }
                    break;
                case 1:
                {
                    if (self.alertComfirm) {
                        self.alertComfirm();
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }else{
        switch (buttonIndex) {
            case 0:
            {
                if (self.alertComfirm) {
                    self.alertComfirm();
                }
            }
                break;
            case 1:
            {
                if (self.alertCancel) {
                    self.alertCancel();
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)back2UnActiveRootVC{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    id delegate = [UIApplication sharedApplication].delegate;
    
    if ([delegate respondsToSelector:@selector(changeAvtiveRootVC)]) {
        [delegate performSelector:@selector(changeAvtiveRootVC) withObject:nil];
    }
#pragma clang diagnostic pop
}
- (void)deal9008Error{
    
//    [TRUhttpManager cancelALLHttp];
    
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"密钥失效，请重新发起初始化" confrimTitle:@"确定" cancelTitle:nil confirmRight:NO confrimBolck:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        [xindunsdk deactivateUser:[TRUUserAPI getUser].userId];
        [TRUUserAPI deleteUser];
//        [xindunsdk deactivateAllUsers];
        [self back2UnActiveRootVC];
    } cancelBlock:nil];
}
- (void)deal9019Error{
    
    [self dele9019ErrorWithBlock:nil];
}
- (void)dele9019ErrorWithBlock:(void (^)())block{
    if (!self.showed9019Error) {
        __weak typeof(self) weakSelf = self;
        [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"当前账号已锁定，请与管理员联系" confrimTitle:@"确定" cancelTitle:nil confirmRight:NO confrimBolck:^{
            weakSelf.showed9019Error = NO;
            if (block) {
                block();
            }
        } cancelBlock:nil];
        self.showed9019Error = YES;
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    NSTimeInterval time = [self getNowTimeTimestamp];
    if (time - self.lastTouchTime <=0.5) {
        ++self.clickAllTime;
//        NSLog(@"clicktime = %d",self.clickAllTime);
        if (self.clickAllTime==7) {
            [self sendMail];
            self.clickAllTime = -100;
        }
    }else{
        self.clickAllTime = 1;
    }
    self.lastTouchTime = time;
}
//待审批
- (void)deal9021ErrorWithBlock:(void(^)())block{
    
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"您的账号申请已提交，请联系管理员审批。" confrimTitle:@"确定" cancelTitle:nil confirmRight:YES confrimBolck:^{
        if (block) block();
    } cancelBlock:nil];

}
//已提交
- (void)deal9022ErrorWithBlock:(void(^)())block{
    
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"您的账号申请已提交，管理员尚未审批通过，请勿重复提交。" confrimTitle:@"确定" cancelTitle:nil confirmRight:YES confrimBolck:^{
        
        if (block) block();
        
    } cancelBlock:nil];
}
//拒绝
- (void)deal9023ErrorWithBlock:(void(^)())block{
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"您的账号申请被拒绝，请联系管理员。" confrimTitle:@"确定" cancelTitle:nil confirmRight:YES confrimBolck:^{
        if (block) block();
    } cancelBlock:nil];
}
//设备已禁用
- (void)deal9025ErrorWithBlock:(void(^)())block{
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"您的账号已被禁用，请联系管理员。" confrimTitle:@"确定" cancelTitle:nil confirmRight:YES confrimBolck:^{
        if (block) block();
    } cancelBlock:nil];
}

//拒绝
- (void)deal9026ErrorWithBlock:(void(^)())block{
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"您绑定的设备数量已达上限，想要绑定该设备，请先删除一个已激活设备。" confrimTitle:@"确定" cancelTitle:nil confirmRight:YES confrimBolck:^{
        if (block) block();
    } cancelBlock:nil];
}

static const char TRUHUDKey = '\0';
- (MBProgressHUD *)hud{
    MBProgressHUD *hud = objc_getAssociatedObject(self, &TRUHUDKey);
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        objc_setAssociatedObject(self, &TRUHUDKey,
                                 hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        hud.margin = 10.0;
        hud.label.font = [UIFont boldSystemFontOfSize:14.0 * PointHeightRatio6];
        [self.view addSubview:hud];
    }
    return (MBProgressHUD*)hud;
}

- (void)showHudWithText:(NSString *)text{

    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = text;
    [self.hud showAnimated:YES];
    //    [self.hud hideAnimated:YES afterDelay:2.0];
}
- (void)showHudWithTitle:(NSString *)titel text:(NSString *)text{
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = titel;
    self.hud.detailsLabel.text = text;
    [self.hud showAnimated:YES];
    //    [self.hud hideAnimated:YES afterDelay:2.0];
    
}

- (void)showActivityWithText:(NSString *)text{
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = text;
    [self.hud showAnimated:YES];
}
- (void)hideHudDelay:(NSTimeInterval)delay{
    [self.hud hideAnimated:YES afterDelay:delay];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.view.y = 0;
    self.view.height = SCREENH;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    YCLog(@"%@ 界面消失",[self class]);
}

-(NSTimeInterval)getNowTimeTimestamp{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];

    NSTimeInterval a=[dat timeIntervalSince1970];

    return a;
}

- (void)dealloc{
    YCLog(@"%@ dealloc 内存释放",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

