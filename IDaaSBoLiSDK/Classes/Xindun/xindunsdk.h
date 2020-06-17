//
//  xindunsdk.h
//  xindunsdk
//
//  Created by zaifangwang on 2015/11/26.
//  Copyright © 2015年 product. All rights reserved.
//

/*****   API使用说明
0. 设置芯盾服务器部署地址：initEnv

1. 检查用户是否已经激活：isUserActivitated(userid)
    userid：必选参数。在应用内唯一标识该用户的字符串，在芯盾SDK内使用此串标识用户。
        可以是对帐号进行Hash+salt的结果。
        【仅支持字母和数字的组合】

2. 如果用户未激活，需要走通过语音验证码激活用户的流程：
      - 提醒用户，继续操作将收到电话语音播报的4位数字验证码；
      - 调用requestVoiceCaptchaForUser 申请电话语音验证码：需要传入userid和用户已经绑定的手机号
      - 用户输入验证码以后，调用verifyVoiceCaptchaForUser 进行校验，校验通过则用户在本设备上变成已激活状态。

3. 用户已经激活以后，可以调用解密短信验证码、加密明文验证码的接口
**/

/** 错误码定义
 ---SDK定义的错误码
 0 //操作成功
 -1 //操作失败
 -5000  // SDK未授权
 -5001 // 参数错误
 -5002 // 内存不足
 -5003 // 重复初始化
 -5004 // 网络错误
 
 ---服务器返回的错误码
 9002 // 需要轮询检查服务器状态
 
 */

/**
 * Update Logs:
  - 2016-08-01: 支持U盾、人脸、上行短信初始化方式；支持风控开关。
  - 2016-03-03: 增加云平台获取SID支持；接口增加APP_SECRET字段，增强APP校验
  - 2015-12-17: 增加修改服务器部署地址的接口。
  - 2015-11-27: 去除无用函数声明
 *
 */


#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,XDAlgoType){
    XDAlgoTypeOpenSSL = 0,     //OPENSSL
    XDAlgoTypeSM= 1        //国密
};

typedef NS_OPTIONS(NSUInteger, XDDeviceFilter){
    XDDeviceFilterNone = 0,       //不过滤
    XDDeviceFilterWeb = 1,        //过滤web
    XDDeviceFilterSensor = 2,     //过滤传感器
    XDDeviceFilterDynamic = 4,    //过滤动态信息
    XDDeviceFilterStatic = 8,     //过滤静态信息
    XDDeviceFilterAPPInfo = 16    //过滤APPInfo
};
//nano信息过滤标识
static XDDeviceFilter nano_filter = XDDeviceFilterWeb | XDDeviceFilterSensor | XDDeviceFilterDynamic | XDDeviceFilterStatic | XDDeviceFilterAPPInfo;
//small信息过滤标识
static XDDeviceFilter default_filter = XDDeviceFilterWeb | XDDeviceFilterSensor;
//全量信息过滤标识
static XDDeviceFilter none_filter = XDDeviceFilterNone;




@interface xindunsdk : NSObject

#pragma mark 重新整理的SDK（集成最新设备信息、设备指纹代码，通过参数配置设备信息采集内容、是否采集web、web是否从线上html获取，国密、openssl切换）

/**
 * 初始化SDK运行环境(非直连)
 @param appId              芯盾为客户应用服务器分配的APPID
 @param algoType           加密类型，XDAlgoTypeOpenSSL：OPENSSL，XDAlgoTypeSM：国密
 @param enableOnLineDevfp  是否启用在线设备指纹
 @param url                设备指纹地址
 @return 初始化SDK运行环境结果
 */
+ (BOOL)initEnv:(NSString *)appId algoType:(XDAlgoType)algoType enableOnLineDevfp:(BOOL)enableOnLineDevfp url:(NSString *)url;

/**
 * 初始化SDK运行环境(直连)
 @param appId              芯盾为客户应用服务器分配的APPID
 @param algoType           加密类型，XDAlgoTypeOpenSSL：OPENSSL，XDAlgoTypeSM：国密
 @param baseUrl            芯盾服务地址
 @return 初始化SDK运行环境结果
 */
+ (BOOL)initEnv:(NSString *)appId algoType:(XDAlgoType)algoType baseUrl:(NSString *)baseUrl;


/**
 *  初始化状态检查
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return           YES：已经初始化 NO：未初始化
 */
+ (BOOL)isUserInitialized:(NSString *)userId;


/**
 *  清除初始化状态
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return           0：清除成功 其他：错误码
 */
+ (int)deactivateUser:(NSString *)userId;

/**
 * 获取设备信息
 @param deviceFilter   过滤标识，默认取全部信息
 @return NSDictionary，{"status" : 0, "deviceInfo" : {}}
 */
+ (NSDictionary *)getDeviceInfo:(XDDeviceFilter)deviceFilter;

/**
 * 获取SDK信息
 
 @param userid 芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应。此接口如果不传，ukid返回空字符串
 @return NSDictionary，{"status" : 0, "info" : {}}
 */
+ (NSDictionary *)getSDKInfo:(NSString *)userid;

/**
 *  非直连初始化（一次认证）：获取初始化请求token
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return           status对应的返回码，tokena对应的tokena字符串
 */
+ (NSDictionary *)initByServerTokenGetTokenA:(NSString *)userId;
/**
 *  非直连初始化（一次认证）：获取初始化请求token
 *  @param userId           芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param deviceFilter     设备信息过滤标识
 *  @return                 status对应的返回码，tokena对应的tokena字符串
 */
+ (NSDictionary *)initByServerTokenGetTokenA:(NSString *)userId deviceFilter:(XDDeviceFilter)deviceFilter;

/**
 *  非直连初始化（一次认证）：完成用户初始化
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param tokenB     服务器返回的密钥派生因子密文
 *  @return           status对应的返回码
 */
+ (NSDictionary *)initByServerTokenFinish:(NSString *)userId tokenB:(NSString *)tokenB;


/**
 *  非直连初始化（二次认证）：获取初始化请求token
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return           status对应的返回码，sid对应的sid字符串
 */
