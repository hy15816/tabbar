//
//  HYMianViewController.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#define kCoinCountKey       100      //金币总数
#define kPackageImgvWidth   120      //钱袋宽高

#import "HYMianViewController.h"
#import "FirstVC.h"
#import "SecondVC.h"
#import "ThirdVC.h"
#import "FourVC.h"
#import "LeftView.h"

#import "Reachability.h"
#import "ASIHTTPRequest.h"

#import "LoginVC.h"

#import "BLEOperation.h"
#import "ShowGateVC.h"

#import "UILabel+FlickerNumber.h"
#import <AudioToolbox/AudioToolbox.h>

@interface HYMianViewController ()<UINavigationControllerDelegate,ProjBaseVCDelegate,LeftViewDelegate,BLEOperationDelegate,FourVCDelegate>
{
    LeftView        *leftView;
    NSMutableData   *_data;
    NSURLResponse   *_response;
    BLEOperation    *bleOp;
    //
    NSMutableArray  *_coinTagsArr;
    UIImageView     *_packageImgv;
    UILabel         *_lbFlicker;    //显示score
    
}

@end

@implementation HYMianViewController
@synthesize isPushIndex = _isPushIndex;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self autoLogin];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //先加ctorls,再添加barItems, 默认选中时，firsVC才会显示出来，
    [self addChildControllers];
    [self addTabBarItem];
    
    //摇一摇设置
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
    
    //蓝牙
    bleOp = [BLEOperation share];
    [bleOp initCentralManager];
    bleOp.delegate = self;
    
    //添加收金币效果
    [self setupUI];
    //[self getCionAction];
    
    if (_isPushIndex == 1) {
        //
        NSLog(@"............-->1");
    }
    
}

//tabBar的item
-(void)addTabBarItem{
    
    [hyTabBar addItemIcon:@"ooopic_11" select:@"ooopic_15" title:@"1" selectTitlt:@"T_T"];
    [hyTabBar addItemIcon:@"ooopic_12" select:@"ooopic_15" title:@"2" selectTitlt:@"T_T"];
    [hyTabBar addItemIcon:@"ooopic_13" select:@"ooopic_15" title:@"3" selectTitlt:@"T_T"];
    [hyTabBar addItemIcon:@"ooopic_14" select:@"ooopic_15" title:@"4" selectTitlt:@"T_T"];
    
}

//添加子控制器
-(void)addChildControllers{
    //
    FirstVC *first = [hMainStoryboard instantiateViewControllerWithIdentifier:@"FirstVCIDF"];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:first];
    nav1.delegate = self;
    
    //
    SecondVC *sec = [hMainStoryboard instantiateViewControllerWithIdentifier:@"SecondVCIDF"];
    sec.delegate = self;
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:sec];
    nav2.delegate = self;
    
    //
    ThirdVC *third = [hMainStoryboard instantiateViewControllerWithIdentifier:@"ThirdVCIDF"];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:third];
    nav3.delegate = self;
    
    //
    FourVC *four = [hMainStoryboard instantiateViewControllerWithIdentifier:@"FourVCIDF"];
    four.delegate = self;
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:four];
    nav4.delegate = self;
    
    
    [self addChildViewController:nav1];
    [self addChildViewController:nav2];
    [self addChildViewController:nav3];
    [self addChildViewController:nav4];

}



