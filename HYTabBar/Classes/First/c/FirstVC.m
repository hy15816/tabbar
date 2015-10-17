//
//  FirstViewController.m
//  CusTabBar
//
//  Created by rd-123 on 15/9/7.
//  Copyright (c) 2015年 rd-123. All rights reserved.
//

#import "FirstVC.h"
#import "FirstCell.h"
#import "BLEOperation.h"
#import "ReadBookVC.h"
#import "LoginVC.h"

@interface FirstVC ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;
- (IBAction)loginAction:(UIBarButtonItem *)sender;
@property (strong,nonatomic) UITableView *fTableView;
@property (strong,nonatomic) NSMutableArray *booksArray;
@property (strong,nonatomic) NSMutableArray *imagesArray;
@end

@implementation FirstVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    if ([GlobalTool isLogin]) {
        self.loginButton.enabled = NO;
    }
//    BOOL b = [self rc:@"TAS12345A" scanCp:@"TAS12346S"];

    
    //    NSLog(@"b--%d",b);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  测试发送的数据
     */
    //[[BLEOperation share] getData:@"粤S872FA" carId:@"00005193"];
    
    _booksArray = [[NSMutableArray alloc] initWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g", nil];
    _imagesArray = [[NSMutableArray alloc] initWithObjects:@"ooopic_11",@"ooopic_12",@"ooopic_13",@"ooopic_14",@"ooopic_15",@"ooopic_11",@"ooopic_12", nil];
    
    _fTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _fTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _fTableView.delegate = self;
    _fTableView.dataSource = self;
    [self.view addSubview:_fTableView];
    
    //[self timers];
    //[self.view addSubview:accView];
    
    
    
}

/**
 *  定时器
 */
-(void)timers{
    // 重复执行
    static int a=0;
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //在这里执行事件
        
        NSLog(@"times %d",a);
        if (a>10) {
            dispatch_source_cancel(_timer);
        }
        a++;
    });
    dispatch_resume(_timer);
}


-(BOOL)rc:(NSString *)selfCp scanCp:(NSString *)scanCp{
    BOOL flag;
    int count = 0;
    NSMutableArray *arr1 = [[NSMutableArray alloc]init];
    NSMutableArray *arr2 = [[NSMutableArray alloc]init];
    
    for (int i=0; i<9; i++) {
        NSString *str1 = [selfCp substringWithRange:NSMakeRange(i, 1)];
        NSString *str2 = [scanCp substringWithRange:NSMakeRange(i, 1)];
        [arr1 addObject:str1];
        [arr2 addObject:str2];
    }
    for (int i=0; i<9; i++) {
        if ([arr1[i] isEqual:arr2[i]]) {
            count++;
        }
    }
    NSLog(@"count:%d",count);
    if(count>=8){
        flag = YES;
        return flag;
    }else{
        flag = NO;
        return flag;
    }
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _booksArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FirstCell *cell = [FirstCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.imageButton addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //cell.titleLabel.text = [_booksArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -- UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}



-(void)imageButtonClick:(UIButton *)btn{
    
    ReadBookVC *read = [hMainStoryboard instantiateViewControllerWithIdentifier:@"ReadBookVCIDF"];
    [self.navigationController showViewController:read sender:@"aa"];

}


-(void)openVip{
    NSDictionary *sendDic = @{@"amount":@"350",hUSERNAME:@"18565667965",@"use":@""};
    
    [GlobalTool postJSONWithUrl:@"http://112.74.128.144:8189/AnerfaBackstage/paymentRecord/ktVip.do" parameters:sendDic success:^(NSDictionary *json){
        NSLog(@"get return json:%@",json);

        if ([[json objectForKey:hCODE] intValue] == 36000  ) {
            [SVProgressHUD showSuccessWithStatus:@"成功开通vip"];
            
        }else if ([[json objectForKey:hCODE] intValue] == 36001){
            [SVProgressHUD showSuccessWithStatus:@"已是vip"];
        }else{
            [GlobalTool errorWithCode:[[json objectForKey:hCARNUMID] intValue]];
        }
        
    } fail:^(NSError *error){
        NSLog(@"get return err:%@",error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
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

- (IBAction)loginAction:(UIBarButtonItem *)sender {
    if (![GlobalTool isLogin]) {
        //登录
        LoginVC *login = [hMainStoryboard instantiateViewControllerWithIdentifier:@"LoginVCIDF"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:^{}];
    }else{
        //ZhifuVC *zhifu = [hMainStoryboard instantiateViewControllerWithIdentifier:@"ZhifuVCIDF"];
        //[self.navigationController pushViewController:zhifu animated:YES];
        
    }
    
}
@end
