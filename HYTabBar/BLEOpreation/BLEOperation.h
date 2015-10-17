//
//  BLEOperation.h
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/23.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#define BLEBOOL @"bleBool"

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEOperationDelegate <NSObject>
@required
/**
 *  中心设备状态更新
 *
 *  @param message 更新提示信息
 */
-(void)didUpdateCMState:(NSString *)message;

@optional;
/**
 *  连接成功
 *
 *  @param carDict 连接成功的车牌
 */
-(void)didConnectWithCar:(NSDictionary *)carDict;

/**
 *  外设特征值更新
 *
 *  @param result 结果
 */
-(void)didUpdateValueForChtc:(NSString *)result;

/**
 *  已断开连接
 */
-(void)didDisConnection;

/**
 *  开闸是否成功
 */
-(void)didOpenGatesWithError:(NSString *)result;

@end

@interface BLEOperation : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (assign,nonatomic) id<BLEOperationDelegate> delegate;
@property (assign,nonatomic) id<BLEOperationDelegate> delegatePeripheralProperValue;

@property (strong,nonatomic) NSMutableArray *allCarArray;

+ (BLEOperation *)share;

-(void)initCentralManager;          //初始化中心
-(void)startScan;                   //扫描外设
-(void)connectPeripheral;           //连接外设
-(void)cancelPeripheralConnection;  //断开连接

-(NSData *)getData:(NSString *)carNumber carId:(NSString *)idString;
@end
