//
//  ProjBaseVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/23.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "ProjBaseVC.h"

@interface ProjBaseVC ()
{
    UIButton        *_showWLANStateView;    //无网络时显示

}
@end

@implementation ProjBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *openItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(openButtonPressed)];
    self.navigationItem.leftBarButtonItem = openItem;
    
    _showWLANStateView =[UIButton buttonWithType:UIButtonTypeCustom];
    _showWLANStateView.frame = CGRectMake(0, 29, DEVICE_WIDTH, 35);
    _showWLANStateView.backgroundColor = [UIColor clearColor];
    [_showWLANStateView addTarget:self action:@selector(dismissShowWLANStateView) forControlEvents:UIControlEventTouchUpInside];
    [_showWLANStateView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_showWLANStateView setTitle:@"当前无网络可用，请检查网络设置>>" forState:UIControlStateNormal];
    _showWLANStateView.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_showWLANStateView];
    
    
}
- (void)openButtonPressed
{
    //[self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkWLANState];
    });
    
}

#pragma mark - 检测网络状态
-(void)checkWLANState{
    
    
    
    NSDictionary *dic = @{@"license_plate_number":@"粤S652EG"};//车牌号
    [GlobalTool postJSONWithUrl:@"http://112.74.128.144:8189/AnerfaBackstage/addLicensePlate/outOrIn.do" parameters:dic success:^(id accData){
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.5 animations:^{
                _showWLANStateView.backgroundColor = [UIColor clearColor];
                _showWLANStateView.frame = CGRectMake(0, 29, DEVICE_WIDTH, 35);
                [self changedSeleViewUp];
            }];
        });
    } fail:^(NSError *err){
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.5 animations:^{
                _showWLANStateView.backgroundColor = [UIColor orangeColor];
                _showWLANStateView.frame = CGRectMake(0, 29, DEVICE_WIDTH, 35);
                
                [self changedSeleViewDown];
            }];
         });
    }];
    
}

/**
 *  隐藏ShowWLANStateView
 */
-(void) dismissShowWLANStateView{
    /*
    [UIView animateWithDuration:.5 animations:^{
        _showWLANStateView.backgroundColor = [UIColor clearColor];
        _showWLANStateView.frame = CGRectMake(0, 29, DEVICE_WIDTH, 35);
        [self changedSeleViewUp];
    }];
    */
    UIViewController *control = [[UIViewController alloc] init];
    control.view.backgroundColor = [UIColor yellowColor];
    [self.navigationController pushViewController:control animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changedSeleViewDown{
    
}
-(void)changedSeleViewUp{
    
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