+ (NSDictionary *)initByAuthcodeGetRequestToken:(NSString *)userId;

/**
 *  非直连初始化（二次认证）：获取初始化请求token
 *  @param userId            芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param deviceFilter      设备信息过滤标识
 *  @return                  status对应的返回码，sid对应的sid字符串
 */
+ (NSDictionary *)initByAuthcodeGetRequestToken:(NSString *)userId deviceFilter:(XDDeviceFilter)deviceFilter;

/**
 *  非直连初始化（二次认证）：获取初始化验证token
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param captcha    用户提供的语音验证码，或者应用自动获取的captcha
 *  @return           status对应的返回码，sid对应的sid字符串
 */
+ (NSDictionary *)initByAuthcodeGetVerificationToken:(NSString *)userId captcha:(NSString *) captcha;

/**
 *  非直连初始化（二次认证）：获取初始化验证token
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param captcha    用户提供的语音验证码，或者应用自动获取的captcha
 *  @param deviceFilter      设备信息过滤标识
 *  @return           status对应的返回码，sid对应的sid字符串
 */
+ (NSDictionary *)initByAuthcodeGetVerificationToken:(NSString *)userId captcha:(NSString *)captcha deviceFilter:(XDDeviceFilter)deviceFilter;

/**
 *  非直连初始化（二次认证）：完成用户初始化
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param tokenB     服务器返回的密钥派生因子密文
 *  @return           status对应的返回码
 */
+ (NSDictionary *)initByAuthcodeFinish:(NSString *)userId tokenB:(NSString *)tokenB;

/**
 *  交易信息加密
 *  @param userId               芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param transactionInfo      交易相关信息，格式由应用自行定义
 *  @return                     status对应的错误码，encdata对应的加密字符串
 */
+ (NSDictionary *)getEncryptedTransactionInfo:(NSString *)userId transactionInfo:(NSString *) transactionInfo;

/**
 *  交易信息加密(对应服务端1.5及以下)
 *  @param userId               芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param transactionInfo      交易相关信息，格式由应用自行定义
 *  @return                     status对应的错误码，encdata对应的加密字符串
 */
+ (NSDictionary *)getOldEncryptedTransactionInfo:(NSString *)userId transactionInfo:(NSString *) transactionInfo;

/**
 *  交易信息加密
 *  @param userId               芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param deviceFilter         过滤标识，默认取全部信息
 *  @param transactionInfo      交易相关信息，格式由应用自行定义
 *  @return                     status对应的错误码，encdata对应的加密字符串
 */
+ (NSDictionary *)getEncryptedTransactionInfo:(NSString *)userId deviceFilter:(XDDeviceFilter)deviceFilter transactionInfo:(NSString *) transactionInfo;


#pragma mark ******统一身份认证******
/////////////////////// 统一身份认证 ////////////////////////////

//申请激活
+ (void)requestCIMSActiveForUser:(NSString *)user type:(NSString *)type onResult:(void(^)(int error, id response))onResult;
//激活
+ (void)verifyCIMSActiveForUser:(NSString *)user authCode:(NSString *)authCode pushID:(NSString *)pushID onResult:(void(^)(int error, id response))onResult;
//用户信息同步
+ (void)requestCIMSUserInfoSyncForUser:(NSString *)user realName:(NSString *)realName phone:(NSString *)phone authCode:(NSString *)authCode department:(NSString *)department employeeNum:(NSString *)employeeNum onResult:(void(^)(int error, id response))onResult;
//应用列表接口
+ (void)getCIMSAppInfoListForUser:(NSString *)user onResult:(void(^)(int error, id response))onResult;
//单个应用
+ (void)checkCIMSAppUser:(NSString *)user appID:(NSString *)appID userName:(NSString *)userName pwd:(NSString *)pwd onResult:(void(^)(int error, id response))onResult;
+ (void)requestCIMSDelUserAppInfo:(NSString *)user appID:(NSString *)appID onResult:(void (^)(int error))onResult;
//获取验证码
+ (void)requestCIMSAuthCodeForUser:(NSString *)user phone:(NSString *)phone type:(NSString *)type onResult:(void(^)(int error, id response))onResult;
//fetch
+ (void)getCIMSPushFetchForUser:(NSString *)user stoken:(NSString *)stoken onResult:(void(^)(int error, id response))onResult;
///push/getlist
+ (void)getCIMSPushListForUser:(NSString *)user onResult:(void(^)(int error, id response))onResult;

+ (void)requestCIMSCheckTokenForUser:(NSString *)user stoken:(NSString *)stoken confirm:(NSString *)confirm onResult:(void(^)(int error, id response))onResult;
+ (void)getCIMSUserInfoForUser:(NSString *)user onResult:(void(^)(int error, id response))onResult;
//+ (NSString *)getCIMSDynamicCode:(NSString *)userNo;
+ (void)requestCIMSSyncTotp:(NSString *)userID onResult:(void (^)(int error))onResult;

//设备相关
+ (void)getCIMSActivedDeviceListForUser:(NSString *)user onResult:(void(^)(int error, id response))onResult;

+ (void)requestCIMSDevicePushConfigForUser:(NSString *)user openDevices:(NSArray *)openDevices closeDevices:(NSArray *)closeDevices onResult:(void(^)(int error))onResult;

+ (void)requestCIMSDeviceDeleteForUser:(NSString *)user deleteDevices:(NSArray *)deleteDevices onResult:(void(^)(int error))onResult;

//人脸相关
+ (void)requestCIMSFaceInfoSyncForUser:(NSString *)user faceData:(NSData *)faceData onResult:(void(^)(int error))onResult;
+ (void)verifyCIMSFaceForUser:(NSString *)user ftoken:(NSString *)ftoken confirm:(NSString *)confirm faceData:(NSData *)faceData onResult:(void(^)(int error))onResult;


