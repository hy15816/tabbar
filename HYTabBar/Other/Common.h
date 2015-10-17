//
//  common.h
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/14.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

//==================常用值=====================
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)      //设备屏幕宽度
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)    //设备屏幕高度
#define hUSERDFS [NSUserDefaults standardUserDefaults]
#define hHYTabBarHeight 49.f        //tabbar高度
/** 本地路径*/
#define hDocumentPath       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define hPersonsPlistPath    [hDocumentPath stringByAppendingPathComponent:@"persons.plist"]
#define hPlistPath(fileName) [hDocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]]
#define hMainStoryboard     [UIStoryboard storyboardWithName:@"Main" bundle:nil]

/** r red   0-255 g green 0-255 b blue  0-255 a alpha 0-1 */
#define COLORRGB(r,g,b,a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]

/** value 0xFFFFFF*/
#define COLORVALUE(value,a) [UIColor colorWithRed:((value & 0xFF0000) >> 16)/255.f green:((value & 0xFF00) >> 8)/255.f blue:(value & 0xFF)/255.0 alpha:a]

//==================地址=======================
#define hGetURLImage    @"http://img5.imgtn.bdimg.com/it/u=3279029117,1242220858&fm=21&gp=0.jpg"       //图片网址
#define LOGINURL        @"http://112.74.128.144:8189/AnerfaBackstage/login/login.do"                    //登录
#define OPCARINFOURL    @"http://112.74.128.144:8189/AnerfaBackstage/addLicensePlate/addLicensePlate.do"    //操作车牌



//==================用户=======================
#define hDFUSERNAME  [hUSERDFS valueForKey:hUSERNAME]
#define hLOGINSTATE  @"loginState"   //登录状态
#define hUSERNAME    @"user_name"    //用户名
#define hUSERPWD     @"password"     //密码
#define hDMTCODE     @"documentCode" //凭证码
#define hCODE        @"code"         //返回值
#define hCARNUM      @"License_plate_number"    //车牌号码
#define hCARNUMID    @"license_plate_id"        //车牌号码ID
#define hStateAuto   @"auto_state"              //开闸状态
#define hLsptNumber  @"license_plate_number"    //错误码