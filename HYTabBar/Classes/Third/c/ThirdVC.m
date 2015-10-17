//
//  ThirdVC.m
//  CusTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 rd-123. All rights reserved.
//

#import "ThirdVC.h"
#import "ZhifuVC.h"
#import "LoginVC.h"

@interface ThirdVC ()<UISearchBarDelegate>

- (IBAction)payItemClick:(UIBarButtonItem *)sender;
@property (strong,nonatomic) UISegmentedControl *segmentControl;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation ThirdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    _segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@" 新 闻 ",@" 音 乐 ", nil]];
    _segmentControl.frame = CGRectMake((self.view.frame.size.width - self.view.frame.size.width/4.f)/2, 7, self.view.frame.size.width/4.f, 30);
    _segmentControl.selectedSegmentIndex = 0;
    [_segmentControl addTarget:self action:@selector(segmentSelectindex:) forControlEvents:UIControlEventValueChanged];
    [self.navigationController.navigationBar addSubview: _segmentControl];

    
}
-(void)segmentSelectindex:(UISegmentedControl *)segment{
    
    NSInteger index = segment.selectedSegmentIndex;
    if (index == 0) {
        //
        NSLog(@"0");
    }
    
    if (index == 1) {
        NSLog(@"1");
    }
}
#pragma mark -- UICollectionViewDataSource
//cell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 130;
}

//section个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:((1 * indexPath.row) / 255.0) green:((2 * indexPath.row)/255.0) blue:((3 * indexPath.row)/255.0) alpha:1.0f];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-15, cell.frame.size.width, 15)];
    l.textAlignment = NSTextAlignmentCenter;
    l.text = [NSString stringWithFormat:@"abc %ld",(long)indexPath.row];
    l.textColor = [UIColor whiteColor];
    l.backgroundColor = [UIColor clearColor];
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    [cell.contentView addSubview:l];
    return cell;
}

#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((DEVICE_WIDTH -35)/3+1, 100);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark -- UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    
//    return UIStatusBarStyleLightContent;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)payItemClick:(UIBarButtonItem *)sender {
    
    if (![GlobalTool isLogin]) {
        //登录
        LoginVC *login = [hMainStoryboard instantiateViewControllerWithIdentifier:@"LoginVCIDF"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:^{}];
    }else{
        ZhifuVC *zhifu = [hMainStoryboard instantiateViewControllerWithIdentifier:@"ZhifuVCIDF"];
        [self.navigationController pushViewController:zhifu animated:YES];

    }
    
}
@end