//声纹相关
+ (void)requestCIMSVoiceInfoSyncForUser:(NSString *)user voiceId:(NSString *)voiceId onResult:(void(^)(int error))onResult;
+ (void)verifyCIMSVoiceForUser:(NSString *)user vtoken:(NSString *)vtoken confirm:(NSString *)confirm onResult:(void(^)(int error))onResult;
//+ (NSString *)getCIMSUUID:(NSString *)user;
+ (void)deleteCIMSFaceVoiceInfoForUser:(NSString *)user type:(NSString *)type onResult:(void(^)(int error))onResult;
//+ (NSString *)getCIMSVoiceAuthIDForUser:(NSString *)user;
//单点登录相关
+ (void)getCIMSLogin2Target4AppForUser:(NSString *)user onResult:(void(^)(int error, id response))onResult;
//今日验证次数 getdatecount
+ (void)getCIMSDateCountForUser:(NSString *)user startDate:(NSDate *)startDate endDate:(NSDate *)endDate onResult:(void(^)(int error, id response))onResult;

//获取旧手机号验证码
+ (void)getCIMSAuthcode4Update:(NSString *)user authType:(NSString *)authType onResult:(void(^)(int error, id response))onResult;
//校验旧手机验证码
+ (void)checkCIMSAuchcode4Update:(NSString *)user authcode:(NSString *)authcode onResult:(void(^)(int error, id response))onResult;
//获取用户的会话列表
+ (void)getCIMSSessionList:(NSString *)user appid:(NSString *)appid onResult:(void(^)(int error, id response))onResult;
/**
 注销对应会话的用户
 
 @param user 芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 @param appid 应用ID
 @param sid sessionID
 @param onResult 回调结果，error：错误码
 */
+ (void)requestCIMSSessionLogout:(NSString *)user appid:(NSString *)appid sid:(NSString *)sid onResult:(void (^)(int error))onResult;

/**
 获取OAuth信息
 
 @param user 芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 @param onResult 回调结果， error：错误码，response：OAuth信息
 */
+ (void)requestCIMSOAuthInfo:(NSString *)user onResult:(void(^)(int error, id response))onResult;





#pragma mark ******特斯联：门锁信息保护接口******

/////////////////////////////// 特斯联：门锁信息保护接口 ++++++++++ ////////////////
/**  门锁信息解密接口
 输入参数：
    -	userId：芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应。
    -	encryptedDoorInfo：芯盾服务器加密门锁id + 门锁密钥生成的密文。
 API方法返回值：
    -	NSDictionary, status对应的错误码, plain返回解密出的原文
 */
+ (NSDictionary *) tslParseDoorInfo: (NSString *)userId transactionInfo:(NSString *) encryptedDoorInfo;

/**	获取门锁挑战应答码API
 API方法输入参数：
 -	userId：芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应。
 -	doorId：门锁id
 -	doorSec: 门锁密钥
 -	code：挑战随机数
 
 API方法返回值：
 -		NSDictionary, status对应的错误码，resp对应的应答码字符串
 */
+ (NSDictionary *) tslGetLockChallengeResponse: (NSString *)userId withDoor:(NSString *) doorId withSecret: (NSString *) doorSec withChallenge: (NSString *)code;

/////////////////////////////// 特斯联：门锁信息保护接口 ---------- ////////////////

/////////////////////////////// 设备指纹：在线获取 ++++++++++ ////////////////
#pragma mark ******在线获取设备指纹接口******
/**
 * 从芯盾设备指纹云平台获取本机设备ID。
     输入：APPID，芯盾设备指纹云平台为客户分配的ID
     异步返回：
         error： 0 - 成功，其他 - 错误码
         dictResult：字典对象，包含如下内容
             - devid：设备ID
             - devname：设备名称
             - is_emu：是否模拟器
             - is_root：是否越狱
 */
+ (void) getDeviceIdOnline: (NSString *)APPID withServer: (NSString *)URL OnResult:(void (^)(int error, id dicResult))onresult;
+ (void) getDeviceIdOnline: (NSString *)APPID OnResult:(void (^)(int error, id dicResult))onresult;

+ (void)getDeviceIdOnline:(NSString*)APPID withServer:(NSString *)URL withParams:(NSDictionary *)param OnResult:(void (^)(int error, id dicResult))onresult;
/////////////////////////////// 设备指纹：在线获取 ---------- ////////////////

#pragma mark - 设备注册+登录
/////////////////////////////// 设备注册+登录 ++++++++++ ////////////////
+ (NSDictionary *)getEncryptCommonParamsDevinfoWithParams:(NSDictionary *)params devinfo:(NSString *)devinfo;
/////////////////////////////// 设备注册+登录 ---------- ////////////////




#pragma mark  *** Deprecated/discouraged APIs ***

/**
 *  初始化SDK运行环境
 *  @param appId      芯盾为客户应用服务器分配的APPID
 *  @param url        芯盾服务器部署地址
 *  @return           YES：初始化成功 NO：参数错误
 */
+ (BOOL)initEnv:(NSString *)appId url:(NSString *)url;

/**
 *  语音初始化
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone      用户已经绑定的手机号。必须为真实的手机号
 *  @param onSuccess  成功回调
 *  @param onFailure  失败回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByVoiceRequest:(NSString *)userId phone:(NSString *)phone onSuccess:(void (^)(id result))onSuccess onFailure:(void (^)(int errorCode, NSString *errorMsg))onFailure;
/**
 *  校验语音初始化
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone      用户已经绑定的手机号。必须为真实的手机号
 *  @param onSuccess  成功回调
 *  @param onFailure  失败回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByVoiceCheck:(NSString *)userId phone:(NSString *)phone captcha:(NSString *)captcha onSuccess:(void (^)(id result))onSuccess onFailure:(void (^)(int errorCode, NSString *errorMsg))onFailure;
/**
 *  上行短信初始化
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return           status对应的返回码，request_code对应request_code值
 */
+ (NSDictionary *)initByUpsmsGetRequestCode:(NSString *)userId;

