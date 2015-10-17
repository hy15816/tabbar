//
//  FourCell.h
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/19.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#define YYYGate @"摇一摇"
#define AutoGate @"自   动"

#import <UIKit/UIKit.h>

@protocol FourCellDelegate <NSObject>
@optional
-(void)switchAct:(UISwitch *)sth;

@end

@interface FourCell : UITableViewCell

+ (instancetype) cellWithTableView:(UITableView*)tableView;

@property (assign,nonatomic) id<FourCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *leftImgv;
@property (strong, nonatomic) IBOutlet UISwitch *autoSwitch;
- (IBAction)switchAction:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UILabel *carCardLabel;

@end
