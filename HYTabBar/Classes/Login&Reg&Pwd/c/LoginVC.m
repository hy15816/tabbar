//
//  LoginVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/19.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#define userNameLength  11
#define userPwdsLength  6

#import "LoginVC.h"
#import "SecurityUtil.h"

@interface LoginVC ()<UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *userNameFiled;
@property (strong, nonatomic) IBOutlet UITextField *userPwdField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)cancelLoginClick:(UIBarButtonItem *)sender;
- (IBAction)loginButtonClick:(UIButton *)sender;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.loginButton.enabled = NO;
    _userPwdField.delegate = self;
    _userNameFiled.delegate = self;
    _userNameFiled.text = [[hUSERDFS valueForKey:hUSERNAME] length]>0?[hUSERDFS valueForKey:hUSERNAME]:@"";
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


- (IBAction)cancelLoginClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)loginButtonClick:(UIButton *)sender {
    [_userNameFiled resignFirstResponder];
    [_userPwdField resignFirstResponder];
    if (_userNameFiled.text.length <userNameLength || _userPwdField.text.length < userPwdsLength-3) {
        [SVProgressHUD showImage:nil status:@"请输入正确的账号密码"];
    }else{
        

        [self login];
    }
    
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (_userNameFiled.text.length >=userNameLength-1 && _userPwdField.text.length >= userPwdsLength-3) {
        _loginButton.enabled = YES;
    }
    
    return YES;
}

/**
 *  登录
 */

-(void)login{
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != kNotReachable) {
        [self loginWithNameAndPwd];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请检查网络"];
    }
    
}

-(void)loginWithNameAndPwd{
    
    //用用户名密码登陆
    NSString *user = self.userNameFiled.text;
    NSString *pwd = self.userPwdField.text;
    NSString *md5Pwd = [SecurityUtil encryptMD5String:pwd];
    [GlobalTool postJSONWithUrl:LOGINURL parameters:@{hUSERNAME:user , hUSERPWD:md5Pwd} success:^(NSDictionary *json){
        
        if ([[json objectForKey:hCODE] length] == 32 ) {
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            NSLog(@"mima login code:%@",[json objectForKey:hCODE]);
            
            //保存登录状态
            [hUSERDFS setValue:user forKey:hUSERNAME];
            [hUSERDFS setValue:@"1" forKey:hLOGINSTATE];
            [hUSERDFS setValue:pwd forKey:hUSERPWD];
            [hUSERDFS setValue:[json objectForKey:hCODE] forKey:hDMTCODE];//凭证码
            [GlobalTool setUserPlistFile:user];//创建person.plist文件
            [self loginSuc];
        }
        [GlobalTool errorWithCode:[[json objectForKey:hCODE] intValue]];
    } fail:^(NSError *error){
        
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.userNameFiled resignFirstResponder];
    [self.userPwdField resignFirstResponder];
}

-(void)loginSuc{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"\n\n");}];
}

@end
