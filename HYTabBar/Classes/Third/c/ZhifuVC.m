//
//  ZhifuVC.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/12.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//  测试支付宝支付

/**===============================================
 *  1.https://open.alipay.com 移动应用开发，创建应用,
 *  2.相关配置，
 *  3.根据PDF文档说明导入头文件及类库，Other Linker Flags -Objc(非必需),
 *  4.(openssl文件、头文件)添加正确的Header Search Paths :&(PROJECT_DIR)/ 加上openssl的文件位置(Show in Finder->command+i->拷贝路径)，
 *  5.获取partner:身份ID，seller:支付宝收款账号，private_key:商户方的私钥
 *  6.配置appScheme，Info->Url Types ->URL Schemes:hytabBarTypesUrl
 *  7.在AppDelegate注册回调
 ===============================================*/

#import "ZhifuVC.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "Order.h"
//以下安尔发公司账户，
static NSString *partner = @"2088011087664696";
static NSString *seller = @"anerfa1688@126.com";
static NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK+XijtWzKAmFHHGhrrbhI4o/tKLWrwlyx4+A6T+RiFknrMP5HDiMvB6cRvV0taCe51N0wDledQ40RHDZUMlrOVgEb5XvPUBJQYanBD8m8IRveTkQomkplMI22Hgdjv5r+6S50Kjgrrrw1bosM/mlb/BMDNb4ghED7nZZL8A/+3FAgMBAAECgYAu14NFvysJUf9ENsy8TlE3R1JrQkerR32/DJYWTsrQn7ICXKv5PS6PnmpMHaeIF/j4BsnSRGVSqvGDBpgd6JANk0d/xWYe/n9VFRrzTUksQuAwVAFQszwyyvGC+tT/FNRDdI29cPwJVluY4WbbabdXU52LKte7KfliSERD2bs7YQJBAOMRv1bHIY4lIfiX49egvfxlfIxGU7ytERFIgnDTtL4UhHN+SFupk/1PBg+A24qgQ6qpfNi6KZUj13DaG5/IPk0CQQDF9sU5iqZL4kZhL1Kcpi6mNu5hiZsQrp95Ua8nW78KAcN2CLOLm61JuU8mW9O6ByDv7gGjjA5G1Rixv119X9lZAkEAskysRzLECX7k5vQ154qDxF3YZ7mNZTksjrq2GmxSn3My8hF2Neu5lg1oP+I6AeeIWskNjIzZvA9Ry36odFXjfQJARO5cVmD07s9nekekGG+1JqNR9hyYJgLn/LJ4rte/eZiLmvoEqsQWXulrqgunecspqOHTKEOIZRmmc54Sy6koYQJAB+BwH5C+I1KSQ4daJWerl+vLPKqc7EYIvGXG9Ju2hNUcNUWDTqHyPHiOPGgLWgd1kfra/e5HMNzlbHK3v4H9ig==";

@interface ZhifuVC ()
- (IBAction)confirmPay:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation ZhifuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.confirmButton.layer.cornerRadius = 5;
    self.confirmButton.layer.borderWidth = .5;
    self.confirmButton.layer.borderColor = [UIColor redColor].CGColor;
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

- (IBAction)confirmPay:(UIButton *)sender {
    
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = @"这是商品标题"; //商品标题
    order.productDescription = @"商品描述商品描述商品描述商品描述"; //商品描述
    order.amount = @"0.01"; //商品价格（元）
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";//商品信息
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";//未付款交易的超时时间，30分钟
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"hytabBarTypesUrl";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    //NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        NSLog(@"orderString:%@",orderString);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
    }

}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    //2015091200
    //时间+
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
@end
