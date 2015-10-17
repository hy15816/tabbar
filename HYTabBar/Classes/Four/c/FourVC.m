//
//  FourVC.m
//  CusTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 rd-123. All rights reserved.
//


#import "FourVC.h"
#import "FourCell.h"
#import "SBJson.h"
#import "LoginVC.h"
#import "NSString+helper.h"
#import "HYLoadMoreFooterView.h"

@interface FourVC ()<UIAlertViewDelegate,FourCellDelegate>
@property (strong,nonatomic) UIRefreshControl *refControl;
@property(strong,nonatomic) NSIndexPath *selectPath;
@property (strong,nonatomic) NSMutableArray *recordsArray;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addCars;
- (IBAction)loginOutClick:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginOut;

@end

@implementation FourVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([GlobalTool isLogin]) {
        NSString *titleString = [hUSERDFS valueForKey:hUSERNAME];
        self.title = [titleString OPphoneNo];
        self.addCars.enabled = YES;
        self.loginOut.enabled = YES;
    }else{
        self.addCars.enabled = NO;
        self.loginOut.enabled = NO;
        self.title = @"请先登录";
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _recordsArray = [[NSMutableArray alloc] init];
    [self setupRefresh];
    [self setupDownRefresh];
    
    /** 若没有登录弹出页面(在HYTabBarController present出来)，且不查询*/
    if ([self.delegate respondsToSelector:@selector(showLoginView)]) {
        [self.delegate showLoginView];
    }
    
    //若已登录，第一次自动刷新
    if ([GlobalTool isLogin]) {
        
        [self refreshStateChange:_refControl];
    }
    
    
}
#pragma mark -- 下啦刷新
-(void)setupRefresh{
    //1.添加刷新控件
     _refControl=[[UIRefreshControl alloc]init];
    [_refControl setTintColor:[UIColor blackColor]];//COLORRGB(<#r#>, <#g#>, <#b#>, <#a#>)
    [_refControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"下拉刷新"]];
    [_refControl addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refControl];
    
    //2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    //[_refControl beginRefreshing];
    
    // 3.加载数据
    //[self refreshStateChange:_refControl];
}

-(void)refreshStateChange:(UIRefreshControl *)control{
    if (control.refreshing) {
         control.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在刷新..."];
    }
    
    if ([GlobalTool isLogin]) {
        
        [self getAllRecords:_refControl];//刷新
    }else{
        [SVProgressHUD showImage:nil status:@"请先登录!"];
        [_refControl endRefreshing];
        return;
    }

}

#pragma mark -- 上啦加载

-(void)setupDownRefresh{
    HYLoadMoreFooterView *footerView = [HYLoadMoreFooterView footer];
    footerView.hidden = YES;
    self.tableView.tableFooterView = footerView;
}

-(void)loadMoreStatus{
    for (int i=0; i<10; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSString stringWithFormat:@"abcdef%d",i] forKey:@"License_plate_number"];
        [dict setObject:[NSString stringWithFormat:@"0098765%d",i] forKey:@"License_plate_id"];
        [_recordsArray addObject:dict];
    }
    
}
//实现协议
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_recordsArray.count == 0 || self.tableView.tableFooterView.isHidden == NO) return;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    //当最后一个cell完全显示时，contentOffset.y值
    CGFloat judeOffsetY = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height - self.tableView.tableFooterView.frame.size.height;
    if (offsetY >= judeOffsetY) { // 最后一个cell完全进入视野范围内
        // 显示footer
        self.tableView.tableFooterView.hidden = NO;
        
        // 加载更多的微博数据
        [self loadMoreStatus];
    }
}
#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _recordsArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FourCellIDF" ];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.leftImgv.image = [UIImage imageNamed:@"ooopic_11"];
    cell.carCardLabel.text = [[_recordsArray objectAtIndex:indexPath.row] objectForKey:hCARNUM];
    cell.autoSwitch.on = [GlobalTool getOpenGateTypeFro:cell.carCardLabel.text] == OpenGateTypeAuto?YES:NO;
    cell.delegate = self;
    
    return cell;
}

#pragma mark -- UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did select");
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete ) {
        _selectPath = indexPath;
        //1.删除数据库
        [self deledateCarNum:indexPath.row];
        
    }
}

/**
 *  删除车牌
 *
 *  @param index 索引
 */
