//
//  AppDelegate.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "GuideView.h"
#import "Reachability.h"

@interface AppDelegate ()
@property (strong,nonatomic) Reachability *reachability;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];//显示window
    [self addGudieView];
    [self monitoringNetwork];
    return YES;
}

#pragma mark -- 监听网络
-(void)monitoringNetwork{
    _reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange:) name:kReachabilityChangedNotification object:nil];
    [_reachability startNotifier];
}

-(void)networkStateChange:(NSNotification *)notify{
    
    _reachability = [notify object];
    if (!_reachability.isReachable) {
        NSLog(@"no wan");
        [SVProgressHUD showErrorWithStatus:@"当前网络不稳定"];
    }
    
    if (_reachability.isReachableViaWiFi) {
        NSLog(@"wifi");
    }
    
    if (_reachability.isReachableViaWWAN) {
        NSLog(@"2、3G ");
        [SVProgressHUD showImage:nil status:@"正在使用数据流量网络"];
    }
    
}


#pragma mark --  引导页面
-(void)addGudieView{
    
    if (![hUSERDFS valueForKey:@"firstLaunch"]) {
    
        GuideView *gview = [[GuideView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        NSMutableArray *images  = [[NSMutableArray alloc] initWithObjects:@"image_leftImg",@"laugImg",@"ooopic_launchImg_640x960", nil];
        [gview setImages:images];
        [self.window addSubview:gview];
        [hUSERDFS setValue:@"1" forKey:@"firstLaunch"];
    
    }
}

#pragma mark
#pragma mark -- 

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

#pragma mark -- 支付回调
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"dic:%@",resultDic);
        NSLog(@"result = %@",[resultDic valueForKey:@"memo"]);//6002网络连接异常；6001用户中途取消，9000成功
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"提示" message:[resultDic valueForKey:@"memo"] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [a show];
        if ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000) {
            //上传服务器支付成功
            
        }
        
    }];
    
    return YES;
    
}
@end