/**
 *  申请上行短信初始化请求码
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone      用户已经绑定的手机号。必须为真实的手机号
 *  @param onSuccess  成功的回调，result是要发送的短信内容
 *  @param onFailure  失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)iniByUpsmsGetReplyCode:(NSString *)userId phone:(NSString *)phone onSuccess:(void (^)(NSString * result))onSuccess onFailure:(void (^)(int errorCode, NSString *errorMsg))onFailure;

/**
 *  检查上行短信初始化状态
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone      用户已经绑定的手机号。必须为真实的手机号
 *  @param onSuccess  成功的回调
 *  @param onFailure  失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByUpSmsCheck:(NSString *)userId phone:(NSString *)phone onSuccess:(void (^)(id  result))onSuccess onFailure:(void (^)(int errorCode, NSString *errorMsg))onFailure;



/**
 *  U盾初始化
 *  @param userId     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return           status对应的返回码，sid对应sid值
 */
+ (NSDictionary *)initByUkeyRequest:(NSString *)userId;
/**
 *  校验U盾初始化的验证码
 *  @param userId       芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param captcha      用户提供的验证码
 *  @param onSuccess    成功的回调
 *  @param onFailure    失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByUkeyCheck:(NSString *)userId captcha:(NSString *)captcha onSuccess:(void (^)(id result)) onSuccess onFailure:(void (^)(int errCode, NSString *errMsg))onFailure;
/**
 *  上行电话初始化：申请验证电话号码
 *  @param userId       芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone        用户已经绑定的手机号。必须为真实的手机号
 *  @param expiretime   请求会在多少秒以后超时，超过以后再拨打电话无效
 *  @param onSuccess    成功的回调,result是电话号码
 *  @param onFailure    失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByCallRequest:(NSString *)userId phone:(NSString *)phone expireTime:(NSString *)expireTime onSuccess:(void (^)(id result))onSuccess onFailure:(void (^)(int errCode, NSString *errMsg))onFailure;


/**
 *  申请上行语音验证码加上行短信
 *  @param userId       芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone        用户已经绑定的手机号。必须为真实的手机号
 *  @param expiretime   请求会在多少秒以后超时，超过以后再拨打电话无效
 *  @param onSuccess    成功的回调,result是电话号码和发送内容（格式：028-66006474@36aefc）
 *  @param onFailure    失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByCallSmsRequest:(NSString *)userId phone:(NSString *)phone expireTime:(NSString *)expireTime onSuccess:(void (^)(id result))onSuccess onFailure:(void (^)(int errCode, NSString *errMsg))onFailure;

/**
 *  上行电话初始化：检查电话验证结果
 *  @param userId       芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone        用户已经绑定的手机号。必须为真实的手机号
 *  @param onSuccess    成功的回调
 *  @param onFailure    失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)initByCallCheck:(NSString *)userId phone:(NSString *)phone onSuccess:(void (^)(id result))onSuccess onFailure:(void (^)(int errCode, NSString *errMsg))onFailure;


/**
 *  身份认证
 *  @param userId           芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param contextInfo      交易相关信息，格式由应用自行定义。其中包含的内容，在风险评估完成后，受到芯盾协商得到的密钥保护
 *  @param onSuccess        成功的回调,result是utoken值
 *  @param onFailure        失败的回调，errCode对应的错误码，errMsg对应的错误信息
 */
+ (void)getUserAuthInfo:(NSString *)userId contextInfo:(NSString *)contextInfo onSuccess:(void (^)(id result))onSuccess onFailure:(void (^)(int errCode, NSString *errMsg))onFailure;

/**
 * 请务必在调用初始化接口（requestVoiceCaptchaForUser）之前调用此接口
 * 设置芯盾服务器的部署地址，默认为 https://sdk.trusfort.com:7443。需要联系芯盾服务器部署人员确认。
 */
//+ (Boolean) setServerURLPrefix: (NSString *)url_prefix;
+ (Boolean) initEnv: (NSString *)url_prefix withAppID: (NSString *)AppID WithRiskServer: (NSString *)risk_server_prefix;

/**
 * 检查用户是否已经通过语音验证码完成了激活。
 *  true：用户已经激活
 *  false：用户尚未激活，需要先后调用requestVoiceCaptchaForUser、verifyVoiceCaptchaForUser完成激活。
 */
+ (Boolean)isUserActivitated: (NSString *)userid;
/**
 *  用户状态信息
 *  返回值NSDictionary，"status"：状态码，"msg":手机信息
 */
+ (NSDictionary *)userInitializedInfo:(NSString *)userId;

/**
 * 取消用户的激活状态。
 * 如需使用芯盾功能，需要重新调用requestVoiceCaptchaForUser接口请求语音验证码，并验证通过。
 */
// 取消所有本地用户的激活状态。
+ (void) deactivateAllUsers;
// 取消指定用户的激活状态。
//+ (void) deactivateUser: (NSString *)userid;

//////////////////////// 初始化方式：语音验证码 ///////////////////////////
/**
 * 为指定用户请求语音验证码。由芯盾云外呼平台发出呼叫
 * 返回码error：0 - 申请成功，其他 - 申请失败（手机号错误、userid错误、网络错误）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) requestVoiceCaptchaForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id result_info))onresult;

/**
 * 验证用户收到的语音验证码。
 * 返回码error：0 - 验证通过，其他 - 验证失败失败（手机号错误、userid错误、网络错误、验证码错误等）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) verifyVoiceCaptchaForUser: (NSString *)userid WithPhone: (NSString *)phone WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error, id result_info))onresult;

//////////////////////// 初始化方式：U盾（蓝牙盾、音频盾） ///////////////////////////
/**
 * 获取U盾初始化所需要的sid参数。应用使用sid，传递给服务器端，请求初始化所需要的验证码
 * 返回码error：0 - 验证通过，其他 - 申请sid失败（userid错误、授权错误等）。如果已经初始化，返回-5003。
 result_info: json字符串，格式如 {"sid":"123456b393a8371055ac78f7686aae7e4902187b4746b2", "risk_level": 0, "risk_info": {} }
 */
+ (void) requestUkeyInitSidForUser: (NSString *)userid OnResult:(void (^)(int error, id result_info))onresult;