#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{

    hyTabBar.hidden = NO;
    
    // 获得当期导航控制器的根控制器
    UIViewController *root = navigationController.viewControllers[0];
    if (root != viewController) { // 不是根控制器
        // 拉长导航控制器的view
        CGRect frame = navigationController.view.frame;
        frame.size.height = [UIScreen mainScreen].applicationFrame.size.height+20;
        navigationController.view.frame = frame;
        
        // 添加Dock到根控制器的view上面
        [hyTabBar removeFromSuperview];
        CGRect dockFrame = hyTabBar.frame;
        
        dockFrame.origin.y = root.view.frame.size.height - hHYTabBarHeight;
        
        if ([root.view isKindOfClass:[UIScrollView class]]) { // 根控制器的view是能滚动
            UIScrollView *scroll = (UIScrollView *)root.view;
            dockFrame.origin.y += scroll.contentOffset.y;
            
            
        }
        hyTabBar.frame = dockFrame;
        [root.view addSubview:hyTabBar];
        
    }

}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    UIViewController *root = navigationController.viewControllers[0];
    if (viewController == root) {
        // 让导航控制器view的高度还原
        CGRect frame = navigationController.view.frame;
        frame.size.height = [UIScreen mainScreen].applicationFrame.size.height - hHYTabBarHeight+20;
        navigationController.view.frame = frame;
        
        // 添加Dock到mainView上面
        [hyTabBar removeFromSuperview];
        CGRect dockFrame = hyTabBar.frame;
        //dockFrame = CGRectMake(0, self.view.frame.size.height - kDockHeight-23, self.view.frame.size.width, kDockHeight);
        
        // 调整dock的y值
        dockFrame.origin.y = DEVICE_HEIGHT - hHYTabBarHeight;
        hyTabBar.frame = dockFrame;
        [self.view addSubview:hyTabBar];
    }


}

#pragma mark - SecondVCDelegate
-(void)addLeftView{
    
    if (!leftView) {
        leftView = [[LeftView alloc] initWithFrame:CGRectMake(-DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    }
    
    leftView.delegate = self;
    [self.view addSubview:leftView];
}
-(void)showLeftView:(UIViewController *)control{
    
    [self addLeftView];
    //animations
    [UIView animateWithDuration:.35 animations:^{
        leftView.frame = CGRectMake(-DEVICE_WIDTH/2, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        self.view.frame = CGRectMake(DEVICE_WIDTH/2, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        [self setImage];
    }];
}

-(void)backButtonClick:(UIButton *)button{

    
}

-(void)setImage{
    //检测网络
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != kNotReachable) {
        // 1.显示进度
        // 2.获取
        ASIHTTPRequest *httpReqs = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:hGetURLImage]];
        [httpReqs setDelegate:self];
        [httpReqs setCompletionBlock:^{
            //load结束
            
            UIImage *downloadedImage = [UIImage imageWithData:[httpReqs responseData]];
            if (!downloadedImage) {
                return ;
            }
            
            [leftView setLeftViewbgImg:downloadedImage];
            [SVProgressHUD dismiss];
            
            
        }];
        
        static long long downloadedBytes = 0;
        [httpReqs setBytesReceivedBlock:^(unsigned long long size, unsigned long long total){
            
            NSLog(@"size:%lld,total:%lld",size,total);
            
            downloadedBytes += size;
            
            CGFloat progressPercent = (CGFloat)downloadedBytes/total;
            [SVProgressHUD showProgress:progressPercent status:@"加载中"];
            NSLog(@"value:%.0f%%",progressPercent*100);
            downloadedBytes = 0;
        }];
        
        [httpReqs startAsynchronous];
        
    }else{
        NSLog(@"network not available");
    }

}

-(void)leftViewSwipe:(UISwipeGestureRecognizer *)swipe{
    
    [UIView animateWithDuration:.35 animations:^{
        leftView.frame = CGRectMake(-DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        
    }];

}

#pragma mark - FourVCDelegate
-(void)showLoginView{
    if (![GlobalTool isLogin]) {
        // 弹出登录页面
        LoginVC *loginvc = [hMainStoryboard instantiateViewControllerWithIdentifier:@"LoginVCIDF"];
        UINavigationController *lnav = [[UINavigationController alloc] initWithRootViewController:loginvc];
        
        [self presentViewController:lnav animated:YES completion:^{}];
    }
    
}

#pragma mark - 摇一摇
//1.设置view的  applicationSupportsShakeToEdit = YES
//2.重写becomeFirstResponder return YES
//3.实现摇动的3个方法
//检测到摇动
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"Began");
        //
        bleOp.allCarArray = [GlobalTool getData:[hUSERDFS valueForKey:hUSERNAME]];//获取d当前账号本地所有车牌dict
        //[bleOp startScan];//开始扫描
        
        if (_packageImgv.alpha ==0) {
            [self getCionAction];
        }
        
        return;
    }
    
}
/*
//摇动结束
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"Ended");
    }
    
    
}
//摇动取消
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"请重试，");
    }
    
    
}
 */

