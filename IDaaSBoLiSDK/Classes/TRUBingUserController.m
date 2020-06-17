//
//  TRUBingUserController.m
//  Good_IdentifyAuthentication
//
//  Created by zyc on 2017/11/10.
//  Copyright © 2017年 zyc. All rights reserved.
//
#import "TRUBaseViewController.h"
#import "TRUBingUserController.h"
#import "NSString+Regular.h"
#import "NSString+Trim.h"
#import "xindunsdk.h"
#import "IDaaSBoLiFramework.h"
#import "TRUUserAPI.h"
//#import "TRUAddPersonalInfoViewController.h"
#import "TRUhttpManager.h"
#import "UIButton+Touch.h"
#import "YYModel.h"
#import "TRUMacros.h"
@interface TRUBingUserController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *iphoneEmialView;
@property (weak, nonatomic) IBOutlet UIView *numView;

@property (weak, nonatomic) IBOutlet UITextField *inputoneTF;

@property (weak, nonatomic) IBOutlet UITextField *inputphonemailTF;
@property (weak, nonatomic) IBOutlet UITextField *inputpasswordTF;//验证码
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIView *AccountbottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneemailTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verifySendTopContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verifyButtonTopContraint;
@property (weak, nonatomic) IBOutlet UILabel *showPhoneOrEmailLB;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, copy) NSString *loginStr;

@property (nonatomic,assign) BOOL multipleVerify;

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *token;
@end