/**
 * 根据拿sid从芯盾服务器换回的验证码，初始化用户密钥。
 * 返回码error：0 - 验证通过，其他 - 验证验证码失败（userid错误、网络错误、验证码错误、授权错误等）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) verifyUkeyCaptchaForUser: (NSString *)userid WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error, id result_info))onresult;

//////////////////////// 初始化方式：人脸图片 ///////////////////////////
/**
 * 获取人脸图片后，提交到服务器进行校验。
 * 返回码error：0 - 验证通过，其他 - 验证失败（userid错误、授权错误等）。如果已经初始化，返回-5003。
 result_info: json字符串，格式如 { "risk_level": 0, "risk_info": {} }
 */
+ (void) verifyFaceForUser: (NSString *)userid WithFaceImage: (NSString*)facePath WithFaceInfo: (NSString *)faceInfo OnResult:(void (^)(int error, id result_info))onresult;

//////////////////////// 初始化方式：上行短信 ///////////////////////////
/**
 * 获取上行短信内容：编码后的长字符串。适用于短信服务号固定的情形。
 * 返回：json字符串，格式如 { "status": 0, "request_code": "da5f9c8a9fdb9dc4cb0d64697989d411d4140801" }
 */
+ (NSString *) requestUplinkSmsInitSidForUser:(NSString *)userid;

/**
 * 获取通知短信，以及上行短信回复的内容：4-8位数字。适用于短信服务号动态变化的情形。
 * 返回码error：0 - 获取成功，其他 - 获取失败（userid错误、授权错误等）。如果已经初始化，返回-5003。
 result_info: json字符串，格式如 { "risk_level": 0, "risk_info": {} }
 */
+ (void) requestUplinkSmsInitTriggerAndCodeForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id sms_reply_code))onresult;

/**
 * 用户已经发送上行短信后，查询初始化结果的接口。
 * 返回码error：0 - 初始化成功，9002 - 尚未收到上行短信，可再次查询，其他 - 获取失败（userid错误、授权错误等）。如果已经初始化，返回-5003。
 result_info: json字符串，格式如 { "risk_level": 0, "risk_info": {} }
 */
+ (void) checkUplinkSmsInitResultForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id result_info))onresult;

////////////////////////////明文验证码处理////////////////////////////////////////
/** 芯盾自测接口
 * 为指定用户请求明文短信验证码。
 */
+ (void) requestPlainCaptchaForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id OnResult:(void (^)(int error, id msg))onresult;

/**
 * 为银行服务器向芯盾服务器发申请明文验证码、加密验证码请求，生成token
 */
+ (NSString *) getXindunRequestTokenForUser: (NSString *)userid; // 用于申请验证码
+ (NSString *) getXindunRequestTokenForUser: (NSString *)userid ForTransaction:(NSString*) transaction_id; //用于校验解密后的验证码

/**
 * 为银行服务器向芯盾服务器发送校验明文验证码请求，加密明文验证码
 */
+ (NSString *) getEncryptedCaptchaForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id WithCaptcha:(NSString *)captcha;

/** 芯盾自测接口
 * 验证用户收到的明文短信验证码。
 */
+ (void) verifyPlainCaptchaForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error))onresult;

////////////////////////////密文验证码处理////////////////////////////////////////

/**
 * 密文验证码解密接口
 */
+ (NSString *) getDecryptedCaptchaForUser: (NSString *)userid WithEncryptedCaptcha: (NSString *)encrypted_captcha;


///////////////////////////////////////////
/**
 *
 */
//+ (NSString*) get_sha1: (NSString *)text;

/**芯盾自测接口
 * 为指定用户请求加密短信验证码。
 */
+ (void) requestEncryptedCaptchaForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id OnResult:(void (^)(int error, id msg))onresult;

/**芯盾自测接口
 * 验证用户收到的明文短信验证码。
 */
+ (void) verifyEncryptedCaptchaForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error))onresult;

/**
 * 身份验证接口
 * 返回码error：0 - 身份认证成功，其他 - 身份认证失败
 respJson: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) getAuthInfoForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id OnResult:(void (^)(int error, id respJson))onresult;
/**
 * 大数据风控接口
 * 返回码error：0 - 获取风控结果成功，其他 - 获取风控结果失败
 respJson: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) getRiskInfoForUser: (NSString *)userid ForOpType: (NSString *)optype WithPhone: (NSString*)user_phone WithContext: (NSString *)jsonContext OnResult:(void (^)(int error, id respJson))onresult;

// 风控通知接口，内测使用
+ (void) bizzNotifyForUser: (NSString *)userid WithType: (NSString *)notify_type OnResult:(void (^)(int error, id respJson))onresult;

+ (NSString *) encryptData: (NSString *)plain ForUser: (NSString *)userid;
+ (NSString *) decryptData: (NSString *)encrypted ForUser: (NSString *)userid;

/**
 * 会话秘钥加密(采集完整设备信息)
 
 @param plain 明文
 @return NSDictionary，{"status" : 0, "info":{ appid：应用ID , appkey_version：秘钥版本号,os_type:ios, sToken：密文token }}
 */
+ (NSDictionary *)commonEncrypt:(NSString*)plain;

/**
 * 会话秘钥加密(采集精简设备信息)
 
 @param plain 明文
 @return NSDictionary，{"status" : 0, "info":{ appid：应用ID , appkey_version：秘钥版本号,os_type:ios, sToken：密文token }}
 */
+ (NSDictionary *)commonEncryptNano:(NSString *)plain;

/**
 * 会话秘钥解密
 
 @param sToken 密文
 @return NSDictionary， {"status" : 0, "plain" :明文 }
 */
+ (NSDictionary *)commonDecrypt:(NSString*)sToken;

////////////////////// 通用数据加解密，HMAC接口 ////////////////////
/**
 * 字符串加密接口。使用WORK_KEY，必须使用本SDK或者对应芯盾服务器解密。
 * 输出：密文字符串
 */
+ (NSString *) encryptText: (NSString *)plain;
+ (NSString *) decryptText: (NSString *)encrypted;
+ (NSString *) getTextHmac: (NSString *)text;

////////////////////// 获取设备ID ////////////////////
+ (NSString *) getDeviceId;


