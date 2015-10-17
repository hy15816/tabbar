//
//  LeftView.h
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/14.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftViewDelegate  <NSObject>

-(void)backButtonClick:(UIButton *)button;
-(void)leftViewSwipe:(UISwipeGestureRecognizer *)swipe;
@end

@interface LeftView : UIView

@property (assign,nonatomic) id<LeftViewDelegate> delegate;

/**
 *  设置背景图片
 *
 *  @param image image
 */
-(void)setLeftViewbgImg:(UIImage *)image;

@end
