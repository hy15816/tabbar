//
//  FourCell.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/19.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "FourCell.h"

@implementation FourCell

- (void)awakeFromNib {
    // Initialization code
}

+ (instancetype) cellWithTableView:(UITableView*)tableView{
    // 1. 可重用标示符
    static NSString *idf = @"Cell";
    // 2. tableView查询可重用Cell
    FourCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    
    // 3. 如果没有可重用cell
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FourCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchAction:(UISwitch *)sender  {
    
    if ([self.delegate respondsToSelector:@selector(switchAct:)]) {
        [self.delegate switchAct:sender];
    }
}
@end