/////////////////////// 二维码扫码验证支持 ////////////////////////////
+ (NSString *) getQrcodeStokenSignature: (NSString *)serverToken ForTransaction: (NSString *)transaction_id;

/////////////////////// 交易信息加密接口 ////////////////////////////
+ (NSString *) getEncryptedTransanctionInfoForUser: (NSString *)userid ForTransaction: (NSString *)transaction_info;

/////////////////////// 加密了params的请求接口 ////////////////////////////
/**
 * 为指定用户请求语音验证码。由芯盾云外呼平台发出呼叫
 * 返回码error：0 - 申请成功，其他 - 申请失败（手机号错误、userid错误、网络错误）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) secRequestVoiceCaptchaForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id result_info))onresult;

/**
 * 验证用户收到的语音验证码。
 * 返回码error：0 - 验证通过，其他 - 验证失败失败（手机号错误、userid错误、网络错误、验证码错误等）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) secVerifyVoiceCaptchaForUser: (NSString *)userid WithPhone: (NSString *)phone WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error, id result_info))onresult;
/**
 * 身份验证接口
 * 返回码error：0 - 身份认证成功，其他 - 身份认证失败
 respJson: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void) secGetAuthInfoForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id OnResult:(void (^)(int error, id respJson))onresult;
/////////////////////// 从服务器获取统一的用户ID接口（某客户特有） ////////////////////////////
/**
 * userid: json串
 */
+ (void) networkGetUnifiedUserId: (NSString *)userid OnResult:(void (^)(int error, id respJson))onresult;

/////////////////////// SSE非直连（某客户特有） ////////////////////////////

/**
 *  生成初始化申请token
 *
 *  @param userID   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param onresult 回调结果，error : 0 成功，其他为失败
 resp : token字符串
 
 */
+ (void)initByAuthcodeGetRequestTokenForUser:(NSString *)userID OnResult:(void (^)(int err, id resp))onresult;

/**
 *  生成初始化校验token
 *
 *  @param userid    芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param authCode  用户提供的验证码，或者应用自动获取的authcode
 *  @param onresult  回调结果，error : 0 成功，其他为失败
 resp : 生成的校验token串
 */
+ (void)initByAuthcodeGetVerifyTokenForUser:(NSString *)userid withAuthcode:(NSString *)authCode OnResult:(void (^)(int err, id resp))onresult;

/**
 *  校验应用服务器返回的授权token字符串，如果成功则为该用户生成密钥
 *
 *  @param userID    芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param response  应用业务服务器返回的授权token串
 *  @param onresult  回调结果，error : 0 初始化成功，其他为失败
 */
+ (void)initByAuthcodeVerifyServerResponseForUser:(NSString *)userID Response:(id)response OnResult:(void(^)(int err))onresult;


/////////////////////// SSE jar集成方式（某客户特有） ////////////////////////////

/**
 *  获取初始化请求token
 *
 *  @param userid  芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *
 *  @return 返回值格式为 {
 "status":,//0:成功， 其他:失败
 "uuid":"", // 32字符定长
 "devfp":"", // 设备指纹，44字符定长
 "initRequestToken":"", // 长度小于2000字节
 }
 */
+ (NSString *)getSecInitRequestTokenForUser:(NSString *)userid;


/**
 *  获取初始化验证token
 *
 *  @param userid   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param authcode 用户提供的验证码，或者应用自动获取的authcode
 *
 *  @return 返回值result_info: json字符串格式为：{
 "status":,//0:成功， 其他:失败
 "uuid":"", // 32字符定长
 "devfp":"", // 设备指纹，44字符定长
 "initInitVerifyToken":"", // 长度小于2000字节
 }
 */
+ (NSString *)getSecInitVerifyTokenForUser:(NSString *)userid WithAuthcode:(NSString *)authcode;


/**
 *   完成用户初始化
 *
 *  @param userid 芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param stoken 服务器返回的密钥派生因子密文
 *
 *  @return 0:成功，其他:失败
 */
+ (int)finishSecInitForUser:(NSString *)userid WithStoken:(NSString *)stoken;


/**
 *  获取身份认证token
 *
 *  @param userid         芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param transaction_id 交易相关信息，格式由应用自行定义。其中包含的内容，在风险评估完成后，受到芯盾协商得到的密钥保护
 *
 *  @return  返回值respJson: 结果json字符串，格式为：{
 "status":,//0：成功， 其他：失败
 "uuid":"", // 32字符定长
 "devfp":"", // 设备指纹，44字符定长
 "authToken":"", // 长度小于2000字节
 }
 */
+ (NSString *) getAuthTokenForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id;

/////////////////////// SSE 设备信息（某客户特有） ////////////////////////////

/**
 *  获取设备信息
 *
 *  @return 设备信息字符串
 */
+ (NSString *)getDeviceInfo;

/////////////////////// SSE 上行语音初始化（某客户特有） ////////////////////////////
/**
 *  申请上行语音初始化
 *
 *  @param userID   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param type     @"1":上行语音， @"2":上行语音+上行短信
 *  @param onresult 回调结果，error : 0 成功，其他为失败
 resp : 需要拨打的语音号码
 */
+ (void)requestUplinkVoiceInitSidForUser:(NSString *)userid withPhone:(NSString *)phone expiretime:(NSString *)expiretime type:(NSString *)type OnResult:(void (^)(int err, id resp))onresult;
/**
 *  验证上行语音初始化
 *
 *  @param userID   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param onresult 回调结果，err : 0 初始化成功，其他为失败
 
 */
+ (void)verifyUplinkVoiceInitForUser:(NSString *)userid withPhone:(NSString *)phone withAuthcode:(NSString *)authcode OnResult:(void (^)(int err))onresult;




/////////////////////// 参数加密 ////////////////////////////


