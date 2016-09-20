//
//  AppDelegate.m
//  WSWeChatLogin
//
//  Created by warron on 16/9/18.
//  Copyright © 2016年 warron. All rights reserved.
//

#import "AppDelegate.h"
#import "WSViewController.h"


UserInfoModel *_userInfoModel;

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     WSViewController *wsview = [[WSViewController alloc]init];
       
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    wsview.view.backgroundColor = [UIColor whiteColor];
    
     _window.rootViewController = wsview;
    
    _userInfoModel =  [UserInfoModel share];
    //向微信注册
    [WXApi registerApp:@"wx4868b35061f87885"]; // 注意这里不要写错！（写错后无法获取授权，停留在登录界面等待）
    
     return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options{
   return [WXApi handleOpenURL:url delegate:self];
}

//现在，你的程序要实现和微信终端交互的具体请求与回应，因此需要实现WXApiDelegate协议的两个方法：
//onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
-(void) onReq:(BaseReq*)req{
    
  
}

//如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。

-(void) onResp:(BaseResp*)resp{
   /*
     0  展示成功页面
     -1  可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。
     -2  用户取消	无需处理。发生场景：用户不支付了，点击取消，返回APP。
     */
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        //授权登录的类。
      SendAuthResp *sResp = (SendAuthResp *)resp;
        
        [_userInfoModel setSResp:sResp];
        
        switch (sResp.errCode) {
            case 0:{
                
                //这里处理回调的方法。 通过代理吧对应的登录消息传送过去。
                if ([_wxDelegate respondsToSelector:@selector(loginSuccessByCode:)])
                    [_wxDelegate loginSuccessByCode:sResp];

            }break;
            case -4:
                //用户拒绝授权
                 NSLog(@"error %@",resp.errStr);
                break;
            case -2:
                //用户取消
                 NSLog(@"error %@",resp.errStr);
                break;
            default:
                break;
        }
    }

  else  if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        //微信分享 微信回应给第三方应用程序的类
        SendMessageToWXResp *response = (SendMessageToWXResp *)resp;
        
        NSLog(@"error code %d  error msg %@  lang %@   country %@",response.errCode,response.errStr,response.lang,response.country);
        
        if (resp.errCode == 0) {  //成功。
            //这里处理回调的方法 。 通过代理吧对应的登录消息传送过去。
                if([_wxDelegate respondsToSelector:@selector(shareSuccessByCode:)])
                    [_wxDelegate shareSuccessByCode:response.errCode];
            
        }else{ //失败
            NSLog(@"error %@",resp.errStr);
        }
    }
    
   
    if ([resp isKindOfClass:[PayResp class]]) {
        // 微信支付
        PayResp *response=(PayResp *)resp;
        
        switch(response.errCode){
            case 0:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                break;
                
            default:
                NSLog(@"支付失败，retcode=%d  errormsg %@",resp.errCode ,resp.errStr);
                break;
        }
    }
}
//1、Appsecret 是应用接口使用密钥，泄漏后将可能导致应用数据泄漏、应用的用户数据泄漏等高风险后果；存储在客户端，极有可能被恶意窃取（如反编译获取Appsecret）；
//2、access_token 为用户授权第三方应用发起接口调用的凭证（相当于用户登录态），存储在客户端，可能出现恶意获取access_token 后导致的用户数据泄漏、用户微信相关接口功能被恶意发起等行为；
//3、refresh_token 为用户授权第三方应用的长效凭证，仅用于刷新access_token，但泄漏后相当于access_token 泄漏，风险同上。

//如果你的程序要发消息给微信，那么需要调用WXApi的sendReq函数：其中req参数为SendMessageToWXReq类型。
-(BOOL) sendReq:(BaseReq*)req{
    //SendMessageToWXReq的scene成员，如果scene填WXSceneSession，那么消息会发送至微信的会话内。如果scene填WXSceneTimeline，那么消息会发送至朋友圈。如果scene填WXSceneFavorite,那么消息会发送到“我的收藏”中。scene默认值为WXSceneSession。
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
