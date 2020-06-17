//
//  TRUPushingViewController.m
//  Good_IdentifyAuthentication
//
//  Created by hukai on 2018/10/30.
//  Copyright © 2018年 zyc. All rights reserved.
//

#import "TRUPushingViewController.h"
#import "xindunsdk.h"
#import "TRUAuthModel.h"
#import "TRUUserAPI.h"
#import "TRUhttpManager.h"
#import "TRUMacros.h"

@interface TRUPushingViewController ()

/// 右1
@property (weak, nonatomic) IBOutlet UILabel *accountLB;
/// 右2
@property (weak, nonatomic) IBOutlet UILabel *ipLB;
/// 右3
@property (weak, nonatomic) IBOutlet UILabel *localLB;
/// 右4
@property (weak, nonatomic) IBOutlet UILabel *TimeLB;
@property (weak, nonatomic) IBOutlet UILabel *titleAuthLB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmButtonTopConstraint;//确认按钮到登录信息的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logLBTopConstraint;//登录账户距离顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logLBLeftConstraint;//"登录账户"按钮左边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logDetailsLBRightConstraint;//『登录账户』内容详情右边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigTitleTopConstraint;//"您正在通过**登录"到顶部边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logLBTopToBigTitleConstraint;//登录账户距离主标题的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineConstraint;
@property (weak, nonatomic) IBOutlet UIButton *pushOKBtn;

@property (weak, nonatomic) NSTimer *pushTimer;

@property (weak, nonatomic) IBOutlet UILabel *firstLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *secondLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *thirdLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *fourthLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *fifthLeftLB;
@property (weak, nonatomic) IBOutlet UILabel *fifthRightLB;

@end

@implementation TRUPushingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self customUI];
    if (self.pushModel) {
        [self commonInit];
    }else{
        [self requestPushModelFromServerWithToken:self.token];
    }
    
    
}


- (void)setPushModel:(TRUPushAuthModel *)pushModel{
    _pushModel = pushModel;
}

#pragma mark 从服务器获取push模型
- (void)requestPushModelFromServerWithToken:(NSString *)stoken{
    
    [self showActivityWithText:@""];
    [xindunsdk getCIMSUUID:self.userNo];
    self.userNo = [TRUUserAPI getUser].userId;
    __weak typeof(self) weakSelf = self;
    if (self.userNo) {
        NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
        NSString *sign = stoken == nil ? @"" : stoken;
        NSArray *ctxx = @[@"token",sign];
        NSString *para = [xindunsdk encryptByUkey:self.userNo ctx:ctxx signdata:sign isDeviceType:YES];
        NSDictionary *paramsDic = @{@"params" : para};
        [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/push/fetch"] withParts:paramsDic onResult:^(int errorno, id responseBody){
//        [xindunsdk getCIMSPushFetchForUser:self.userNo stoken:stoken onResult:^(int errorno, id responseBody) {
            [weakSelf hideHudDelay:0.0];
            NSLog(@"-Push->%d-->%@",errorno,responseBody);
            NSDictionary *dic = nil;
            if (errorno == 0 && responseBody) {
                dic = [xindunsdk decodeServerResponse:responseBody];
                if ([dic[@"code"] intValue] == 0) {
                    dic = dic[@"resp"];
                    TRUPushAuthModel *model = [TRUPushAuthModel modelWithDic:dic];
                    model.token = stoken;
                    weakSelf.pushModel = model;
                    [weakSelf commonInit];
                }
            }else if (9008 == errorno){
                [weakSelf deal9008Error];
            }else if (9019 == errorno){
//                [weakSelf deal9019Error];
                [weakSelf dele9019ErrorWithBlock:^{
                    [weakSelf dismissVC:0];
                }];
            }else if (-5004 == errorno){
                [weakSelf showHudWithText:@"网络错误 请稍后重试"];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:)  withObject:@"0" afterDelay:2.0];
            }else{
                NSString *err = [NSString stringWithFormat:@"其他错误（%d）and%@",errorno,stoken];
                [weakSelf showHudWithText:err];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.0];
            }
        }];
        
    }
}