/**
 *  为指定用户请求语音验证码。由芯盾云外呼平台发出呼叫
 *  @param userid   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param onresult 回调结果，0 - 申请成功，其他 - 申请失败（手机号错误、userid错误、网络错误）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void)requestSecVoiceCaptchaForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id result_info))onresult;

/**
 * 验证用户收到的语音验证码。
 *  @param userid   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param onresult 回调结果，0 - 申请成功，其他 - 申请失败（手机号错误、userid错误、网络错误）
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void)verifySecVoiceCaptchaForUser: (NSString *)userid WithPhone: (NSString *)phone WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error, id result_info))onresult;


/**
 * 获取通知短信，以及上行短信回复的内容：4-8位数字。适用于短信服务号动态变化的情形。
 *  @param userid   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param onresult 回调结果，0 - 申请成功，其他 - 申请失败（手机号错误、userid错误、网络错误）如果已经初始化，返回-5003。
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 
 */
+ (void)requestSecUplinkSmsInitTriggerAndCodeForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id sms_reply_code))onresult;

/**
 * 用户已经发送上行短信后，查询初始化结果的接口。
 *  @param userid   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param onresult 回调结果，error：0 - 初始化成功，9002 - 尚未收到上行短信，可再次查询，其他 - 获取失败（userid错误、授权错误等）。如果已经初始化，返回-5003。
 result_info: json字符串，格式如 { "risk_level": 0, "risk_info": {} }
 */
+ (void)checkSecUplinkSmsInitResultForUser: (NSString *)userid WithPhone: (NSString *)phone OnResult:(void (^)(int error, id result_info))onresult;




/**
 * 根据拿sid从芯盾服务器换回的验证码，初始化用户密钥。
 *  @param userid   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param onresult 回调结果error：0 - 验证通过，其他 - 申请sid失败（userid错误、授权错误等）。
 result_info: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void)verifySecUkeyCaptchaForUser: (NSString *)userid WithCaptcha: (NSString *)captcha OnResult:(void (^)(int error, id result_info))onresult;

/**
 * 获取人脸图片后，提交到服务器进行校验。
 *  @param userid     芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param facePath   人脸照片路径
 *  @param faceInfo   其他信息
 *  @param onresult   回调结果 error：0 - 验证通过，其他 - 验证失败（userid错误、授权错误等）。如果已经初始化，返回-5003。
 result_info: json字符串，格式如 { "risk_level": 0, "risk_info": {} }
 */
+ (void)verifySecFaceForUser: (NSString *)userid WithFaceImage: (NSString*)facePath WithFaceInfo: (NSString *)faceInfo OnResult:(void (^)(int error, id result_info))onresult;
/**
 *  申请上行语音初始化
 *
 *  @param userID   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param type     @"1":上行语音， @"2":上行语音+上行短信
 *  @param onresult 回调结果，error : 0 成功，其他为失败
 resp : 需要拨打的语音号码
 */
+ (void)requestSecUplinkVoiceInitSidForUser:(NSString *)userid withPhone:(NSString *)phone expiretime:(NSString *)expiretime type:(NSString *)type OnResult:(void (^)(int err, id resp))onresult;
/**
 *  验证上行语音初始化
 *
 *  @param userID   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param phone    用户手机号
 *  @param onresult 回调结果，err : 0 初始化成功，其他为失败
 
 */
+ (void)verifySecUplinkVoiceInitForUser:(NSString *)userid withPhone:(NSString *)phone OnResult:(void (^)(int err))onresult;


/////////////////////// SSE SDK ////////////////////////////

/**
 *  初始化SSE SDK运行环境
 *  @param AppID    芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return         true：成功， false：失败
 */
+ (Boolean)initEnvWithAppID:(NSString *)AppID;


/**
 *  AES加密
 *
 *  @param data        需要加密的内容
 *  @param dataLength    需要加密的内容的长度
 *  @return             Base64编码后的密文串
 */
+ (NSString *)getXindunAesEncryptData:(const unsigned char*)data dataLength:(const long)dataLength;
/**
 *  AES解密
 *
 *  @param data        需要解密的内容
 *  @param output       解密后的数据
 *  @param outputLength   解密后数据的长度
 *  @return             0： 成功 其他：失败
 */

+ (int)getXindunAesDecryptData:(NSString *)data output:(unsigned char*)output outputLength:(long *)outputLength;
/**
 *  hmac-sha256
 *
 *  @param data        需要计算hmac的内容
 *  @param dataLength    数据长度
 *  @return            Base64后的hmac
 */
+ (NSString *)getXindunHamcSha256Data:(const unsigned char*)data dataLength:(const long)dataLength;


/**
 *  国密加密
 *
 *  @param data        需要加密的内容
 *  @param dataLength    需要加密的内容的长度
 *  @return             Base64编码后的密文串
 */
+ (NSString *)getXindunsm4EncryptData:(const unsigned char*)data dataLength:(const long)dataLength;
/**
 *  国密解密
 *
 *  @param data        需要解密的内容
 *  @param output       解密后的数据
 *  @param outputLength   解密后数据的长度
 *  @return             0： 成功 其他：失败
 */
+ (int)getXindunsm4DecryptData:(NSString *)data output:(unsigned char*)output outputLength:(long *)outputLength;
/**
 *  国密hmac
 *
 *  @param data        需要计算hmac的内容
 *  @param dataLength    数据长度
 *  @return            Base64后的hmac
 */
+ (NSString *)getXindunsm3HmacData:(const unsigned char*)data dataLength:(const long)dataLength;

/////////////////////// 交易信息加密接口 ////////////////////////////

+ (void) getUserAuthTokenForUser: (NSString *)userid ForTransaction: (NSString *)transaction_info OnResult:(void (^)(int error, id authToken))onresult;

/////////////////////// SSE 非直连方案 ////////////////////////////
/**
 *  申请初始化认证Sid
 *
 *  @param userid        芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @return              token字符串
 */
//+ (NSString *)getInitRequestTokenForUser:(NSString *)userid;
+ (void)getInitRequestSidForUser:(NSString *)userid OnResult:(void (^)(int error, id sid))onresult;

/**
 *  校验初始化
 *
 *  @param userid        芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param response      服务器响应字符串
 *  @return              0：初始化城 其他：初始化失败
 */
+ (void)finishInitByStokenForUser: (NSString *)userid WithStoken: (NSString *)stoken OnResult:(void (^)(int error))onresult;