@implementation TRUBingUserController
{
    BOOL isPhone;
    BOOL isEmail;
    BOOL isEmployee;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    [self hiddenWithfalsh:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定";
    isEmail = isPhone = isEmployee = NO;
    self.verifyBtn.backgroundColor = DefaultGreenColor;
    self.verifyBtn.layer.cornerRadius = 5;
    self.verifyBtn.layer.masksToBounds = YES;
    self.AccountbottomView.layer.cornerRadius = 5;
    self.AccountbottomView.layer.borderWidth = 1;
    self.AccountbottomView.layer.borderColor = RGBCOLOR(215, 215, 215).CGColor;
    self.numView.layer.cornerRadius = 5;
    self.numView.layer.borderWidth = 1;
    self.numView.layer.borderColor = RGBCOLOR(215, 215, 215).CGColor;
    self.iphoneEmialView.layer.cornerRadius = 5;
    self.iphoneEmialView.layer.borderWidth = 1;
    self.iphoneEmialView.layer.borderColor = RGBCOLOR(215, 215, 215).CGColor;
    self.inputoneTF.delegate = self;
    self.inputpasswordTF.delegate = self;
    self.inputphonemailTF.delegate = self;
    self.verifyBtn.timeInterval = 0.5;
    NSString *modeStr = [NSString stringWithFormat:@"%d",self.activeModel];
    if (1) {
        if ([modeStr isEqualToString:@"1"]) {//激活方式 激活方式(1:邮箱,2:手机,3:工号,4:工号密码加手机，5工号密码加邮箱)
            isEmail = YES;
            _inputoneTF.placeholder = @"请输入您的邮箱";
            _numView.hidden = YES;
            _sendBtn.hidden = NO;
            _iphoneEmialView.hidden = NO;
            self.activeModel = 1;
        }else if ([modeStr isEqualToString:@"2"]){
            isPhone = YES;
            _inputoneTF.placeholder = @"请输入您的手机号";
            _numView.hidden = YES;
            _sendBtn.hidden = NO;
            _iphoneEmialView.hidden = NO;
            self.activeModel = 2;
        }else if ([modeStr isEqualToString:@"3"]){
            isEmployee = YES;
            _inputoneTF.placeholder = @"请输入您的账号";
            _numView.hidden = NO;
            _sendBtn.hidden = YES;
            _iphoneEmialView.hidden = YES;
            self.activeModel = 3;
        }else if ([modeStr isEqualToString:@"4"]){
            isEmployee = YES;
            _inputoneTF.placeholder = @"请输入您的账号";
            _numView.hidden = NO;
            _sendBtn.hidden = YES;
            _iphoneEmialView.hidden = YES;
            self.activeModel = 4;
            self.phoneemailTopConstraint.constant = 140;
            self.verifySendTopContraint.constant = 140;
            self.verifyButtonTopContraint.constant = - 55;
        }else if ([modeStr isEqualToString:@"5"]){
            isEmployee = YES;
            _inputoneTF.placeholder = @"请输入您的账号";
            _numView.hidden = NO;
            _sendBtn.hidden = YES;
            _iphoneEmialView.hidden = YES;
            self.phoneemailTopConstraint.constant = 140;
            self.verifySendTopContraint.constant = 140;
            self.verifyButtonTopContraint.constant = - 55;
            self.activeModel = 5;
        }
        
    }else{
        [_inputoneTF addTarget:self action:@selector(valueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
    }
    _inputpasswordTF.secureTextEntry = YES;
    [_sendBtn setBackgroundColor:DefaultGreenColor];
    _sendBtn.layer.masksToBounds = YES;
    _sendBtn.layer.cornerRadius = 5.0;
#ifdef DEBUG
//    self.inputoneTF.text = @"1234";
//    self.inputpasswordTF.text = @"qwer1234";
#endif
    
}

- (void)resetUI{
    _inputoneTF.placeholder = @"请输入您的账号";
    _numView.hidden = NO;
    _sendBtn.hidden = YES;
    _iphoneEmialView.hidden = YES;
    self.inputoneTF.textColor = RGBCOLOR(0, 0, 0);
    self.inputpasswordTF.textColor = RGBCOLOR(0, 0, 0);
    self.phoneemailTopConstraint.constant = 140;
    self.verifySendTopContraint.constant = 140;
    self.verifyButtonTopContraint.constant = - 55;
    self.inputoneTF.text = nil;
    self.inputpasswordTF.text = nil;
    self.inputphonemailTF.text = nil;
    self.inputoneTF.userInteractionEnabled = YES;
    self.inputpasswordTF.userInteractionEnabled = YES;
    self.multipleVerify = NO;
    self.phone = nil;
    self.email = nil;
    self.token = nil;
    self.inputoneTF.enabled = YES;
    self.inputpasswordTF.enabled = YES;
    self.showPhoneOrEmailLB.text = @"";
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        switch (self.activeModel) {
            case 1:
            {
                if (textField == self.inputoneTF) {
                    [self.inputphonemailTF becomeFirstResponder];
                }else{
                    [self VerifyBtnClick:nil];
                }
            }
                break;
            case 2:
            {
                if (textField == self.inputoneTF) {
                    [self.inputphonemailTF becomeFirstResponder];
                }else{
                    [self VerifyBtnClick:nil];
                }
            }
                break;
            case 3:
            {
                if (textField == self.inputoneTF) {
                    [self.inputpasswordTF becomeFirstResponder];
                }else{
                    [self VerifyBtnClick:nil];
                }
            }
                break;
            case 4:
            {
                if (textField == self.inputoneTF) {
                    [self.inputpasswordTF becomeFirstResponder];
                }else if(textField == self.inputpasswordTF){
                    [self firstVerify];
                }else if(textField == self.inputphonemailTF){
                    [self VerifyBtnClick:nil];
                }
            }
                break;
            case 5:
            {
                if (textField == self.inputoneTF) {
                    [self.inputpasswordTF becomeFirstResponder];
                }else if(textField == self.inputpasswordTF){
                    [self firstVerify];
                }else if(textField == self.inputphonemailTF){
                    [self VerifyBtnClick:nil];
                }
            }
                break;
            default:
                break;
        }
        return YES; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}


-(void)valueChanged:(UITextField *)field{
    NSString *str = field.text;
    
    if ([str isPhone]) {
        isPhone = YES;
        isEmployee = NO;
        isEmail = NO;
        [self hiddenWithfalsh:1];
        
    }else if ([str isEmail]){
        isPhone = NO;
        isEmployee = NO;
        isEmail = YES;
        [self hiddenWithfalsh:1];
    }else{
        switch (self.activeModel) {
            case 3:
            {
                isPhone = NO;
                isEmployee = YES;
                isEmail = NO;
                [self hiddenWithfalsh:2];
            }
                break;
            case 4:
            {
                if (self.multipleVerify) {
                    isPhone = NO;
                    isEmployee = YES;
                    isEmail = NO;
                    [self hiddenWithfalsh:3];
                }else{
                    isPhone = NO;
                    isEmployee = YES;
                    isEmail = NO;
                    [self hiddenWithfalsh:2];
                }
            }
                break;
            case 5:
            {
                if (self.multipleVerify) {
                    isPhone = NO;
                    isEmployee = YES;
                    isEmail = NO;
                    [self hiddenWithfalsh:3];
                }else{
                    isPhone = NO;
                    isEmployee = YES;
                    isEmail = NO;
                    [self hiddenWithfalsh:2];
                }
            }
                break;
            default:
                break;
        }
        
    }
}

- (IBAction)eyeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    _inputpasswordTF.secureTextEntry = sender.selected;
}

#pragma mark -验证
- (IBAction)VerifyBtnClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_inputoneTF.text.trim.length == 0 && self.activeModel ==3) {
        [self showHudWithText:@"请输入正确的账号/验证码信息"];
        [self hideHudDelay:1.5f];
        return;
    }
    if (_inputpasswordTF.text.trim.length == 0 && isEmployee) {
        [self showHudWithText:@"请输入正确的账号/密码信息"];
        [self hideHudDelay:1.5f];
        return;
    }
    if (_inputphonemailTF.text.trim.length == 0 && isEmployee == NO) {
        [self showHudWithText:@"请输入正确的账号/验证码信息"];
        [self hideHudDelay:1.5f];
        return;
    }
    
    if (isEmail) {//邮箱验证
        [self verifyJpushId:@"email"];
    }
    if (isPhone) {//手机验证
        [self verifyJpushId:@"phone"];
    }
    if (isEmployee) {//员工号验证
        switch (self.activeModel) {
            case 3:
            {
                [self requestCodeForUserEmployeenum:_inputoneTF.text type:@"employeenum"];
            }
                break;
            case 4:
            {
                if (self.multipleVerify) {
                    if (self.inputphonemailTF.text.length==0) {
                        [self showHudWithText:@"请输入验证码信息"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    if (self.inputpasswordTF.text.length ==0) {
                        
                    }
                    if (self.phone.length==0) {
                        [self showHudWithText:@"请联系管理员补全手机号信息"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    [self verifyJpushId:@"employeenumPhone"];
                }else{
                    if (self.inputoneTF.text.length == 0) {
                        [self showHudWithText:@"请输入手机号"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    if (self.inputpasswordTF.text.length == 0) {
                        [self showHudWithText:@"请输入密码"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    [self firstVerify];
                }
            }
                break;
            case 5:
            {
                if (self.multipleVerify) {
                    if (self.inputphonemailTF.text.length==0) {
                        [self showHudWithText:@"请输入验证码信息"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    if (self.email.length==0) {
                        [self showHudWithText:@"请联系管理员补全邮箱信息"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    [self verifyJpushId:@"employeenumEmail"];
                }else{
                    if (self.inputoneTF.text.length == 0) {
                        [self showHudWithText:@"请输入邮箱"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    if (self.inputpasswordTF.text.length == 0) {
                        [self showHudWithText:@"请输入密码"];
                        [self hideHudDelay:1.5f];
                        return;
                    }
                    [self firstVerify];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)firstVerify{
    __weak typeof(self) weakSelf = self;
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushID = [stdDefaults objectForKey:@"TRUPUSHID"];
    if(pushID.length==0){
        pushID = @"1234567890";
    }
    NSString *type;
    switch (self.activeModel) {
        case 4:
        {
            type = @"employeenumPhone";
        }
            break;
        case 5:
        {
            type = @"employeenumEmail";
        }
            break;
        default:
            break;
    }
    NSString *singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%@\",\"type\":\"%@\",\"authcode\":\"%@\"", [self.inputoneTF.text.trim UTF8String],pushID, type,self.inputpasswordTF.text];
    NSString *para = [xindunsdk encryptBySkey:self.inputoneTF.text.trim ctx:singStr isType:YES];
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/checkUserInfo"] withParts:paramsDic onResult:^(int errorno, id responseBody) {
        if (errorno==0) {
            if (responseBody!=nil) {
                NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
                YCLog(@"dic = %@",dic);
                weakSelf.verifyButtonTopContraint.constant = 20;
                weakSelf.iphoneEmialView.hidden = NO;
                weakSelf.sendBtn.hidden = NO;
                weakSelf.showPhoneOrEmailLB.hidden = NO;
                weakSelf.multipleVerify = YES;
                [weakSelf.inputpasswordTF endEditing:YES];
                [weakSelf.inputoneTF endEditing:YES];
                weakSelf.inputpasswordTF.userInteractionEnabled = NO;
                weakSelf.inputoneTF.userInteractionEnabled = NO;
                weakSelf.inputphonemailTF.hidden = NO;
//                weakSelf.phoneCodelineView.hidden = NO;
                [weakSelf.inputphonemailTF becomeFirstResponder];
                weakSelf.inputoneTF.textColor = RGBCOLOR(153, 153, 153);
                weakSelf.inputpasswordTF.textColor = RGBCOLOR(153, 153, 153);
                dic = dic[@"resp"];
                weakSelf.phone = dic[@"phone"];
                weakSelf.token = dic[@"token"];
                weakSelf.email = dic[@"email"];
                if (weakSelf.activeModel==5) {
                    if (weakSelf.email.length==0) {
                        weakSelf.showPhoneOrEmailLB.text = [NSString stringWithFormat:@"邮箱： "];
                    }else if (weakSelf.phone.length==11){
                        weakSelf.showPhoneOrEmailLB.text = [NSString stringWithFormat:@"邮箱：%@",[weakSelf getEmailFromStr:weakSelf.email]];
                    }
                }else if (weakSelf.activeModel==4){
                    if (weakSelf.phone.length==0) {
                        weakSelf.showPhoneOrEmailLB.text = [NSString stringWithFormat:@"手机号： "];
                    }else if (weakSelf.phone.length==11){
                        weakSelf.showPhoneOrEmailLB.text = [NSString stringWithFormat:@"手机号： *** **** *%@",[weakSelf.phone substringFromIndex:8]];
                    }
                }
                [self sendCodeBtnClcik:nil];
            }
        }else if(errorno==-5004){
            [self showHudWithText:@"网络错误"];
            [self hideHudDelay:2.0];
        }else if (9019 == errorno){
            [weakSelf deal9019Error];
        }else if (9002 == errorno){
            [self showHudWithText:@"用户不存在"];
            [self hideHudDelay:2.0];
        }else if (9021 == errorno){
//            weakSelf.sendBtn.enabled = YES;
            //            [weakSelf startTimer];
            [weakSelf deal9021ErrorWithBlock:nil];
        }else if (9022 == errorno){
            [weakSelf deal9022ErrorWithBlock:nil];
        }else if (9023 == errorno){
            [weakSelf stopTimer];
            [weakSelf deal9023ErrorWithBlock:nil];
        }else if (9026 == errorno){
            [weakSelf stopTimer];
            [weakSelf deal9026ErrorWithBlock:nil];
        }else if (9036 == errorno){
            [weakSelf showHudWithText:@"前后台激活方式不一致"];
            [weakSelf hideHudDelay:2.0];
        }else{
            [self showHudWithText:@"用户名/密码错误"];
            [self hideHudDelay:2.0];
        }
    }];
}

- (NSString *)getEmailFromStr:(NSString *)str{
//    str = @"afasfdaf@fafa@abc.com";
    NSMutableArray *array = [self getRangeStr:str findText:@"@"];
    NSString *firstStr;
    NSString *lastStr;
    NSString *resultStr;
    if (array.count>0) {
        if ([array lastObject]>3) {
            firstStr = [str substringToIndex:3];
            lastStr = [str substringFromIndex:[[array lastObject] intValue]];
            resultStr = [NSString stringWithFormat:@"%@****%@",firstStr,lastStr];
        }else{
            resultStr = str;
        }
    }
    return resultStr;
}

- (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText
{
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:20];
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range
    if (rang.location != NSNotFound && rang.length != 0) {
        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中
        NSRange rang1 = {0,0};
        NSInteger location = 0;
        NSInteger length = 0;
        for (int i = 0;; i++)
        {
            if (0 == i) {//去掉这个xxx
                location = rang.location + rang.length;
                length = text.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            }else
            {
                location = rang1.location + rang1.length;
                length = text.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            //在一个range范围内查找另一个字符串的range
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            if (rang1.location == NSNotFound && rang1.length == 0) {
                break;
            }else//添加符合条件的location进数组
                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
        }
        return arrayRanges;
    }
    return nil;
}

-(void)verifyJpushId:(NSString *)type{
    NSString *activeNumber = _inputphonemailTF.text.alltrim;
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushID = [stdDefaults objectForKey:@"TRUPUSHID"];
    [self showHudWithText:@"正在激活..."];
//    if (self.activeModel == 4) {
//        activeNumber = self.phone;
//    }else if(self.activeModel == 5){
//        activeNumber = self.email;
//    }
    if (!pushID || pushID.length == 0) {//说明pushid获取失败
        if ([type isEqualToString:@"employeenum"]) {
            [self active4User:self.inputpasswordTF.text.trim pushID:@"1234567890" type:type];
        }else{
            [self active4User:activeNumber pushID:@"1234567890" type:type];
        }
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        [stdDefaults setObject:@"1234567890" forKey:@"TRUPUSHID"];
        [stdDefaults synchronize];
        //#endif
    }else{
        if ([type isEqualToString:@"employeenum"]) {
            [self active4User:self.inputpasswordTF.text.trim pushID:pushID type:type];
        }else{
            [self active4User:activeNumber pushID:pushID type:type];
        }
    }
}

- (IBAction)sendCodeBtnClcik:(UIButton *)sender {
    if (self.activeModel==4) {
        if (self.phone.length == 0) {
            [self showHudWithText:@"手机号不存在"];
            [self hideHudDelay:1.5f];
            return;
        }
        [self requestCodeForUser:self.phone type:@"employeenumPhone"];
        return;
    }
    if (self.activeModel==5) {
        if (self.email.length == 0) {
            [self showHudWithText:@"邮箱不存在"];
            [self hideHudDelay:1.5f];
            return;
        }
        [self requestCodeForUser:self.email type:@"employeenumEmail"];
        return;
    }
    if (_inputoneTF.text.trim.length == 0 && self.activeModel ==1){
        [self showHudWithText:@"请输入您的邮箱"];
        [self hideHudDelay:1.5f];
        return;
    }
    if (_inputoneTF.text.trim.length == 0 && self.activeModel ==2){
        [self showHudWithText:@"请输入您的手机号"];
        [self hideHudDelay:1.5f];
        return;
    }
    if (![_inputoneTF.text.trim isEmail] && self.activeModel == 1) {
        [self showHudWithText:@"请输入正确格式的邮箱账号"];
        [self hideHudDelay:1.5f];
        return;
    }
    if (![_inputoneTF.text.trim isPhone] && self.activeModel ==2) {
        [self showHudWithText:@"请输入正确格式的手机号"];
        [self hideHudDelay:1.5f];
        return;
    }
    switch (self.activeModel) {
        case 1:
        {
            if (![self.inputoneTF.text isEmail]) {
                [self showHudWithText:@"请输入正确的账号"];
                [self hideHudDelay:1.5f];
                return;
            }
        }
            break;
        case 2:
        {
            if (![self.inputoneTF.text isPhone]) {
                [self showHudWithText:@"请输入正确的账号"];
                [self hideHudDelay:1.5f];
                return;
            }
        }
            break;
        default:
            break;
    }
    NSString *str = _inputoneTF.text.trim;
    if ([str isPhone]) {//是手机号
        [self requestCodeForUser:str type:@"phone"];
    }else if ([str isEmail]){//是邮箱
        [self requestCodeForUser:str type:@"email"];
    }else{
        [self showHudWithText:@"请输入正确的账号"];
        [self hideHudDelay:1.5f];
        return;
    }
}

-(void)hiddenWithfalsh:(NSInteger)teger{
    if (teger == 0) {
        _numView.hidden = YES;
        _sendBtn.hidden = YES;
        _iphoneEmialView.hidden = YES;
    }else if (teger == 1){//输入的是手机号或者邮箱
        _numView.hidden = YES;
        _sendBtn.hidden = NO;
        _iphoneEmialView.hidden = NO;
    }else if (teger == 2){//输入的是员工号
        _numView.hidden = NO;
        _sendBtn.hidden = YES;
        _iphoneEmialView.hidden = YES;
    }else if (teger == 3){//二次验证，全开
        _numView.hidden = NO;
        _sendBtn.hidden = NO;
        _iphoneEmialView.hidden = NO;
    }
}
- (NSString *)toReadableJSONStringWithDic:(NSDictionary *)dic {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    if (data == nil) {
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    return string;
}
- (void)active4User:(NSString *)activeNumber pushID:(NSString *)pushID type:(NSString *)type{
    __weak typeof(self) weakSelf = self;
    NSString *singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%s\",\"type\":\"%s\",\"authcode\":\"%s\"", [self.inputoneTF.text.trim UTF8String],[pushID UTF8String], [type UTF8String],[activeNumber UTF8String]];
    NSString *para = [xindunsdk encryptBySkey:self.inputoneTF.text.trim ctx:singStr isType:YES];
    if (self.activeModel == 4) {
        singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%s\",\"type\":\"%s\",\"authcode\":\"%s\",\"token\":\"%s\"", [self.phone UTF8String],[pushID UTF8String], [type UTF8String],[activeNumber UTF8String],[self.token UTF8String]];
        para = [xindunsdk encryptBySkey:self.phone ctx:singStr isType:YES];
    }else if (self.activeModel ==5){
        singStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"pushid\":\"%s\",\"type\":\"%s\",\"authcode\":\"%s\",\"token\":\"%s\"", [self.email UTF8String],[pushID UTF8String], [type UTF8String],[activeNumber UTF8String],[self.token UTF8String]];
        para = [xindunsdk encryptBySkey:self.email ctx:singStr isType:YES];
    }
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/active"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message) {
        [weakSelf hideHudDelay:0.0];
//        errorno = 90041;
        NSDictionary *dic = [xindunsdk decodeServerResponse:responseBody];
        if (errorno == 0) {
            NSString *userId = nil;
            int err = [xindunsdk privateVerifyCIMSInitForUserNo:self.inputoneTF.text.trim response:dic[@"resp"] userId:&userId];
            
            if (err == 0) {
                //同步用户信息
                [weakSelf showHudWithText:@"正在激活"];
                NSString *paras = [xindunsdk encryptByUkey:userId ctx:nil signdata:nil isDeviceType:NO];
                NSDictionary *dictt = @{@"params" : [NSString stringWithFormat:@"%@",paras]};
//                NSString *baseUrl1 = @"http://192.168.1.150:8004";
                [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/getuserinfo"] withParts:dictt onResult:^(int errorno, id responseBody) {
                    [weakSelf hideHudDelay:0.0];
                    NSDictionary *dicc = nil;
                    if (errorno == 0 && responseBody) {
                        dicc = [xindunsdk decodeServerResponse:responseBody];
                        if ([dicc[@"code"] intValue] == 0) {
                            dicc = dicc[@"resp"];
                            //用户信息同步成功
                            TRUUserModel *model = [TRUUserModel yy_modelWithDictionary:dicc];
                            NSString *json = [self toReadableJSONStringWithDic:dicc];
                            model.userId = userId;
                            [TRUUserAPI saveUser:model];
                            
                            [self getUserTokenWithRefreshToken:^(NSString *token) {
                                [self getAuthToken:token];
                            } error:^(int errorCode, NSString *errorMsg) {
                                NSString *err = [NSString stringWithFormat:@"获取token失败,错误码是%d，错误信息%@",errorCode,errorMsg];
                                [self showHudWithText:err];
                                [self hideHudDelay:2.0];
                            }];
                        }
                    }
                }];
            }
        }else if(-5004 == errorno){
            [self showHudWithText:@"网络错误，请稍后重试"];
            [self hideHudDelay:2.0];
        }else if(9001 == errorno){
            if (self.activeModel == 3){
                [self showHudWithText:@"请输入正确的账号/密码"];
                [self hideHudDelay:2.0];
            }else{
                [self showHudWithText:@"请输入正确的账号/验证码"];
                [self hideHudDelay:2.0];
            }
        }else if(9002 == errorno){
            if([type isEqualToString:@"employeenum"]){
                [self showHudWithText:@"密码错误"];
                [self hideHudDelay:2.0];
            }
            if (self.activeModel==4 || self.activeModel==5) {
                [self showHudWithText:@"验证码错误"];
                [self hideHudDelay:2.0];
            }
        }else if (9019 == errorno){
            [self deal9019Error];
        }else if (9016 == errorno){
            [self showHudWithText:@"验证码失效"];
            [self hideHudDelay:2.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resetUI];
            });
        }else if(90041==errorno){
            [self showHudWithText:@"token失效"];
            [self hideHudDelay:2.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resetUI];
            });
            
        }else if (9036 == errorno){
            [weakSelf showHudWithText:@"前后台激活方式不一致"];
            [weakSelf hideHudDelay:2.0];
        }else{
            NSString *err = [NSString stringWithFormat:@"%@",message];
            [self showHudWithText:@"激活失败"];
            [self hideHudDelay:2.0];
        }
    }];
    
}

- (void)getAuthToken:(NSString *)token{
    
}


-(void)getUserToken:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
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

-(void)getUserTokenWithRefreshToken:(void (^)(NSString *token))success error:(void (^)(int errorCode, NSString *errorMsg))error{
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

#pragma mark -获取验证码
-(void)requestCodeForUser:(NSString *)user type:(NSString *)type{
    [self showHudWithText:@"正在申请激活码..."];
    __weak typeof(self) weakSelf = self;
    NSString *signStr = [NSString stringWithFormat:@",\"userno\":\"%@\",\"type\":\"%s\"}", self.inputoneTF.text, [type UTF8String]];
    NSString *para = [xindunsdk encryptBySkey:self.inputoneTF.text ctx:signStr isType:NO];
    if (self.activeModel == 4) {
        signStr = [NSString stringWithFormat:@",\"userno\":\"%@\",\"type\":\"%s\",\"token\":\"%s\"}", self.phone, [type UTF8String],[self.token UTF8String]];
        para = [xindunsdk encryptBySkey:self.inputoneTF.text.trim ctx:signStr isType:NO];
    }else if (self.activeModel ==5){
        signStr = [NSString stringWithFormat:@",\"userno\":\"%@\",\"type\":\"%s\",\"token\":\"%s\"}", self.email, [type UTF8String],[self.token UTF8String]];
        para = [xindunsdk encryptBySkey:self.email ctx:signStr isType:NO];
    }
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    YCLog(@"baseUrl = %@",baseUrl);
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/apply4active"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message) {
        [weakSelf hideHudDelay:0.0];
        if (0 == errorno) {
            YCLog(@"发送成功");
            //第一次申请 也就是第一次进入这个页面，开始倒计时
            [weakSelf showHudWithText:@"发送成功"];
            [weakSelf hideHudDelay:2.0];
            weakSelf.sendBtn.enabled = NO;
            [weakSelf startTimer];
            
        }else if (-5004 == errorno){
            if ([type isEqualToString:@"email"]) {
                [weakSelf showHudWithText:@"邮箱错误"];
                [weakSelf hideHudDelay:2.0];
            }else if([type isEqualToString:@"phone"]){
                [weakSelf showHudWithText:@"手机号错误"];
                [weakSelf hideHudDelay:2.0];
            }
        }else if (9001 == errorno){
            if ([type isEqualToString:@"email"]) {
                [weakSelf showHudWithText:@"请输入正确的账号信息"];
                [weakSelf hideHudDelay:2.0];
            }else if([type isEqualToString:@"phone"]){
                [weakSelf showHudWithText:@"请输入正确的账号信息"];
                [weakSelf hideHudDelay:2.0];
            }else{
                if (self.activeModel == 4) {
                    [weakSelf showHudWithText:@"请输入正确的账号信息"];
                    [weakSelf hideHudDelay:2.0];
                }else if (self.activeModel ==5 ){
                    [weakSelf showHudWithText:@"请输入正确的账号信息"];
                    [weakSelf hideHudDelay:2.0];
                }
            }
        }else if (9002 == errorno){
            if ([type isEqualToString:@"email"]) {
                [weakSelf showHudWithText:@"请输入正确的账号信息"];
                [weakSelf hideHudDelay:2.0];
            }else if([type isEqualToString:@"phone"]){
                [weakSelf showHudWithText:@"请输入正确的账号信息"];
                [weakSelf hideHudDelay:2.0];
            }else{
                if (self.activeModel == 4) {
                    [weakSelf showHudWithText:@"请输入正确的账号信息"];
                    [weakSelf hideHudDelay:2.0];
                }else if (self.activeModel ==5 ){
                    [weakSelf showHudWithText:@"请输入正确的账号信息"];
                    [weakSelf hideHudDelay:2.0];
                }
            }
        }else if (9019 == errorno){
            [weakSelf deal9019Error];
        }else if (9021 == errorno){
            weakSelf.sendBtn.enabled = NO;
            [weakSelf startTimer];
            [weakSelf deal9021ErrorWithBlock:nil];
        }else if (9022 == errorno){
            [weakSelf deal9022ErrorWithBlock:nil];
        }else if (9023 == errorno){
            [weakSelf stopTimer];
            [weakSelf deal9023ErrorWithBlock:nil];
        }else if (9026 == errorno){
            [weakSelf stopTimer];
            [weakSelf deal9026ErrorWithBlock:nil];
        }else if(90041==errorno){
            [self showHudWithText:@"token失效"];
            [self hideHudDelay:2.0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resetUI];
            });
        }else if (90044 == errorno){
            [weakSelf showHudWithText:@"稍后再重试发送验证码"];
            [weakSelf hideHudDelay:2.0];
        }else if (9036 == errorno){
            [weakSelf showHudWithText:@"前后台激活方式不一致"];
            [weakSelf hideHudDelay:2.0];
        }else{
            NSString *err = [NSString stringWithFormat:@"其他错误（%d）",errorno];
            [weakSelf showHudWithText:@"激活失败"];
            [weakSelf hideHudDelay:2.0];
        }
    }];
}

-(void)requestCodeForUserEmployeenum:(NSString *)user type:(NSString *)type{
    [self showHudWithText:@"正在申请激活..."];
    __weak typeof(self) weakSelf = self;
    NSString *signStr = [NSString stringWithFormat:@",\"userno\":\"%s\",\"type\":\"%s\"}", [self.inputoneTF.text.trim UTF8String], [type UTF8String]];
    NSString *para = [xindunsdk encryptBySkey:self.inputoneTF.text.trim ctx:signStr isType:NO];
    NSDictionary *paramsDic = @{@"params" : para};
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"CIMSURL"];
    [TRUhttpManager sendCIMSRequestWithUrl:[baseUrl stringByAppendingString:@"/mapi/01/init/apply4active"] withParts:paramsDic onResultWithMessage:^(int errorno, id responseBody, NSString *message) {
        [self hideHudDelay:0.0];
        if (0 == errorno) {
            YCLog(@"发送成功");
            //第一次申请 也就是第一次进入这个页面，开始倒计时
            [weakSelf verifyJpushId:@"employeenum"];
            
        }else if (-5004 == errorno){
            [weakSelf showHudWithText:@"网络错误，请稍后重试"];
            [weakSelf hideHudDelay:2.0];
        }else if (9001 == errorno){
            [weakSelf showHudWithText:@"请输入正确的账号/密码"];
            [weakSelf hideHudDelay:2.0];
        }else if (9002 == errorno){
            [weakSelf showHudWithText:@"账号或密码不正确"];
            [weakSelf hideHudDelay:2.0];
        }else if (9019 == errorno){
            [weakSelf deal9019Error];
        }else if (9021 == errorno){
            weakSelf.sendBtn.enabled = NO;
            [weakSelf startTimer];
            [weakSelf deal9021ErrorWithBlock:nil];
        }else if (9022 == errorno){
            [weakSelf deal9022ErrorWithBlock:nil];
        }else if (9023 == errorno){
            [weakSelf stopTimer];
            [weakSelf deal9023ErrorWithBlock:nil];
        }else if (9026 == errorno){
            [weakSelf stopTimer];
            [weakSelf deal9026ErrorWithBlock:nil];
        }else if (9036 == errorno){
            [weakSelf showHudWithText:@"前后台激活方式不一致"];
            [weakSelf hideHudDelay:2.0];
        }else{
            NSString *err = [NSString stringWithFormat:@"其他错误（%d）",errorno];
            [weakSelf showHudWithText:@"激活失败"];
            [weakSelf hideHudDelay:2.0];
        }
    }];
    
}


- (void)startTimer{
    
    __weak typeof(self) weakSelf = self;
    [weakSelf stopTimer];
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:weakSelf selector:@selector(startButtonCount) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.timer = timer;
    [timer fire];
    
}
- (void)stopTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        totalTime = 60;
    }
    
}
static int totalTime = 60;
- (void)startButtonCount{
    
    if (totalTime >= 1) {
        totalTime -- ;
        NSString *leftTitle  = [NSString stringWithFormat:@"已发送(%ds)",totalTime];
        [self.sendBtn setTitle:leftTitle forState:UIControlStateNormal];
    }else{
        totalTime = 60;
        [self.sendBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        self.sendBtn.enabled = YES;
        [self stopTimer];
    }
    
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopTimer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 用户协议 UserAgreement


@end
