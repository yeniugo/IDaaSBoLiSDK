//
//  TRUBaseViewController.h
//  Good_IdentifyAuthentication
//
//  Created by zyc on 2017/9/25.
//  Copyright © 2017年 zyc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRUBaseViewController : UIViewController

@property (nonatomic, strong) UILabel *linelabel;

@property (nonatomic,strong) UIButton *leftItemBtn;

- (void)showConfrimCancelDialogViewWithTitle:(NSString *)title msg:(NSString *)msg confrimTitle:(NSString *)confrimTitle cancelTitle:(NSString *)cancelTitle confirmRight:(BOOL)confirmRight confrimBolck:(void(^)())confrimBlock cancelBlock:(void(^)())cancelBlock;
- (void)showConfrimCancelDialogAlertViewWithTitle:(NSString *)title msg:(NSString *)msg confrimTitle:(NSString *)confrimTitle cancelTitle:(NSString *)cancelTitle confirmRight:(BOOL)confirmRight confrimBolck:(void (^)())confrimBlock cancelBlock:(void (^)())cancelBlock;
- (void)back2UnActiveRootVC;
- (void)deal9008Error;
- (void)deal9019Error;
- (void)dele9019ErrorWithBlock:(void(^)())block;
- (void)deal9021ErrorWithBlock:(void(^)())block;
- (void)deal9022ErrorWithBlock:(void(^)())block;
- (void)deal9023ErrorWithBlock:(void(^)())block;
- (void)deal9026ErrorWithBlock:(void(^)())block;
- (void)deal9025ErrorWithBlock:(void(^)())block;
- (void)showHudWithText:(NSString *)text;
- (void)showHudWithTitle:(NSString *)titel text:(NSString *)text;
- (void)showActivityWithText:(NSString *)text;
- (void)hideHudDelay:(NSTimeInterval)delay;

- (void)sendMail;

@end
