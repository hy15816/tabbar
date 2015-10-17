//
//  ReadBookVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/24.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//  阅读页面

#define TopViewHeight       50.f
#define BottomViewHeight    80.f

#import "ReadBookVC.h"
#import "UIScrollView+touches.h"

typedef enum {
    TranPageTypeUp,
    TranPageTypeDown
}TranPageType;

@interface ReadBookVC ()<UITextViewDelegate>
{
    UIView *top;
    BOOL flags;
    UIView *bottomView;
    UITextView *txtView;
}
@end

@implementation ReadBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    flags = NO;
    top = [[UIView alloc] initWithFrame:CGRectMake(0, -TopViewHeight, DEVICE_WIDTH, TopViewHeight)];
    top.backgroundColor = [UIColor whiteColor];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(5, 10, 30, 30);
    [b setImage:[UIImage imageNamed:@"goLeft"] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(backVC:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:b];
    
    txtView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    txtView.userInteractionEnabled = YES;
    txtView.showsHorizontalScrollIndicator = NO;
    txtView.showsVerticalScrollIndicator = NO;
    txtView.backgroundColor = COLORRGB(250, 250, 247, 1);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jdzh" ofType:@"txt"];
    NSError *error;
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    txtView.text = [s substringToIndex:10000];
    txtView.editable = NO;
    txtView.selectable = NO;
    txtView.delegate = self;
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, BottomViewHeight)];
    bottomView.backgroundColor = COLORRGB(255, 231, 157, 1);
    
    [self.view addSubview:txtView];
    [self.view addSubview:top];
    [self.view addSubview:bottomView];
}


- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)backVC:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doubleTapTxtView{
    //双击

    flags = !flags;
    [UIView animateWithDuration:.15 animations:^{
        if (flags) {
            top.frame = CGRectMake(0, 0, DEVICE_WIDTH, TopViewHeight);
            bottomView.frame = CGRectMake(0, DEVICE_HEIGHT-TopViewHeight, DEVICE_WIDTH, BottomViewHeight);
        }else{
            top.frame = CGRectMake(0, -TopViewHeight, DEVICE_WIDTH, TopViewHeight);
            bottomView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, BottomViewHeight);
        }
    }];
    
}
-(void)textViewDidChangeSelection:(UITextView *)textView{
    
}

#pragma mark -- touches


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:[touch view]];
    //执行翻页
    if (point.x > (self.view.frame.size.width-self.view.frame.size.width/3.5f)) {
        [self singleTapTxtView:TranPageTypeDown];//翻页至下一页
        NSLog(@"touches Ended next");
    }else if(point.x < self.view.frame.size.width/3.5f){
        [self singleTapTxtView:TranPageTypeUp];
        NSLog(@"touches Ended up");
    }else{//弹出菜单
        [self doubleTapTxtView];
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touches Moved");
}

-(void)singleTapTxtView:(TranPageType)type{
    //单击也隐藏上下的view
    if (flags) {
        flags = NO;
        [UIView animateWithDuration:.15 animations:^{
            top.frame = CGRectMake(0, -TopViewHeight, DEVICE_WIDTH, TopViewHeight);
            bottomView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, BottomViewHeight);
        }];
        
    }
    //单击
    //翻页效果
    
    [UIView beginAnimations:@"anID" context:nil];
    [UIView setAnimationDuration:.5];
    //[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [txtView setContentOffset:CGPointMake(0, 480) animated:YES];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationTransition:type ==TranPageTypeDown?UIViewAnimationTransitionCurlUp:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    [UIView commitAnimations];
    
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
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
