//
//  FirstCell.h
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/24.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface FirstCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)imageBtnClick:(UIButton *)sender;

+(instancetype)cellWithTableView:(UITableView *)tableView;

@end
