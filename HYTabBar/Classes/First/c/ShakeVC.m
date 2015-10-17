//
//  ShakeVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/12.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

/**
 *  用户打开APP，点击开始后进入“摇一摇”，
 *  “摇一摇”过程分两段：第一段为用户摇晃5下，然后画面提示进入第二段，第二段无上限，为持续摇晃过程。
 *  最后结束计算分数。第一段（摇晃5下）分数为70-100内随机数值，第二段分数根据摇晃时间计算，总分数的“第一段分数X第二段分数”
 *  分数计入排行，排行有“每日排行”及“总排行”两种，“每日排行”每日更新
 */

#import "ShakeVC.h"
#import <CoreMotion/CoreMotion.h>

@interface ShakeVC ()
{
    BOOL _isShake; // 是否在摇动
    BOOL _isOver;
    NSInteger _beginTimestamp;// 开始摇的时间戳
}
@end

@implementation ShakeVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isOver = NO;// 是否摇动已经结束
    _beginTimestamp = 0;
    //设置允许摇动
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];//设置第一响应者
    
}

//重载
-(BOOL)canBecomeFirstResponder{

    return YES;
}
#pragma mark -- applicationSupportsShakeToEdit = YES
//检测到摇动
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{

    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"Began");
        //[self initShake];
    }
    
}
//摇动结束
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"Ended");

}
//摇动取消
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSLog(@"请重试，");
    
}

#pragma mark -- 计算摇晃持续时间
- (void)initShake {
    
    CMMotionManager *_motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *_operationQueue = [[NSOperationQueue alloc] init];
    
    _motionManager.accelerometerUpdateInterval = 1;
    
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue withHandler:^(CMAccelerometerData *latestAcc, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            // 所有操作进行同步
            @synchronized(_motionManager) {
                _isShake = [self isShake:_motionManager.accelerometerData];
                if (_beginTimestamp == 0 && _isShake == YES) {
                    NSLog(@"开始了");
                    _beginTimestamp = [[NSDate date] timeIntervalSince1970];
                }
                
                if (_beginTimestamp != 0 && _isShake == NO) {
                        _isOver = YES;
                    }
                
                // 此时为摇动结束
                if (_isOver) {
                    // 停止检测摇动事件
                    [_motionManager stopAccelerometerUpdates];
                    // 取消队列中排队的其它请求
                    [_operationQueue cancelAllOperations];
                    NSInteger currentTimestamp = [[NSDate date] timeIntervalSince1970];
                    // 摇动的持续时间
                    NSInteger second = currentTimestamp - _beginTimestamp;
                    NSLog(@"摇动结束， 持续时间为:%ld", (long)second);
                }
            }
        });
    }];
}

- (BOOL)isShake:(CMAccelerometerData *)newestAccel {
    
    _isShake = NO;
    // 三个方向任何一个方向的加速度大于1.5就认为是处于摇晃状态，当都小于1.5时认为摇奖结束。
    if (ABS(newestAccel.acceleration.x) > 1.5 || ABS(newestAccel.acceleration.y) > 1.5 || ABS(newestAccel.acceleration.z) > 1.5) {
        _isShake = YES;
    }
    return _isShake;
}


-(void)viewWillDisappear:(BOOL)animated{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
