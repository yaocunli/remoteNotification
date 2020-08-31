//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
// 远程推送APNS优点：长连接、离线状态也可以、安装identifier分组通知

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册远程推送服务
    //1.enable the Push Notifications capability in your Xcode project
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    //设置通知类型
    if (version >= 10.0)
        {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionCarPlay | UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
                NSLog(@" iOS 10 request notification success");
            }else{
                NSLog(@" iOS 10 request notification fail");
            }
        }];
        }
    else if (version >= 8.0)
        {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
        [application registerUserNotificationSettings:setting];
        }else
            {     //iOS <= 7.0
                UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
                [application registerForRemoteNotificationTypes:type];
            }
    
    //2.注册app 适用于iOS 8+
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    //apn内容获取，如果apn有值，则是通过远程通知点击进来
    NSDictionary *apn = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    return YES;
}

//2.上传device token到我们的服务器
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // token 不要本地缓存，当你重新启动、用户换个手机、升级系统都会返回新的token
    // 安全的加密上传到我们的服务器❓
    
    if (deviceToken) {
        NSMutableString *deviceTokenString = [NSMutableString string];
        const char *bytes = deviceToken.bytes;
        NSInteger count = deviceToken.length;
        for (int i = 0; i < count; i++) {
            [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: deviceTokenString forKey: @"phoneToken"];
        [defaults synchronize];
        //上传远程通知deviceToken到我们服务器
        
    }
}

//2.注册失败
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //失败之后，找个合适机会再试一次
    
    
}
#pragma mark - app收到通知调用的方法
#pragma mark - ios 10+
// ios 10+ : Asks the delegate how to handle a notification that arrived while the app was running in the foreground.

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    
}

// ios 10+ : 用户点击远程通知启动app（后台进入）
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    
}

#pragma mark - ios 7,8,9
// 基于iOS7及以上的系统版本，如果是使用 iOS 7 的 Remote Notification 特性那么此函数将被调用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSLog(@"%@",userInfo);
    
}


/**
 
 3.上传payload和device token到APNS
 
 （1、服务器有两种方式建立和apns的安全连接（token和证书）
 （2、服务器发送POST请求：必须包含以下信息
 （3、证书建立连接的话：证书和CSR文件绑定，CSR文件作为私钥加密证书，证书当做公钥用来和APNS交互。我们服务器安装这两种证书,证书有效期1年。
 
 
 The JSON payload that you want to send
 
 The device token for the user’s device
 
 Request-header fields specifying how to deliver the notification
 
 For token-based authentication, your provider server’s current authentication token（大多是证书）
 
 HEADERS
 - END_STREAM
 + END_HEADERS
 :method = POST
 :scheme = https
 :path = /3/device/00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0
 host = api.sandbox.push.apple.com
 apns-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
 apns-push-type = alert
 apns-expiration = 0
 apns-priority = 10
 DATA
 + END_STREAM
 { "aps" : { "alert" : "Hello" } }
 
 
 
 */

/**
 4.创造一个新的远程通知
 大小限制在4~5KB之间
 json payload:aps字段告诉怎么显示，是弹框、声音或者badge
 可以自定义key，和aps字典同级
 {
 “aps” : {
 “alert” : {
 “title” : “Game Request”,
 “subtitle” : “Five Card Draw”
 “body” : “Bob wants to play poker”,
 },
 “category” : “GAME_INVITATION”
 },
 “gameID” : “12345678”
 }
 
 
 */

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