- (BOOL)becomeFirstResponder{
    return YES;
}


#pragma mark - BLEOperationDelegate
//蓝牙状态更新
-(void)didUpdateCMState:(NSString *)message{
    
    [SVProgressHUD showErrorWithStatus:message];
}

//连接成功的车牌
-(void)didConnectWithCar:(NSDictionary *)carDict{
   /*
    ShowGateVC *gate = [hMainStoryboard instantiateViewControllerWithIdentifier:@"ShowGateVCIDF"];
    gate.title = [carDict objectForKey:hCARNUM];
    UINavigationController *navGate = [[UINavigationController alloc] initWithRootViewController:gate];
    [self presentViewController:navGate animated:YES completion:^{}];
    */
}

-(void)didOpenGatesWithError:(NSString *)result{
    [SVProgressHUD showImage:nil status:result];
}

#pragma mark -  收金币特效
-(void)setupUI{
    _coinTagsArr = [NSMutableArray new];
    //袋子
    _packageImgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"package"]];
    _packageImgv.frame = CGRectMake((DEVICE_WIDTH-kPackageImgvWidth)/2-5, DEVICE_HEIGHT-200, kPackageImgvWidth, kPackageImgvWidth);
    _packageImgv.userInteractionEnabled = YES;
    _packageImgv.alpha = 0;
    
    _lbFlicker =[[UILabel alloc] init];//[UIButton buttonWithType:UIButtonTypeCustom];
    [_lbFlicker setBackgroundColor:[UIColor clearColor]];
    
    _lbFlicker.textColor = [UIColor whiteColor];
    _lbFlicker.textAlignment = NSTextAlignmentCenter;
    _lbFlicker.font = [UIFont systemFontOfSize:20 weight:.5];
    _lbFlicker.frame = CGRectMake(0, kPackageImgvWidth/2, kPackageImgvWidth, 30);
    
    [_packageImgv addSubview:_lbFlicker];
    [self.view addSubview:_packageImgv];
    
}

-(void)AgainClick:(UIButton *)b{
    [self getCionAction];
}

static int coinCount = 0;
-(void)getCionAction{
    [UIView animateWithDuration:.5 animations:^{
        _packageImgv.alpha = 1;
    }];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bgm_coin_01" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound (soundID);
    
    _lbFlicker.text = @"0000";
    //初始化金币生成的数量
    coinCount = 0;
    for (int i = 0; i<kCoinCountKey; i++) {
        
        //延迟调用函数
        [self performSelector:@selector(initCoinViewWithInt:) withObject:[NSNumber numberWithInt:i] afterDelay:i * 0.01];
    }
}
- (void)initCoinViewWithInt:(NSNumber *)i
{
    UIImageView *coin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Gold_%d",[i intValue] % 2 + 1]]];
    //初始化金币的最终位置
    coin.center = CGPointMake(CGRectGetMidX(self.view.frame) + arc4random()%40 * (arc4random() %3 - 1) - 20,CGRectGetMaxY(self.view.frame)-175);//ffix 原CGRectGetMidY(self.view.frame) +100
    coin.tag = [i intValue] + 1000;
    //每生产一个金币,就把该金币对应的tag加入到数组中,用于判断当金币结束动画时和福袋交换层次关系,并从视图上移除

    [_coinTagsArr addObject:[NSString stringWithFormat:@"%ld",(long)coin.tag]];
    
    [self.view addSubview:coin];
    //防止删除不干净，隐藏
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        coin.alpha =0;
    });
    
    [self setAnimationWithLayer:coin];
}

