//
//  ShowGateVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/23.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "ShowGateVC.h"

@interface ShowGateVC ()
- (IBAction)disMissVC:(UIBarButtonItem *)sender;

@end

@implementation ShowGateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[BLEOperation share] connectPeripheral];
    [BLEOperation share].delegatePeripheralProperValue = self;
    //[self performSelector:@selector(disMissVC:) withObject:nil afterDelay:5.0];
}

#pragma mark -- 
-(void)didUpdateCMState:(NSString *)message{
    [SVProgressHUD showErrorWithStatus:message];
}
-(void)didUpdateValueForChtc:(NSString *)result{
    if ([result isEqualToString:@"TIMEOK"]) {
        [SVProgressHUD showErrorWithStatus:@"已打开"];
        [[BLEOperation share] cancelPeripheralConnection];
        [self disMissVC:nil];
    }
}
-(void)didDisConnection{
    [SVProgressHUD showErrorWithStatus:@"请重试"];
    [self disMissVC:nil];
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

- (IBAction)disMissVC:(UIBarButtonItem *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEBOOL object:nil];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
