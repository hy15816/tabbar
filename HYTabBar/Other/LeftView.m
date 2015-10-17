//
//  LeftView.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/14.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "LeftView.h"

@implementation LeftView
{
    UIImageView *leftView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self initLeftv];
    }
    return self;
}

-(void)initLeftv{
    leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    leftView.userInteractionEnabled = YES;
    leftView.image = [self getBgImage];
    //leftView.contentMode = UIViewContentModeScaleAspectFit;
    leftView.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftViewSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftView addGestureRecognizer:swipe];
    [self addSubview:leftView];
    
    //leftView-back
    UIButton *bottomView = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomView.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height - 50, self.frame.size.width/2, 50);
    [bottomView.titleLabel setTextAlignment: NSTextAlignmentRight];
    [bottomView setTitle:@"0.0" forState:UIControlStateNormal];
    [bottomView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomView addTarget:self action:@selector(bottomViewClick:) forControlEvents:UIControlEventTouchUpInside];
    //[leftView addSubview:bottomView];

}

-(UIImage *)getBgImage{
    return [UIImage imageNamed:@"image_leftImg"];
}

-(void)setLeftViewbgImg:(UIImage *)image{

    leftView.image = image;
}
-(void)bottomViewClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(backButtonClick:)]) {
        [self.delegate backButtonClick:button];
    }
}

-(void)leftViewSwipe:(UISwipeGestureRecognizer *)swipe{
    if (swipe.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(leftViewSwipe:)]) {
            [self.delegate leftViewSwipe:swipe];
        }
    }
    
}

@end