- (void)setAnimationWithLayer:(UIView *)coin
{
    CGFloat duration = 1.5f;
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    //绘制从底部到福袋口之间的抛物线
    CGFloat positionX   = coin.layer.position.x;    //终点x
    CGFloat positionY   = coin.layer.position.y;    //终点y
    CGMutablePathRef path = CGPathCreateMutable();
    int fromX       = arc4random() % (int)self.view.frame.size.width;     //起始位置:x轴上随机生成一个位置
    int height      = 0;//[UIScreen mainScreen].bounds.size.height + coin.frame.size.height; //y轴以屏幕高度为准 //ffix 改为0
    int fromY       = arc4random() % (int)positionY; //起始位置:生成位于福袋上方的随机一个y坐标
    
    CGFloat cpx = positionX + (fromX - positionX)/2;    //x控制点
    CGFloat cpy = fromY / 2 - positionY;                //y控制点,确保抛向的最大高度在屏幕内,并且在福袋上方(负数)
    
    //动画的起始位置
    CGPathMoveToPoint(path, NULL, fromX, height);
    CGPathAddQuadCurveToPoint(path, NULL, cpx, cpy, positionX, positionY);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:path];
    CFRelease(path);
    path = nil;
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    //图像由大到小的变化动画
    CGFloat from3DScale = 1 + arc4random() % 10 *0.1;
    CGFloat to3DScale = from3DScale * 0.5;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(from3DScale, from3DScale, from3DScale)], [NSValue valueWithCATransform3D:CATransform3DMakeScale(to3DScale, to3DScale, to3DScale)]];
    scaleAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    //动画组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = duration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.animations = @[scaleAnimation, animation];
    [coin.layer addAnimation:group forKey:@"position and transform"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        
        //动画完成后把金币和数组对应位置上的tag移除
        UIView *coinView = (UIView *)[self.view viewWithTag:[[_coinTagsArr firstObject] intValue]+1000];
        //NSLog(@"remove tag:%d",[[_coinTagsArr firstObject] intValue]);
        [coinView removeFromSuperview];
        if (_coinTagsArr.count >0) {
            [_coinTagsArr removeObjectAtIndex:0];
        }
        [_lbFlicker dd_setNumber:@(1000) duration:1.0 format:nil];
        //全部金币完成动画后执行的动作
        if (++coinCount == kCoinCountKey) {
            if (_coinTagsArr.count >0) {
                [_coinTagsArr removeAllObjects];
            }
            [self bagShakeAnimation];
            
        }
    }
}

//福袋晃动动画
- (void)bagShakeAnimation
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:- 0.2];
    shake.toValue   = [NSNumber numberWithFloat:+ 0.2];
    shake.duration = 0.1;
    shake.autoreverses = YES;
    shake.repeatCount = 4;
    
    [_packageImgv.layer addAnimation:shake forKey:@"bagShakeAnimation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.5 animations:^{
            _packageImgv.alpha = 0;//隐藏
        }];
        
    });
}


#pragma mark - 自动登录
-(void)autoLogin{
    
    if ([[hUSERDFS objectForKey:hDMTCODE] length] >0) {
        //用凭证码登录
        [GlobalTool postJSONWithUrl:LOGINURL parameters:@{hDMTCODE:[hUSERDFS objectForKey:hDMTCODE]} success:^(NSDictionary *json){
            if ([[json objectForKey:hCODE] intValue]  == 201 ) {
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                //保存登录状态
                [hUSERDFS setValue:@"1" forKey:hLOGINSTATE];
                NSLog(@"pzm login code:%@",[json objectForKey:hCODE]);
                //[self loginSuc];
            }
            if ([[json objectForKey:hCODE] intValue]  == 202 ) {
                [hUSERDFS setValue:@"" forKey:hDMTCODE];//凭证码
                [self presentToLoginVC];
            }
            [GlobalTool errorWithCode:[[json objectForKey:hCODE] intValue]];
        } fail:^(NSError *err){
            [SVProgressHUD showErrorWithStatus:err.localizedDescription];
        }];
        
    }else{
        [self presentToLoginVC];
    }

}

-(void)presentToLoginVC{
    LoginVC *login = [hMainStoryboard instantiateViewControllerWithIdentifier:@"LoginVCIDF"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
    [self presentViewController:nav animated:YES completion:^{}];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