- (void)commonInit{
    
    switch (self.pushModel.displayFields.count) {
        case 0:
        {
            self.titleAuthLB.text = [NSString stringWithFormat:@"您正在登录【%@】",self.pushModel.appname];
            self.firstLeftLB.text = @"登录账号";
            self.accountLB.text = self.pushModel.username;
            self.secondLeftLB.text = @"ip地址";
            self.ipLB.text = self.pushModel.ip;
            self.thirdLeftLB.text = @"登录地址";
            self.localLB.text = self.pushModel.location;
            self.fourthLeftLB.text = @"登录时间";
            self.TimeLB.text = self.pushModel.dateTime;
        }
            break;
        case 4:
        {
            [self startCounter];
            for (int i = 0; i<4; i++) {
                if (1) {
                    switch (i) {
                        case 0:
                        {
                            self.firstLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.accountLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 1:
                        {
                            self.secondLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.ipLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 2:
                        {
                            self.thirdLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.localLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 3:
                        {
                            self.fourthLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.TimeLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 4:
                        {
                            self.fifthLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.fifthRightLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        default:
                            break;
                    }
                }
                
            }
            self.titleAuthLB.text = [NSString stringWithFormat:@"您正在登录【%@】",self.pushModel.appname];
            NSString *userName = self.pushModel.username;
            if (!userName || userName.length == 0) {
                TRUUserModel *model = [TRUUserAPI getUser];
                if (model.phone.length>0) {
                    userName = model.phone;
                }else if (model.email.length>0){
                    userName = model.email;
                }else if (model.employeenum.length>0){
                    userName = model.employeenum;
                }
            }
            self.accountLB.text = userName;
            
        }
            break;
        case 5:
        {
            self.titleAuthLB.text = [NSString stringWithFormat:@"您正在登录【%@】",self.pushModel.appname];
            for (int i = 0; i<5; i++) {
                if (1) {
                    switch (i) {
                        case 0:
                        {
                            self.firstLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.accountLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 1:
                        {
                            self.secondLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.ipLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 2:
                        {
                            self.thirdLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.localLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 3:
                        {
                            self.fourthLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.TimeLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        case 4:
                        {
                            self.fifthLeftLB.text = self.pushModel.displayFields[i][@"displayName"];
                            self.fifthRightLB.text = self.pushModel.displayFields[i][@"value"];
                        }
                            break;
                        default:
                            break;
                    }
                }
                
            }
        }
        default:
            break;
    }
    
    
}

- (IBAction)backBtnClick:(UIButton *)sender {
    
}

- (IBAction)cancleBtnClick:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    NSString *authtype = self.pushModel.authtype;
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
//    [self showHudWithText:@""];
    NSString *user = [TRUUserAPI getUser].userId;
    NSString *userStr;
    if (self.userNo.length) {
        userStr = self.userNo;
    }else{
        userStr = user;
    }
    NSString *sign = [NSString stringWithFormat:@"%@%@%@", self.pushModel.token,@"2",userStr];
    NSArray *ctxx = @[@"token",self.pushModel.token,@"confirm",@"2",@"userid",userStr];
    NSString *para = [xindunsdk encryptByUkey:user ctx:ctxx signdata:sign isDeviceType:NO];
    NSDictionary *paramsDic = @{@"params" : para};
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/verify/checktoken"] withParts:paramsDic onResult:^(int errorno, id responseBody) {
//        [weakSelf hideHudDelay:0.0];
        if (errorno == 0) {
            //结束后调用动画
            [weakSelf post3DataNoti];
            [weakSelf dismissVC:@"0"];
        }else if (9002 == errorno){
            [weakSelf showHudWithText:@"已验证"];
            [weakSelf hideHudDelay:2.0];
            [weakSelf performSelector:@selector(dismissVC:)  withObject:@"0" afterDelay:2.5];
        }else if (9008 == errorno){
            [weakSelf deal9008Error];
        }else if (9010 == errorno){
            if ([authtype isEqualToString:@"10"]) {
                [weakSelf show9010Error];
            }else{
                [weakSelf showHudWithText:@"登录失败，系统没有认证"];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
            }
        }else if (9019 == errorno){
            [weakSelf deal9019Error];
        }else{
            NSString *err = [NSString stringWithFormat:@"授权错误（%d）",errorno];
            [weakSelf showHudWithText:err];
            [weakSelf hideHudDelay:2.0];
            [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
        }
    }];
}
//音频或者人脸
- (void)authTimeOut{
    __weak typeof(self) weakSelf = self;
    NSString *authtype = self.pushModel.authtype;
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
//    [self showHudWithText:@""];
    NSString *user = [TRUUserAPI getUser].userId;
    NSString *sign = [NSString stringWithFormat:@"%@%@%@", self.pushModel.token,@"4",user];
    NSArray *ctxx = @[@"token",self.pushModel.token,@"confirm",@"4",@"userid",user];
    NSString *para = [xindunsdk encryptByUkey:user ctx:ctxx signdata:sign isDeviceType:NO];
    NSDictionary *paramsDic = @{@"params" : para};
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/verify/checktoken"] withParts:paramsDic onResult:^(int errorno, id responseBody) {
//        [weakSelf hideHudDelay:0.0];
        if (errorno == 0) {
            
        }else if (9002 == errorno){
            [weakSelf showHudWithText:@"已验证"];
            [weakSelf hideHudDelay:2.0];
            [weakSelf performSelector:@selector(dismissVC:)  withObject:@"0" afterDelay:2.5];
        }else if (9008 == errorno){
            [weakSelf deal9008Error];
        }else if (9010 == errorno){
            if ([authtype isEqualToString:@"10"]) {
                [weakSelf show9010Error];
            }else{
                [weakSelf showHudWithText:@"登录失败，系统没有认证"];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
            }
        }else if (9019 == errorno){
            [weakSelf deal9019Error];
        }else{
            NSString *err = [NSString stringWithFormat:@"授权错误（%d）",errorno];
            [weakSelf showHudWithText:err];
            [weakSelf hideHudDelay:2.0];
            [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
        }
    }];
}
- (IBAction)confirm:(id)sender {
    [self downBtnDone];
    
}

//同意允许登录
-(void)downBtnDone{
    __weak typeof(self) weakSelf = self;
    NSString *facestr = [TRUUserAPI getUser].faceinfo;
    BOOL isInitFace;
    if ([facestr isEqualToString:@"0"]) {
        isInitFace = NO;
    }else{
        isInitFace = YES;
    }
    NSString *authtype = self.pushModel.authtype;
    //    YCLog(@"----->%@",authtype);
    
    if ([authtype containsString:@"&"]) {//多重认证
        NSArray * arr = [authtype componentsSeparatedByString:@"&"];
        if (arr.count >0) {
            
        }
    }
    if ([authtype containsString:@"|"]) {
        
    }
    
    //认证类型为 一键认证:1 声纹:7 人脸:6
    if ([authtype isEqualToString:@"1"] || [authtype isEqualToString:@"0"] || [authtype isEqualToString:@"10"]) {
        [self.pushTimer invalidate];
        self.pushTimer = nil;
        __weak typeof(self) weakSelf = self;
        NSString *authtype = self.pushModel.authtype;
        NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
//        [self showHudWithText:@""];
        NSString *user = [TRUUserAPI getUser].userId;
        NSString *userStr;
        if (self.userNo.length) {
            userStr = self.userNo;
        }else{
            userStr = user;
        }
        NSString *sign = [NSString stringWithFormat:@"%@%@%@", self.pushModel.token,@"1",userStr];
        NSArray *ctxx = @[@"token",self.pushModel.token,@"confirm",@"1",@"userid",userStr];
        NSString *userId = [TRUUserAPI getUser].userId;
        NSString *para = [xindunsdk encryptByUkey:userId ctx:ctxx signdata:sign isDeviceType:NO];
        NSDictionary *paramsDic = @{@"params" : para};
        [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/verify/checktoken"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody,NSString *message) {
//            [weakSelf hideHudDelay:0.0];
            if (errorno == 0) {
                //结束后调用动画
                [weakSelf post3DataNoti];
                [weakSelf performSelector:@selector(dismissVC:) withObject:@"1" afterDelay:0.5];
            }else if (9002 == errorno){
                [weakSelf showHudWithText:@"信息已失效"];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:)  withObject:@"0" afterDelay:2.5];
            }else if (9008 == errorno){
                [weakSelf deal9008Error];
            }else if (9010 == errorno){
                
                if ([authtype isEqualToString:@"10"]) {
                    [weakSelf show9010Error];
                }else{
                    [weakSelf showHudWithText:@"登录失败，系统没有认证"];
                    [weakSelf hideHudDelay:2.0];
                    [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
                }
                
            }else if (9019 == errorno){
                [weakSelf deal9019Error];
                
            }else if (9033 == errorno){
                [weakSelf showHudWithText:message];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
            }else{
                NSString *err = [NSString stringWithFormat:@"获取验证请求失败，请稍后重试（%d）",errorno];
                [weakSelf showHudWithText:err];
                [weakSelf hideHudDelay:2.0];
                [weakSelf performSelector:@selector(dismissVC:) withObject:@"0" afterDelay:2.5];
            }
        }];
        
    }else if ([self.pushModel.authtype isEqualToString:@"6"] || [self.pushModel.authtype isEqualToString:@"7"]){//人脸
        [self.pushTimer invalidate];
        self.pushTimer = nil;
        __weak typeof(self) weakSelf = self;
        NSString *token = self.pushModel.token;
        
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"OAuthVerify"];
        if (str.length > 0 && [str isEqualToString:@"yes"]) {//第三方认证
            
        }else{
            
        }
        
    }
}

- (void)post3DataNoti{
    
}
- (void)dismissVC:(NSString *)confrim{
    [self.pushTimer invalidate];
    self.pushTimer = nil;
//    [self.navigationController popViewControllerAnimated:YES];
//    [HAMLogOutputWindow printLog:@"popViewControllerAnimated"];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (self.dismissBlock) {
        BOOL res = [confrim isEqualToString:@"1"] ? YES : NO;
        self.dismissBlock(res);
    }
    
}


- (void)startCounter{
    
    pushCount = self.pushModel.ttl;
    if (pushCount == 0) pushCount = 0;
    __weak typeof(self) weakSelf = self;
    if (!self.pushTimer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:weakSelf selector:@selector(timeselector) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [timer fire];
        self.pushTimer = timer;
    }
    
}
static NSInteger pushCount = 0;
-(void)timeselector{
    pushCount --;
    if (pushCount <= 0) {
        [self.pushTimer invalidate];
        self.pushTimer = nil;
        [self showTimeoutTip];
    }
}

- (void)show9010Error{
    
    [self showConfrimCancelDialogAlertViewWithTitle:@"" msg:@"该应用还未激活，无法完成认证操作，请返回原APP或完成应用激活" confrimTitle:@"激活应用" cancelTitle:@"返回" confirmRight:YES confrimBolck:^{
        
        
    } cancelBlock:^{
        [self dismissVC:@"0"];
    }];
}
- (void)showTimeoutTip{
    __weak typeof(self) weakSelf = self;
    [self showConfrimCancelDialogAlertViewWithTitle:@"请求超时" msg:@"由于您的认证请求已超时，善认无法确认您的身份，请重新发起认证请求" confrimTitle:@"OK" cancelTitle:nil confirmRight:NO confrimBolck:^{
        [weakSelf authTimeOut];
        [weakSelf post3DataNoti];
        [weakSelf dismissVC:nil];
    } cancelBlock:nil];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.pushTimer invalidate];
    self.pushTimer = nil;
    self.navigationController.navigationBar.hidden = NO;
    YCLog(@"TRUPushingViewController viewWillDisappear");
}

-(void)customUI{
    self.linelabel.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.pushOKBtn.backgroundColor = DefaultGreenColor;
    self.pushOKBtn.layer.cornerRadius = 55.0;
    self.pushOKBtn.layer.masksToBounds = YES;
    self.bigTitleTopConstraint.constant = 118*PointHeightPointRatio6;
    if(IS_IPHONE_5||IS_IPHONE_4_OR_LESS){
        self.confirmButtonTopConstraint.constant = 10;
        self.logLBLeftConstraint.constant = 20;
        self.logDetailsLBRightConstraint.constant = 20;
        self.underlineConstraint.constant = 20;
    }
    if(IS_IPHONE_4_OR_LESS){
        self.logLBTopConstraint.constant = 120;
        self.logLBTopToBigTitleConstraint.constant = 10;
        self.underlineConstraint.constant = 10;
    }

    
}



-(NSString*)getCurrentTimes{
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    return currentDateStr;
}

//比较两个日期大小
-(int)compareDate:(NSString*)startDate withDate:(NSString*)endDate{
    
    int comparisonResult;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] init];
    date1 = [formatter dateFromString:startDate];
    date2 = [formatter dateFromString:endDate];
    NSComparisonResult result = [date1 compare:date2];
    //    NSLog(@"result==%ld",(long)result);
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending:
            comparisonResult = 1;
            break;
            //date02比date01小
        case NSOrderedDescending:
            comparisonResult = -1;
            break;
            //date02=date01
        case NSOrderedSame:
            comparisonResult = 0;
            break;
        default:
            //NSLog(@"erorr dates %@, %@", date1, date2);
            break;
    }
    return comparisonResult;
}

@end
