//
//  WSViewController.m
//  WSWeChatLogin
//
//  Created by warron on 16/9/18.
//  Copyright © 2016年 warron. All rights reserved.
//

#import "WSViewController.h"
#import "WXApi.h"
#import "AppDelegate.h"
#import "WeixinPayHelper.h"

#define APP_ID @"wx4868b35061f87885"
#define APP_SECRET @"64020361b8ec4c99936c0e3999a9f249"

AppDelegate * appDelegate;
WeixinPayHelper *helper;

@interface WSViewController ()

@property (strong, nonatomic) UILabel *nickname; // 昵称
@property (strong, nonatomic) UIImageView *imageView; // 用户头像
@property (strong, nonatomic) UIButton *loginButton; // 登录按钮
@property (strong, nonatomic) UIButton *loginOutButton; // 注销按钮

@property (strong, nonatomic) UIButton *shareBtn; // 分享按钮

@property (strong, nonatomic) UIButton *payBtn; // 分享按钮
@end

@implementation WSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //添加对appdelgate的微信分享的代理
      appDelegate.wxDelegate = self;
    
    // 添加观察者
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(display)
                                                 name:@"wxLoginGetData"
                                               object:nil];
    
    // 初始化昵称
    _nickname = [[UILabel alloc] initWithFrame:CGRectMake(120, 50, 120, 30)];
    [_nickname setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:_nickname];
    
    // 初始化头像
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    _imageView.backgroundColor = [UIColor yellowColor];
    _imageView.layer.cornerRadius = 50; // 设置为圆形
    _imageView.layer.masksToBounds = YES; // 若不加这句话，加载的图片还是矩形的。
    [self.view addSubview:_imageView];
    
    // 初始化登录按钮
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, 100, 30)];
    [_loginButton setTitle:@"微信登录" forState:UIControlStateNormal];
    _loginButton.backgroundColor = [UIColor blueColor];
    _loginButton.layer.cornerRadius = 5.0f;
    [_loginButton addTarget:self action:@selector(sendAuthRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    //注销按钮
    _loginOutButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 300, 100, 30)];
    [_loginOutButton setTitle:@"微信注销" forState:UIControlStateNormal];
    _loginOutButton.backgroundColor = [UIColor blueColor];
    _loginOutButton.layer.cornerRadius = 5.0f;
    [_loginOutButton addTarget:self action:@selector(sendRequestForOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginOutButton];
    
    //分享按钮
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 360, 100, 30)];
    [_shareBtn setTitle:@"分享图片" forState:UIControlStateNormal];
    _shareBtn.backgroundColor = [UIColor blueColor];
    _shareBtn.layer.cornerRadius = 5.0f;
    [_shareBtn addTarget:self action:@selector(shareImageBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shareBtn];
    
    
    //分享按钮
    _payBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 360, 100, 30)];
    [_payBtn setTitle:@"微信支付" forState:UIControlStateNormal];
    _payBtn.backgroundColor = [UIColor blueColor];
    _payBtn.layer.cornerRadius = 5.0f;
    [_payBtn addTarget:self action:@selector(payButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_payBtn];

}
-(void)sendAuthRequest{
    
    if ([UserInfoModel share].access_token==nil?YES:NO) {
        if (![WXApi isWXAppInstalled]) {
            
            //构造SendAuthReq结构体
            SendAuthReq* req =[[SendAuthReq alloc] init];
            
            req.scope = @"snsapi_userinfo" ;// 此处不能随意改
            
            req.state = @"123";
            
            
            //第三方向微信终端发送一个SendAuthReq消息结构
            
            [WXApi sendReq:req];
        }else{
            //把微信登录的按钮隐藏掉。
            
        }
    }
    else{
        NSLog(@"您已经登陆");
    }
}
-(void)sendRequestForOut{
    
    //refresh_token失效的后，需要用户重新授权
    [UserInfoModel share].refresh_token = nil;
    [UserInfoModel share].access_token  = nil;
    [_nickname setText:@"请登录"];
    self.imageView.image = [UIImage imageNamed:@"12"];
    
    
}
-(void)shareImageBtn{
 
//    分享或收藏的目标场景，通过修改scene场景值实现。
//    
//    发送到聊天界面——WXSceneSession
//    
//    发送到朋友圈——WXSceneTimeline
//    
//    添加到微信收藏——WXSceneFavorite

    //缩略图
    UIImage *image = [UIImage imageNamed:@"12"];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"我是王帅";
    message.description = @"微信分享测试----描述信息";
    //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
    message.thumbData = UIImagePNGRepresentation(image);
    [message setThumbImage:image];
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = @"http://www.jianshu.com/p/b3QtRo";
    message.mediaObject = ext;
    message.mediaTagName = @"ISOFTEN_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq *sentMsg = [[SendMessageToWXReq alloc]init];
    sentMsg.message = message;
    sentMsg.bText = NO;
  
    sentMsg.scene =  WXSceneTimeline;  //分享到会话。
  
     BOOL isSuccess =  [WXApi sendReq:sentMsg];
}

