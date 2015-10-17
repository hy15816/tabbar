//
//  SecondVC.m
//  CusTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 rd-123. All rights reserved.
//

#import "SecondVC.h"

#warning  头文件的@interface @end，这里必须要有@implementation @end,不然报错，《undefind symbols for architecture x86_64》
@implementation Person


@end


@interface SecondVC ()<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) UIButton *selectBtn;   //当前选中的btn
- (IBAction)checkProvince:(UIButton *)sender;
- (IBAction)checkCity:(UIButton *)sender;
- (IBAction)checkVillage:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *provinceBtn;
@property (strong, nonatomic) IBOutlet UIButton *cityBtn;
@property (strong, nonatomic) IBOutlet UIButton *villageBtn;
@property (strong, nonatomic) IBOutlet UITableView *tbsView;

@property (strong,nonatomic) UITableView *tbView;
@property (strong,nonatomic) NSMutableArray *provinceArray;
@property (strong,nonatomic) NSMutableArray *citysArray;
@property (strong,nonatomic) NSMutableArray *villagesArray;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *goLeftv;
- (IBAction)goLeftvAction:(UIBarButtonItem *)sender;

@end

@implementation SecondVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _provinceArray = [[NSMutableArray alloc] init];
    _citysArray = [[NSMutableArray alloc] initWithObjects:@"c1",@"c2",@"c3", nil];
    _villagesArray = [[NSMutableArray alloc] initWithObjects:@"v1",@"v2",@"v3", nil];
    _selectBtn = _provinceBtn;
    
    [self getProvinceArray];
    
    _tbsView.delegate = self;
    _tbsView.dataSource = self;
    
    //右滑
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftViewSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    //左滑
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRightViewSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    
}

-(void)changedSeleViewDown{
    [UIView animateWithDuration:.5 animations:^{
        self.view.frame = CGRectMake(0, 35, DEVICE_WIDTH, DEVICE_HEIGHT);
    }];
    
}

-(void)changedSeleViewUp{
    [UIView animateWithDuration:.5 animations:^{
        self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    }];
    
}
#pragma mark
#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_selectBtn == _cityBtn) {
        return _citysArray.count;
    }
    if (_selectBtn == _villageBtn) {
        return _villagesArray.count;
    }
    if (_selectBtn == _provinceBtn) {
        return _provinceArray.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdf = @"cellidf";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdf];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdf];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_selectBtn == _provinceBtn) {
        cell.textLabel.text = [_provinceArray objectAtIndex:indexPath.row];
    }
    if (_selectBtn == _cityBtn) {
         cell.textLabel.text = [_citysArray objectAtIndex:indexPath.row];
    }
    if (_selectBtn == _villageBtn) {
         cell.textLabel.text = [_villagesArray objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark
#pragma mark -- UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_selectBtn == _provinceBtn) {
        [_provinceBtn setTitle:[_provinceArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        
    }
    if (_selectBtn == _cityBtn) {
        [_cityBtn setTitle:[_citysArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    }
    if (_selectBtn == _villageBtn) {
        [_villageBtn setTitle:[_villagesArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    }
}

#pragma mark
#pragma mark -- UISwipeGestureRecognizer
-(void)showLeftViewSwipe:(UISwipeGestureRecognizer *)swipe{
    
    if (swipe.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(showLeftView:)]) {
            [self.delegate showLeftView:self];
        }
    }
}

-(void)showRightViewSwipe:(UISwipeGestureRecognizer *)swipe{
    
    if (swipe.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:.35 animations:^{
            
            //_tbsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }];
    }
}

- (IBAction)goLeftvAction:(UIBarButtonItem *)sender {
    
    if ([self.delegate respondsToSelector:@selector(showLeftView:)]) {
        [self.delegate showLeftView:self];
    }
    
}

#pragma mark
#pragma mark -- Check Btn
- (IBAction)checkProvince:(UIButton *)sender {
    _selectBtn = _provinceBtn;
    
//    if (_citysArray.count >0) {
//        [_citysArray removeAllObjects];
//    }
//    if (_villagesArray.count >0) {
//        [_villagesArray removeAllObjects];
//    }
    
    [self getProvinceArray];
    [_tbsView reloadData];
}

- (IBAction)checkCity:(UIButton *)sender {
    _selectBtn = _cityBtn;
    
//    if (_provinceArray.count > 0) {
//        [_provinceArray removeAllObjects];
//    }
//    if (_villagesArray.count >0) {
//        [_villagesArray removeAllObjects];
//    }

    [_tbsView reloadData];
}

- (IBAction)checkVillage:(UIButton *)sender {
    _selectBtn = _villageBtn;
    
//    if (_provinceArray.count > 0) {
//        [_provinceArray removeAllObjects];
//    }
//    if (_citysArray.count >0) {
//        [_citysArray removeAllObjects];
//    }

    [_tbsView reloadData];
}

#pragma mark -- Get Arrays
/**
 *  获取所有省份
 */
-(void)getProvinceArray{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ProvincePlist" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    _provinceArray = (NSMutableArray *)[dict allKeys];
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
