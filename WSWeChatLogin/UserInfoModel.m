//
//  UserInfoModel.m
//  WSWeChatLogin
//
//  Created by warron on 16/9/19.
//  Copyright © 2016年 warron. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

-(instancetype)init{
     //不允许用init方法
    @throw [NSException exceptionWithName:@"这是一个单利类" reason:@"不能用init方法，请使用share类方法" userInfo:nil];
}
-(instancetype)initPrivate{
    //用父类方法初始化
    if (self = [super init]) {
        
    }
    return self;
}
+(instancetype)share{
    static  UserInfoModel * infoModel = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        //GCD方式创建单列
        if (!infoModel?YES:NO) {
            infoModel = [[UserInfoModel alloc]initPrivate];
        }
    });
    return infoModel;
}

- (void)setSResp:(SendAuthResp *)sResp{
    
    _sResp = sResp;
    
    _lang =sResp.lang;
    
    _country = sResp.country;
    
    _state = sResp.state;
 
    _code = sResp.code;
}

-(void)setInfoAfterLogin:(NSDictionary *)dict{
    
    _openid =[dict objectForKey:@"openid"];
    _unionid = [dict objectForKey:@"unionid"];
    _nickname =  [dict objectForKey:@"nickname"];
    _six = [dict objectForKey:@"sex"];
    _country = [dict objectForKey:@"country"];
    _city = [dict objectForKey:@"city"];
    _province = [dict objectForKey:@"province"];
    _headimgurl = [dict objectForKey:@"headimgurl"];
    _privilege = [dict objectForKey:@"privilege"];
 
}
-(void)setRequestParameter:(NSDictionary *)dict{
    _openid = [dict objectForKey:@"openid"]; // 初始化
    _access_token  = [dict objectForKey:@"access_token"];//获得链接令牌
    _refresh_token = [dict objectForKey:@"refresh_token"];//获得刷新令牌
}
@end

