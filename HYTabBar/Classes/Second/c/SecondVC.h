//
//  SecondVC.h
//  CusTabBar
//
//  Created by AEF-RD-1 on 15/9/10.
//  Copyright (c) 2015年 rd-123. All rights reserved.
//

#import "ProjBaseVC.h"

@interface Person : NSObject

{
    @private
    NSString *_name;
    NSString *_age;
    NSString *_address;
    NSString *_phone;
    NSString *_pwd;
}

@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *age;
@property (strong,nonatomic) NSString *address;
@property (strong,nonatomic) NSString *phone;
@property (strong,nonatomic) NSString *pwd;

@end


@interface SecondVC : ProjBaseVC

@end
