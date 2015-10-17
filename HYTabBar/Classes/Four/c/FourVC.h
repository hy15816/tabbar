//
//  FourVC.h
//  CusTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 rd-123. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FourVCDelegate <NSObject>

-(void)showLoginView;

@end

@interface FourVC : UITableViewController

@property (assign,nonatomic) id<FourVCDelegate> delegate;

@end
