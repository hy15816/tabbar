//
//  FirstCell.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/24.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "FirstCell.h"

@implementation FirstCell

- (IBAction)imageBtnClick:(UIButton *)sender {
}

+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    // 1. 可重用标示符
    static NSString *ID = @"FirstCellID";
    // 2. tableView查询可重用Cell
    FirstCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 3. 如果没有可重用cell
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FirstCell" owner:nil options:nil] lastObject];
    }
    
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
