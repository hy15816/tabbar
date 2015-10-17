//
//  HYLoadMoreFooterView.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/21.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "HYLoadMoreFooterView.h"

@implementation HYLoadMoreFooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)footer{
    return [[[NSBundle mainBundle] loadNibNamed:@"HYLoadMoreFooterView" owner:nil options:nil] lastObject];
}

@end