/**
 * 身份验证接口
 *
 *  @param userID   芯盾SDK唯一识别用户的ID。由应用生成，需要和应用的用户ID一一对应
 *  @param transaction_id    交易流水或者交易流水+验证码
 *  @param onresult 回调结果，error：0 - 身份认证成功，其他 - 身份认证失败
 respJson: json字符串，格式如 {"risk_level": 0, "risk_info": {} }
 */
+ (void)getSecAuthInfoForUser: (NSString *)userid ForTransaction: (NSString *)transaction_id OnResult:(void (^)(int error, id respJson))onresult;

#pragma mark - ******Logs api begin******

#define SDK_LOG_VERBOSE 1
#define SDK_LOG_DEBUG   2
#define SDK_LOG_INFO    3
#define SDK_LOG_WARN    4
#define SDK_LOG_ERROR   5
#define SDK_LOG_FATAL   6
#define SDK_LOG_END     7

+(void)changeLogLevel:(int)level;

+(NSString *)getLogs;

+(void)clearLogs;

#pragma mark ******Logs api end******

#pragma mark - ******error report begin******

/**
 *  是否允许错误上报（默认不上报）
 *
 *  @param enable        YES：允许，NO：不允许
 */
+(void)enableErrorReport:(BOOL)enable;

/**
 *  设置错误上报服务地址
 *
 *  @param url        错误上报服务地址，如果用户使用自己的地址部署错误上报服务，则需要正确设置url，如果使用芯盾错误上报云平台，则不许要设置
 */
+(void)setupCustormErrorReportURL:(NSString *)url;

#pragma mark ******error report end******



#pragma mark ******IDAAS解耦SDK*******

/**
 IDaaS专用初始化方法
 
 @param appId       芯盾为客户应用服务器分配的APPID
 @param serviceUrl  业务服务地址，如选用非直连模式，传入nil
 @param devfpUrl    在线设备指纹服务地址，如无需使用在线设备指纹，传入nil
 @return 初始化SDK运行环境结果，YES，成功， NO，参数错误
 */

+ (BOOL)initCIMSEnv:(NSString *)appId serviceUrl:(NSString *)serviceUrl devfpUrl:(NSString *)devfpUrl;

/**
 获取动态验证码，6位验证码，生成周期30秒
 
 @param userNo 用户ID
 @return 动态验证码
 */
+ (NSString *)getCIMSDynamicCode:(NSString *)userNo;

/**
 获取动态验证码
 
 @param userNo          用户ID
 @param capacity     验证码位数 如4/6/8，最大支持10位
 @param interval     生成周期 如30/60/90s
 @return 动态验证码
 */
+ (NSString *)getCIMSDynamicCode:(NSString *)userNo capacity:(NSUInteger)capacity interval:(NSUInteger)interval;

/**
 获取UUID
 
 @param user 用户ID
 @return UUID
 */
+ (NSString *)getCIMSUUID:(NSString *)user;

/**
 生成声纹ID
 
 @param user 用户ID
 @return 为当前用户生成声纹ID
 */
+ (NSString *)getCIMSVoiceAuthIDForUser:(NSString *)user;

/**
 注册或验证人脸
 @param user 用户ID
 @return 为当前用户生成声纹ID
 */
+ (NSString *)requestOrverifyCIMSFaceForUser:(NSString *)user faceData:(NSData *)faceData ctx:(NSArray *)ctx signdata:(NSString *)sign isType:(BOOL)isType;

/**
 *  会话秘钥加密-激活前
 *  @param user         用户ID
 *  @param type         是否添加deviceInfo参数
 *  @param ctx          拼接参数值
 *  @return             加密后的params的字符串
 */

+ (NSString *)encryptBySkey:(NSString *)user ctx:(NSString *)ctx isType:(BOOL)type;

/**
 *  会话秘钥加密，用户秘钥签名
 *  @param userid           用户ID
 *  @param isDeviceType     是否添加deviceInfo参数
 *  @param ctx              拼接参数值
 *  @return                 加密后的params的字符串
 */
+ (NSString *)encryptByUkey:(NSString *)userid ctx:(NSArray *)ctx signdata:(NSString *)sign isDeviceType:(BOOL)isDeviceType;
/**
 *  获取spinfo信息
 *  spcode  公司spid
 */
+ (NSString *)encryptByUkey:(NSString *)spcode;
/**
 *  通用方法，只调用cims加密
 *  signCtx  拼接好的json字符串
 */
+ (NSString *)encryptByUkeyForParams:(NSString *)signCtx;

/**
 *  二次认证 ——————getcartatoken接口的解耦
 *  @param userid    用户ID
 *  @param appid     后台管理平台创建应用的appid
 *  @param type      业务场景 0代表登录，1代表用户操作
 *  @param uaifno    用户行为信息
 *  @return
 */
+ (NSString *)encryptByUkey:(NSString *)userid appid:(NSString *)appid type:(NSString *)type uainfo:(NSString *)uainfo;
//+ (NSDictionary *)getEncryptedTransactionInfo:(NSString *)userId transactionInfo:(NSString *) transactionInfo;
//解密激活后返回
+ (NSDictionary *)decodeServerResponse:(NSString *)resp;
//SSE
+ (int)privateVerifyCIMSInitForUserNo:(NSString *)userNo response:(NSDictionary *)response userId:(NSString **)userId;
+ (BOOL)checkCIMSHmac:(NSString *)userID randa:(NSString *)randa shmac:(NSString *)shmac;
#pragma mark 其他可能用到的辅助接口
//+ (NSString *) encryptData: (NSString *)plain ForUser: (NSString *)userid;
//+ (NSString *) decryptData: (NSString *)encrypted ForUser: (NSString *)userid;


#pragma mark-厦门国际 2.0.1版本

/**
 *获取加密后的params-自注册
 @param ctx     上传参数的拼接
 @param user    用户id或者用户账号
 */
+ (NSString *)getParamsWithencryptText:(NSString *)ctx user:(NSString *)user;

#pragma mark ****** IDAAS解耦SDK  END *******

@end