-(void)deledateCarNum:(NSInteger)index{
    //
    NSDictionary *sendDic = @{hUSERNAME:hDFUSERNAME , hLsptNumber:[_recordsArray[index] objectForKey:hCARNUM],@"cd":@"d"};
    [GlobalTool postJSONWithUrl:OPCARINFOURL parameters:sendDic success:^(NSDictionary *json){
        NSLog(@"del return json:%@",json);
        if ([[json objectForKey:hCARNUMID] intValue] == 10006) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            [GlobalTool deleteRecord:_selectPath.row user:hDFUSERNAME];
            //2.删除数组
            [_recordsArray removeObjectAtIndex:_selectPath.row];
            [GlobalTool deleteRecord:_selectPath.row user:[hUSERDFS valueForKey:hUSERNAME]];
            //3.删除表格
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_selectPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [GlobalTool errorWithCode:[[json objectForKey:hCARNUMID] intValue]];
        
        
    } fail:^(NSError *error){
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_selectPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    //[self getAllRecords];
}
#pragma mark -- FourCellDelegate
-(void)switchAct:(UISwitch *)sth{
    NSIndexPath *indexp = [self.tableView indexPathForSelectedRow];
    NSString *carNumber = [[_recordsArray objectAtIndex:indexp.row] objectForKey:hCARNUM];

    //更新开闸类型
    if (sth.on) {

        [GlobalTool saveState:OpenGateTypeAuto forCarNumber:carNumber];
    }else{

        [GlobalTool saveState:OpenGateTypeYaoYiYao forCarNumber:carNumber];
    }
    
}

-(void)dCar:(NSString *)name car:(NSString *)car cd:(NSString *)cd {
    NSIndexPath *idexp = [self.tableView indexPathForSelectedRow];
    [GlobalTool postJSONWithUrl:OPCARINFOURL parameters:@{hUSERNAME:name , hCARNUM:car,@"cd":cd} success:^(NSDictionary *json){
        NSLog(@"del return json:%@",json);
        if ([[json objectForKey:hCARNUMID] intValue] == 10006) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            [GlobalTool deleteRecord:idexp.row user:hDFUSERNAME];
        }
        [GlobalTool errorWithCode:[[json objectForKey:hCARNUMID] intValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:idexp] withRowAnimation:UITableViewRowAnimationFade];
            
        });
        
        
    } fail:^(NSError *error){
        
        //[SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];

}

#pragma mark -- LoginOut
- (IBAction)loginOutClick:(UIBarButtonItem *)sender {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认退出？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [a show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex) {
        [GlobalTool loginOut];
        self.loginOut.enabled = NO;
        self.addCars.enabled = NO;
        self.title = @"请先登录";
        if (_recordsArray.count) {
            [_recordsArray removeAllObjects];
            [self.tableView reloadData];
            
            
        }
    }
}

-(void)getAllRecords:(UIRefreshControl *)control{
    NSDictionary *sendDic = @{hUSERNAME:hDFUSERNAME,@"license_plate_number":@"",@"cd":@"q"};
    [GlobalTool postJSONWithUrl:OPCARINFOURL parameters:sendDic success:^(NSDictionary *json){
        NSLog(@"get return json:%@",json);

        if ([[json objectForKey:hCARNUMID] intValue] == 100018 || [[json objectForKey:hLsptNumber] isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:@"查询成功"];
            NSString *jsString = [json objectForKey:hCARNUMID];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSError *ers;
            NSArray *jsObj = [jsonParser objectWithString:jsString error:&ers];
            if (_recordsArray.count) {
                [_recordsArray removeAllObjects];
            }
            for (NSDictionary *dict in jsObj) {
                [_recordsArray addObject:dict];
            }
            [_recordsArray writeToFile:hPlistPath(hDFUSERNAME) atomically:YES];
            [self.tableView reloadData];
            NSLog(@"_recordsArray:%@",_recordsArray);
            
        }else{
            [GlobalTool errorWithCode:[[json objectForKey:hCARNUMID] intValue]];
        }
        
        if (control) {
            [self stopRefreshing:control];
        }
    } fail:^(NSError *error){
        NSLog(@"get return err:%ld",(long)error.code);
        
        if (control) {
            [self stopRefreshing:control];
        }
    }];
    
}

-(void)stopRefreshing:(UIRefreshControl *)control{
    
    NSString *lastUpdateTime = [GlobalTool getCurrDateWithFormat:@"yy/M/d H:m:s"];
    control.attributedTitle = [[NSAttributedString alloc]initWithString:lastUpdateTime];
    [control endRefreshing];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _selectPath = nil;
    if (_recordsArray.count) {
        [_recordsArray removeAllObjects];
    }
    
    [SVProgressHUD dismiss];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
