//
//  ScanVC.h
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/14.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanVC : UIViewController

@property (copy, nonatomic) void (^scanFinishedBlock) (NSString *result);

@end
