//
//  AppDelegate.h
//  WSWeChatLogin
//
//  Created by warron on 16/9/18.
//  Copyright © 2016年 warron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

//获取Appdelgate中登陆的信息
@protocol WXDelegate <NSObject>

-(void)loginSuccessByCode:(SendAuthResp *)code;
-(void)shareSuccessByCode:(int) code;
@end
@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,weak)id<WXDelegate> wxDelegate;

@end

