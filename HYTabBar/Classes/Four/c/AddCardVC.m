//
//  AddCardVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/19.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//
#define AddFaile @"addFaile"

#import "AddCardVC.h"
#import "NSString+helper.h"

@interface AddCardVC ()<UITextFieldDelegate>

@property (strong,nonatomic) NSMutableArray *mutArray;

@property (strong, nonatomic) IBOutlet UITextField *inputCarCard;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
- (IBAction)addButtonClick:(UIButton *)sender;

@end

@implementation AddCardVC

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    _mutArray =  [GlobalTool getData:hDFUSERNAME];
    NSLog(@"mutArray:%@",_mutArray);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mutArray = [[NSMutableArray alloc] init];
    _inputCarCard.delegate = self;
    _inputCarCard.text = [[hUSERDFS valueForKey:AddFaile] length]?[hUSERDFS valueForKey:AddFaile]:@"";
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSString *inputString =[NSString stringWithFormat:@"%@%@",_inputCarCard.text,string];
//    if (inputString.length >9 || inputString.length < 6) {
//        return NO;
//    }
//    if (![inputString validateCarNo]) {
//        return NO;
//    }
    return YES;
}
- (IBAction)addButtonClick:(UIButton *)sender {
    if (self.inputCarCard.text.length < 6 || self.inputCarCard.text.length>9) {
        [SVProgressHUD showImage:nil status:@"请输入正确的车牌"];
        return;
    }else{
        [self addCarNumber];
    }
    
}

-(void)addCarNumber{
    NSString *carNumber = [self.inputCarCard.text uppercaseString];
    [GlobalTool postJSONWithUrl:OPCARINFOURL parameters:@{hUSERNAME:hDFUSERNAME , hLsptNumber:carNumber,@"cd":@"c"} success:^(NSDictionary *json){
        NSLog(@"add return json:%@",json);

        if ([[json objectForKey:hLsptNumber] isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:@"添加成功"];
            
            //保存到本地
            [GlobalTool saveData:carNumber carNumId:[json objectForKey:@"license_plate_id"] user:hDFUSERNAME];
            //保存开闸状态
            [GlobalTool saveState:OpenGateTypeYaoYiYao forCarNumber:carNumber];
            
            //置空
            [hUSERDFS setValue:@"" forKey:AddFaile];
            [self back];
        }else{
            [hUSERDFS setValue:carNumber forKey:AddFaile];
            [GlobalTool errorWithCode:[[json objectForKey:@"license_plate_id"] intValue]];
            
        }
        
        
    } fail:^(NSError *error){
        NSLog(@"add return err:%@",error);
        [hUSERDFS setValue:carNumber forKey:AddFaile];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    

}

-(void)back{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        
    });
}

@end