#pragma mark 监听微信登陆是否成功 delegate
-(void)loginSuccessByCode:(SendAuthResp *)sResp{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登陆成功" message:[NSString stringWithFormat:@"reason : %@",sResp] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert show];
    
    //用户同意
    [self  requetWXData:sResp];
}
-(void)requetWXData:(SendAuthResp *)sResp {
    // 获取access_token
    // 格式：https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *urlStr =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", APP_ID, APP_SECRET, sResp.code];
    
    //开始请求数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 创建URL
        NSURL *wxUrl = [NSURL URLWithString:urlStr];
        //请求的数据自
        NSString *wxDataStr = [NSString stringWithContentsOfURL:wxUrl encoding:NSUTF8StringEncoding error:nil];
        //开始解析请求数据
        NSData *data  =  [wxDataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        //开始回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data!=nil?YES:NO) {
                //解析成字典
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                //设置三个重要的请求参数
                [[UserInfoModel share] setRequestParameter:dict];
                
                NSLog(@"dic = %@", dict);
                
                [self getUserInfo]; // 获取用户信息
            }
        });
        
    });
    
}
// 获取用户信息
- (void)getUserInfo {
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", [UserInfoModel share].access_token, [UserInfoModel share].openid];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data!=nil?YES:NO) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                //登陆后批量设置微信返回的所有用户信息
                [[UserInfoModel share] setInfoAfterLogin:dict];
                
                //AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];这里可以用这个来传递数据，此处最好是不用这样的方式，直接来个全局的
                //appdelegate.headimgurl = [dict objectForKey:@"headimgurl"]; // 传递头像地址
                //appdelegate.nickname = [dict objectForKey:@"nickname"]; // 传递昵称
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wxLoginGetData" object:nil]; // 发送通知 获取用户数据后就重新发送到登陆界面
                
                //刷新token
                [self  refresh];
            }
        });
    });
}
//  刷新access_token有效期。获取第一步的code后，请求以下链接进行refresh_token https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=APPID&grant_type=refresh_token&refresh_token=REFRESH_TOKEN
//  access_token是调用授权关系接口的调用凭证，由于access_token有效期（目前为2个小时）较短，当access_token超时后，可以使用refresh_token进行刷新，access_token刷新结果有两种：    1. 若access_token已超时，那么进行refresh_token会获取一个新的access_token，新的超时时间； 2. 若access_token未超时，那么进行refresh_token不会改变access_token，但超时时间会刷新，相当于续期access_token。 另外refresh_token拥有较长的有效期（30天），当refresh_token失效的后，需要用户重新授权。
- (void)refresh {
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", APP_ID, [UserInfoModel share].refresh_token];//[dict objectForKey:@"access_token"]
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *zoneUrl = [NSURL URLWithString:url];
        
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data!=nil?YES:NO) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"dic = %@", dict);
                //刷新三个重要的请求参数
                [[UserInfoModel share] setRequestParameter:dict];
            }
        });
    });
}



#pragma mark 监听微信分享是否成功 delegate
-(void)shareSuccessByCode:(int)code{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"分享成功" message:[NSString stringWithFormat:@"reason : %d",code] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

// 显示昵称和头像
- (void)display {
    //AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *str =[UserInfoModel share].nickname;

    [_nickname setText:str];
    
    NSString *url = [UserInfoModel share].headimgurl;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"12"]];
}


#pragma mark 微信支付
-(void)payButton{
    
    
    /**
     *  外界调用的微信支付方法
     *
     *  @param ordeNumber  系统下发订单号%100000000 得出的数字，确保唯一。
     *  @param myNumber    订单号  确保唯一
     *  @param price       价格
     付款流程:
     
     1. 获取 AccessToken
     2. 获取 genPackage
     3. 调起微信付款
     4. 在appdelegate 中的 onResp 监听 回调方法。 看是付款成功。
     
     回调代码参数说明：
     0  展示成功页面
     -1  可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。
     -2  用户取消	无需处理。发生场景：用户不支付了，点击取消，返回APP。
     */
    
    helper = [[WeixinPayHelper alloc] init];
    [helper payProductWith:@"Test Product" andName:@"product number 1" andPrice:[NSString stringWithFormat:@"%d",1500]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
