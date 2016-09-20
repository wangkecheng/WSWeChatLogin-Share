//
//  UserInfoModel.h
//  WSWeChatLogin
//
//  Created by warron on 16/9/19.
//  Copyright © 2016年 warron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
@interface UserInfoModel : NSObject

+(instancetype)share;

@property (strong, nonatomic) NSString *nickname; // 用户昵称
@property (strong, nonatomic) NSString *headimgurl; // 用户头像地址
@property (strong, nonatomic) NSString *country; // 微信用户当前国家信息
@property (strong, nonatomic) NSString *province; // 用户省份
@property (strong, nonatomic) NSString *city; // 用户城市
@property (strong, nonatomic) NSString *lang; // 微信客户端当前语言
@property (strong, nonatomic) NSString *six; //性别

@property (strong, nonatomic) NSDictionary *privilege; // 用户特权

@property (nonatomic,strong) SendAuthResp *sResp;
@property (strong, nonatomic) NSString *access_token; //
@property (strong, nonatomic) NSString *expires_in; //
@property (strong, nonatomic) NSString *openid; //
@property (strong, nonatomic) NSString *refresh_token; //
@property (strong, nonatomic) NSString *scope; //授权作用域 代表用户授权给第三方的接口权限，第三方应用需要向微信开放平台申请使用相应scope的权限后，使用文档所述方式让用户进行授权，经过用户授权，获取到相应access_token后方可对接口进行调用。
@property (strong, nonatomic) NSString *unionid; //
@property (strong, nonatomic) NSString *state;//第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
@property (strong,nonatomic) NSString *code;//授权临时票据 第三方通过code进行获取access_token的时候需要用到，code的超时时间为10分钟，一个code只能成功换取一次access_token即失效。code的临时性和一次保障了微信授权登录的安全性。第三方可通过使用https和state参数，进一步加强自身授权登录的安全性。


//设置三个重要的请求参数
-(void)setRequestParameter:(NSDictionary *)dict;

//登陆后批量设置微信返回信息
-(void)setInfoAfterLogin:(NSDictionary *)dict;

@end


